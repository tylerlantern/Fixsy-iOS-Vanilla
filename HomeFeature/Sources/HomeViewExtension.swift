import MapKit
import SwiftUI
import PlaceStore

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
		action : MapVisualChannel.Action
	) {
		switch action {
		case .viewDidLoad:
			break;
		case .didSelect(let placeId) :
			
			break;
		case .zoom(let to):
			break;
		case .regionChanged(let mKCoordinateRegion):
			break;
		case .didDeselect:
			break;
		case .didChangeCoordiateRegion(let mKCoordinateRegion):
			break;
		}
	}
	
}
