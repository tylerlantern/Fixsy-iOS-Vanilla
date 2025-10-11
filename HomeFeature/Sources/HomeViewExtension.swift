import MapKit
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
}
