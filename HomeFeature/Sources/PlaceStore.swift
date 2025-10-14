import APIClient
import DatabaseClient
import Foundation
import Models

public class PlaceStore: ObservableObject {
  public enum Event {
    case places([Place])
  }

  var filter: PlaceFilter = .identity
	@Published var keyword : String = ""
  let eventChannel = AsyncStream.makeStream(of: Event.self)
  let observeLocalDataCallback: (PlaceFilter,String) -> AsyncThrowingStream<[Place], Error>
  let syncLocalCallback: ([Place]) async throws -> Int
  var observeTask: Task<(), Error>?
  public init(
    observeLocalDataCallback: @escaping @Sendable (PlaceFilter,String) -> AsyncThrowingStream<
      [Place],
      Error
    >,
    syncLocalCallback: @escaping @Sendable ([Place]) async throws -> Int
  ) {
    self.observeLocalDataCallback = observeLocalDataCallback
    self.syncLocalCallback = syncLocalCallback
  }

  public func fetchRemote(
    callNetwork: () async throws -> (MapResponse)
  ) async {
    do {
      let mapResponse = try await callNetwork()
      _ = try await self.syncLocalCallback(self.toPlaces(mapResponse.branches))
    } catch {
      // TODO:
      print("FAILURE", error)
    }
  }

  public func observeLocalData() {
		self.observeTask?.cancel()
    self.observeTask = Task {
      for try await localPlaces in self.observeLocalDataCallback(
				self.filter, keyword
			) {
        self.eventChannel.continuation.yield(
          .places(localPlaces)
        )
      }
    }
  }

  private func toPlaces(_ items: [PlaceResponse]) -> [Place] {
    items.map { item in
      let oct = item.openCloseTime
      return Place(
        id: item.id,
        name: item.name,
        latitude: item.latitude,
        longitude: item.longitude,
        address: item.address,
        hasMotorcycleGarage: item.hasMotorcycleGarage,
        hasInflationStation: item.hasInflationStation,
        hasWashStation: item.hasWashStation,
        hasPatchTireStation: item.hasPatchTireStation,
        hasCarGarage: item.hasCarGarage,
        averageRate: item.averageRate,
        carGarage: item.carGarage.map({ garage in
          let brands = garage.brands.map { brand in
            CarBrand(id: brand.id, displayName: brand.displayName)
          }
          return Place.CarGarage.init(brands: brands)
        }),
        openCloseTime: Place.OpenCloseTime(
          mondayOpen: oct.mondayOpen,
          mondayClose: oct.mondayOpen,
          tuesdayOpen: oct.tuesdayOpen,
          tuesdayClose: oct.tuesdayClose,
          wednesdayOpen: oct.wednesdayOpen,
          wednesdayClose: oct.wednesdayClose,
          thursdayOpen: oct.tuesdayOpen,
          thursdayClose: oct.tuesdayClose,
          fridayOpen: oct.fridayOpen,
          fridayClose: oct.fridayClose,
          saturdayOpen: oct.saturdayOpen,
          saturdayClose: oct.saturdayClose,
          sundayOpen: oct.sundayOpen,
          sundayClose: oct.sundayClose,
        ),
        images: item.images.map({ image in
          Place.Image(
            id: image.id,
            url: image.url
          )
        }),
        contributorName: item.contributorName
      )
    }
  }
}
