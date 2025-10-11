import CoreLocation
import LocationManagerClient
import SwiftUI
import Synchronization

public extension LocationManagerClient {
  @MainActor
  static let liveValue: Self = {
    let locationManager = CLLocationManager()
    return LocationManagerClient(
      authorizationStatus: {
        locationManager.authorizationStatus
      },
      requestWhenInUseAuthorization: {
        locationManager.requestWhenInUseAuthorization()
      },
      requestLocation: {
        locationManager.requestLocation()
      },

      location: {
        locationManager.location
      },
      delegate: {
        let delegate = Mutex<Delegate?>(nil)
        return AsyncStream<LocationManagerDelegateEvent> { continuation in
          delegate.withLock { $0 = Delegate(continuation: continuation) }
          continuation.onTermination = { _ in
            delegate.withLock { $0 = nil }
          }
          delegate.withLock { delegate in
            locationManager.delegate = delegate
          }
        }
      }
    )
  }()
}

final class Delegate: NSObject, CLLocationManagerDelegate, Sendable {
  let continuation: AsyncStream<LocationManagerDelegateEvent>.Continuation

  init(
    continuation: AsyncStream<LocationManagerDelegateEvent>.Continuation
  ) {
    self.continuation = continuation
  }

  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    self.continuation.yield(.didChangeAuthorization(manager.authorizationStatus))
  }

  public func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    self.continuation.yield(.didUpdateLocations(locations))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    self.continuation.yield(.didFailWithError(error))
  }
}
