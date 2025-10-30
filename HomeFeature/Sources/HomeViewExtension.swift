import APIClient
import BottomSheetModule
import MapKit
import Models
import SwiftUI

extension HomeView {
  func fetchData() {
    self.isRefreshing = true
    self.fetchTask?.cancel()
    self.fetchTask = Task {
      do {
        let mapResponse = try await self.apiClient.call(
          route: .mapData,
          as: MapResponse.self
        )
        _ = try await
          self.databaseClient.syncPlaces(toPlaces(mapResponse.branches))
        self.isRefreshing = false
      } catch is CancellationError {
        self.isRefreshing = false
      } catch {
        self.isRefreshing = false
        if let apiError = error as? APIError {
          self.bannerCenter.show(
            .error,
            title: apiError.title,
            body: apiError.body
          )
          return
        }
        self.bannerCenter.show(
          .error,
          title: String(localized: "Something went wrong."),
          body: error.localizedDescription
        )
      }
    }
  }

  func handleLocationAuthorizationStatus() {
    let authorizationStatus = self.locationManagerClient.authorizationStatus()
    switch authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      Task { @MainActor in
        self.locationManagerClient.requestLocation()
      }
    case .notDetermined:
      Task { @MainActor in
        self.locationManagerClient.requestWhenInUseAuthorization()
      }
    case .denied, .restricted:
      fallthrough
    @unknown default:
      break
    }
  }

  func handlePlaceStoreChannelAction(
    action: MapVisualChannel.Action
  ) {
    switch action {
    case .viewDidLoad:
      break
    case let .didSelect(placeId):
      self.detent = BottomSheetDetents.medium
      self.sheetDisplay = .detail(placeId)
    case .zoom:
      break
    case .regionChanged:
      break
    case .didDeselect:
      break
    case .didChangeCoordiateRegion:
      break
    }
  }

  func observeLocation() {
    self.locationTask = Task {
      for await locs in self.locationManagerClient.locationStream() {
        print("observeLocation", locs)
        // Fetch location first time and cancel observation.
        guard let loc = locs.first
        else { continue }
        let region = MKCoordinateRegion(
          center: loc.coordinate,
          latitudinalMeters: 750,
          longitudinalMeters: 750
        )
        self.mapVisualChannel.sendEvent(
          .userRegion(region)
        )
        self.locationTask?.cancel()
      }
    }
  }

  func observeAuthStatus() {
    self.locationAuthStatusTask?.cancel()
    self.locationAuthStatusTask = Task {
      for await authStatus in self.locationManagerClient.delegate()
        .compactMap({
          switch $0 {
          case let .didChangeAuthorization(status):
            return status
          default:
            return nil
          }
        })
      {
        if [
          CLAuthorizationStatus.authorizedAlways,
          CLAuthorizationStatus.authorizedWhenInUse
        ].contains(authStatus) {
          self.locationManagerClient.requestLocation()
        }
      }
    }
  }

  func observeMapVisualChannelAction() {
    self.mapVisualActionTask?.cancel()
    self.mapVisualActionTask = Task {
      for await action in self.mapVisualChannel.actionStream {
        self.handlePlaceStoreChannelAction(action: action)
      }
    }
  }

  func observeLocalData() {
    self.observeTask?.cancel()
    let clock = ContinuousClock()
    var innerTask: Task<(), Never>?
    self.observeTask = Task {
      for try await filter in databaseClient
        .observePlaceFilter()
        .removeDuplicates()
        .debounce(for: .milliseconds(200), clock: clock)
      {
        innerTask?.cancel()
        innerTask = Task {
          do {
            for try await localPlaces in self.databaseClient.observeMapData(filter, "") {
              self.mapVisualChannel.sendEvent(.places(localPlaces))
            }
          } catch is CancellationError {
            // expected when a newer filter arrives
          } catch {}
        }
      }

      // 4) outer loop finished (stream ended) — clean up the last inner
      innerTask?.cancel()
    }
  }

  func handleOnTapUserLocation() {
    let authStatus = self.locationManagerClient.authorizationStatus()
    guard authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse
    else {
      self.locationManagerClient.requestWhenInUseAuthorization()
      return
    }
    guard let loc = self.locationManagerClient.location()
    else {
      return
    }
    self.mapVisualChannel.sendEvent(
      .userRegion(
        .init(
          center: .init(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude
          ),
          latitudinalMeters: 750,
          longitudinalMeters: 750
        )
      )
    )
  }
}

public func toPlaces(_ items: [PlaceResponse]) -> [Place] {
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
