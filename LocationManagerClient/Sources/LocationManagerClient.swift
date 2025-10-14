import CoreLocation
import Foundation
import SwiftUI

public struct LocationManagerClient {
  public var authorizationStatus: () -> CLAuthorizationStatus
  public var requestWhenInUseAuthorization: () -> ()
  public var requestLocation: () -> ()
  public var location: () -> CLLocation?
  public var delegate: () -> AsyncStream<LocationManagerDelegateEvent>

  public init(
    authorizationStatus: @escaping () -> CLAuthorizationStatus,
    requestWhenInUseAuthorization: @escaping () -> (),
    requestLocation: @escaping () -> (),
    location: @escaping () -> CLLocation?,
    delegate: @escaping () -> AsyncStream<LocationManagerDelegateEvent>,
  ) {
    self.authorizationStatus = authorizationStatus
    self.requestWhenInUseAuthorization = requestWhenInUseAuthorization
    self.requestLocation = requestLocation
    self.location = location
    self.delegate = delegate
  }
}

extension LocationManagerClient: EnvironmentKey {
  public static var defaultValue: Self {
    LocationManagerClient(
      authorizationStatus: { .restricted },
      requestWhenInUseAuthorization: {},
      requestLocation: {},
      location: { nil },
      delegate: {
        AsyncStream {
          LocationManagerDelegateEvent.didChangeAuthorization(.denied)
        }
      }
    )
  }

  public static var testValue: Self {
    .defaultValue
  }

  public static var previewValue: Self {
    .defaultValue
  }
}

extension EnvironmentValues {
  public var locationManagerClient: LocationManagerClient {
    get { self[LocationManagerClient.self] }
    set { self[LocationManagerClient.self] = newValue }
  }
}

extension CLAuthorizationStatus {
  public var description: String {
    switch self {
    case .notDetermined:
      "notDetermined"
    case .denied:
      "denied"
    case .restricted:
      "restricted"
    case .authorizedWhenInUse:
      "authorizedWhenInUse"
    case .authorizedAlways:
      "authorizedAlways"
    default:
      "unknown"
    }
  }
}

public enum LocationManagerDelegateEvent {
  case didChangeAuthorization(CLAuthorizationStatus)
  case didUpdateLocations([CLLocation])
  case didFailWithError(any Error)
}
