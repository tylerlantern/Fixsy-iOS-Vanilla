import CoreLocation
import LocationManagerClient
import SwiftUI
import Synchronization

public extension LocationManagerClient {
  @MainActor
  static let liveValue: Self = {
    let box = LocationManagerBox()
    return LocationManagerClient(
      authorizationStatus: { box.manager.authorizationStatus },
      requestWhenInUseAuthorization: { box.manager.requestWhenInUseAuthorization() },
      requestLocation: { box.manager.requestLocation() },
      location: { box.manager.location },
      delegate: {
        box.broadcaster.makeStream()
      },
      locationStream: {
        box.broadcaster.makeStreamLocation(
          box.manager.location
        )
      }
    )
  }()
}

@MainActor
final class LocationManagerBox {
  let manager = CLLocationManager()
  let broadcaster = Broadcaster()
  private let delegate: Delegate
  init() {
    self.delegate = Delegate(broadcaster: self.broadcaster)
    self.manager.delegate = self.delegate
  }
}

final class Delegate: NSObject, CLLocationManagerDelegate {
  let broadcaster: Broadcaster
  init(broadcaster: Broadcaster) { self.broadcaster = broadcaster }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    self.broadcaster.yield(.didChangeAuthorization(manager.authorizationStatus))
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    self.broadcaster.yieldLocation(locations)
    self.broadcaster.yield(.didUpdateLocations(locations))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.broadcaster.yield(.didFailWithError(error))
  }
}

final class Broadcaster {
  private let dict = Mutex<[UUID: AsyncStream<LocationManagerClient.Event>.Continuation]>([:])
  private let locationDict = Mutex<[UUID: AsyncStream<[CLLocation]>.Continuation]>([:])

  func makeStream() -> AsyncStream<LocationManagerClient.Event> {
    let id = UUID()
    return AsyncStream { continuation in
      self.dict.withLock { $0[id] = continuation }
      continuation.onTermination = { [weak self] _ in
        _ = self?.dict.withLock { $0.removeValue(forKey: id) }
      }
    }
  }

  func yield(_ event: LocationManagerClient.Event) {
    let sinks = self.dict.withLock { Array($0.values) }
    for c in sinks {
      _ = c.yield(event)
    }
  }

  func makeStreamLocation(_ loc: CLLocation?) -> AsyncStream<[CLLocation]> {
    let id = UUID()
    return AsyncStream { continuation in
      self.locationDict.withLock { $0[id] = continuation }
      continuation.yield(
        loc.map({ [$0] }) ?? []
      )
      continuation.onTermination = { [weak self] _ in
        _ = self?.locationDict.withLock { $0.removeValue(forKey: id) }
      }
    }
  }

  func yieldLocation(_ event: [CLLocation]) {
    let sinks = self.locationDict.withLock { Array($0.values) }
    for c in sinks {
      _ = c.yield(event)
    }
  }

  func searchTextChange() {
    Task {
      try await Task.sleep(nanoseconds: 120_000_000)
    }
  }
}
