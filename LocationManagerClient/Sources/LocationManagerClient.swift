import CoreLocation
import Foundation
import SwiftUI

public struct LocationManagerClient {
  public enum Event {
    case didChangeAuthorization(CLAuthorizationStatus)
    case didUpdateLocations([CLLocation])
    case didFailWithError(any Error)
  }

  public var authorizationStatus: () -> CLAuthorizationStatus
  public var requestWhenInUseAuthorization: () -> ()
  public var requestLocation: () -> ()
  public var location: () -> CLLocation?
  public var delegate: () -> AsyncStream<Event>
  public var locationStream: @Sendable () -> AsyncStream<[CLLocation]>

  public init(
    authorizationStatus: @escaping () -> CLAuthorizationStatus,
    requestWhenInUseAuthorization: @escaping () -> (),
    requestLocation: @escaping () -> (),
    location: @escaping () -> CLLocation?,
    delegate: @escaping () -> AsyncStream<Event>,
    locationStream: @Sendable @escaping () -> AsyncStream<[CLLocation]>
  ) {
    self.authorizationStatus = authorizationStatus
    self.requestWhenInUseAuthorization = requestWhenInUseAuthorization
    self.requestLocation = requestLocation
    self.location = location
    self.delegate = delegate
    self.locationStream = locationStream
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
          Event.didChangeAuthorization(.denied)
        }
      },
      locationStream: {
        AsyncStream { _ in }
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
