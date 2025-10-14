import CoreLocation
import SwiftUI
import Synchronization
import LocationManagerClient

public extension LocationManagerClient {
	@MainActor
	static let liveValue: Self = {
		let box = LocationManagerBox()            // keeps strong refs & sets delegate once

		return LocationManagerClient(
			authorizationStatus: { box.manager.authorizationStatus },
			requestWhenInUseAuthorization: { box.manager.requestWhenInUseAuthorization() },
			requestLocation: { box.manager.requestLocation() },
			location: { box.manager.location },
			delegate: { box.broadcaster.makeStream() } // multicast to all subscribers
		)
	}()
}

/// Keeps strong refs to the Core Location objects and the broadcaster.
@MainActor
final class LocationManagerBox {
	let manager = CLLocationManager()
	let broadcaster = Broadcaster()

	private let delegateImpl: Delegate

	init() {
		delegateImpl = Delegate(broadcaster: broadcaster)
		manager.delegate = delegateImpl
	}
}

final class Delegate: NSObject, CLLocationManagerDelegate {
	let broadcaster: Broadcaster
	init(broadcaster: Broadcaster) { self.broadcaster = broadcaster }

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		broadcaster.yield(.didChangeAuthorization(manager.authorizationStatus))
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		broadcaster.yield(.didUpdateLocations(locations))
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		broadcaster.yield(.didFailWithError(error))
	}
}

/// Thread-safe broadcaster (mutex). Multicasts events to many AsyncStreams.
final class Broadcaster {
	private let dict = Mutex<[UUID: AsyncStream<LocationManagerClient.Event>.Continuation]>([:])

	func makeStream() -> AsyncStream<LocationManagerClient.Event> {
		let id = UUID()
		return AsyncStream { continuation in
			dict.withLock { $0[id] = continuation }
			continuation.onTermination = { [weak self] _ in
				_ = self?.dict.withLock { $0.removeValue(forKey: id) }
			}
		}
	}

	func yield(_ event: LocationManagerClient.Event) {
		// snapshot under lock, then yield outside the critical section
		let sinks = dict.withLock { Array($0.values) }
		for c in sinks { _ = c.yield(event) }
	}
}
