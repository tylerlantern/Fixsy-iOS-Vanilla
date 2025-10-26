import BottomSheetModule
import MapKit
import PlaceStore
import SwiftUI

extension HomeView {
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

  func bindPlaces() {
    let clock = ContinuousClock()
    var innerTask: Task<(), Never>?
    Task {
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
          } catch {
            // TODO: surface error if you want
          }
        }
      }

      // 4) outer loop finished (stream ended) — clean up the last inner
      innerTask?.cancel()
    }
  }
}
