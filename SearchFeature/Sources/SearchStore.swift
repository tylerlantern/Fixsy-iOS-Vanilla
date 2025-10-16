import AsyncAlgorithms
import MapKit
import Models
import SwiftUI

@MainActor
public class SearchStore: ObservableObject {
  enum Tap {
    case motorcycle
    case car
    case inflationPoint
    case patchTire
    case washStation
  }

  @Published var filter: PlaceFilter = .identity
  @Published var items: [Item] = []
  @Published var searchText: String = ""

  let locationEvent = AsyncStream.makeStream(of: CLLocation.self)

  let placeCallback: @Sendable (PlaceFilter, String) -> AsyncThrowingStream<[Place], Error>
  let filterCallback: @Sendable () -> AsyncThrowingStream<PlaceFilter, Error>
  let locationCallback: @Sendable () -> AsyncStream<[CLLocation]>

  public init(
    placeCallback: @Sendable @escaping (PlaceFilter, String) -> AsyncThrowingStream<[Place], Error>,
    filterCallback: @Sendable @escaping () -> AsyncThrowingStream<PlaceFilter, Error>,
    locationCallback: @Sendable @escaping () -> AsyncStream<[CLLocation]>
  ) {
    self.placeCallback = placeCallback
    self.filterCallback = filterCallback
    self.locationCallback = locationCallback
  }

  private var observePlacesTask: Task<(), Error>?
  private var observeFilterTask: Task<(), Error>?
  private var transformTask: Task<(), Error>?
  private var searchTask: Task<(), Error>?
  private var locTask: Task<(), Error>?

  func observePlaceFilter() {
    self.observeFilterTask = Task {
      for try await localFilter in self.filterCallback() {
        self.filter = localFilter
      }
    }
  }

  func observeLocalData() {
    self.observePlacesTask?.cancel()
    self.transformTask?.cancel()
    self.observePlacesTask = Task {
      let placesSeq = self.placeCallback(self.filter, self.searchText).removeDuplicates()
      let locSeq = self.locationCallback()
      for try await(places, locs) in combineLatest(placesSeq, locSeq) {
        self.transformTask?.cancel()
        self.transformTask = Task.detached {
          let sortedItems = places.map({ place in
            guard let userLoc = locs.last else {
              return Item(
                id: place.id,
                name: place.name,
                image: Item.parseImage(place),
                service: Item.parseService(place),
                address: place.address,
                distance: nil
              )
            }
            let distance = haversine(
              lat1: userLoc.coordinate.latitude,
              lon1: userLoc.coordinate.longitude,
              lat2: place.latitude,
              lon2: place.longitude
            )
            return Item(
              id: place.id,
              name: place.name,
              image: Item.parseImage(place),
              service: Item.parseService(place),
              address: place.address,
              distance: distance
            )
          })
          .sorted { item1, item2 in
            guard let distance1 = item1.distance,
                  let distance2 = item2.distance
            else {
              return true
            }
            return distance1 > distance2
          }
          await MainActor.run {
            self.items = sortedItems
          }
        }
      }
    }
  }

  func searchTextChanged() {
    self.searchTask?.cancel()
    self.searchTask = Task {
      try await Task.sleep(nanoseconds: 300_000_000)
      self.observeLocalData()
    }
  }

  deinit {
    self.observePlacesTask?.cancel()
    self.observeFilterTask?.cancel()
    self.transformTask?.cancel()
  }

  func handleOnTap(_ tap: Tap) {}
}

func haversine(
  lat1: Double,
  lon1: Double,
  lat2: Double,
  lon2: Double
) -> Double {
  let radius: Double = 6_371
  let latDelta = (lat2 - lat1) * .pi / 180
  let lonDelta = (lon2 - lon1) * .pi / 180

  let a = sin(latDelta / 2) * sin(latDelta / 2) +
    cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
    sin(lonDelta / 2) * sin(lonDelta / 2)

  let c = 2 * atan2(sqrt(a), sqrt(1 - a))
  return radius * c
}
