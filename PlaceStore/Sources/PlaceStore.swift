import APIClient
import DatabaseClient
import MapKit
import Models
import Observation
import SwiftUI

// The class is no longer used.
// The app use database observation instead
@Observable
public class PlaceStore {
  public var filter: PlaceFilter = .identity

  let eventChannel = AsyncStream.makeStream(of: Event.self)
  let locationStreamCallback: @Sendable () -> AsyncStream<[CLLocation]>
  let syncLocalCallback: ([Place]) async throws -> Int
  let apiClient: APIClient
  public init(
    apiClient: APIClient,
    locationStreamCallback: @escaping @Sendable () -> AsyncStream<[CLLocation]>,
    syncLocalCallback: @escaping @Sendable ([Place]) async throws -> Int,
  ) {
    self.apiClient = apiClient
    self.locationStreamCallback = locationStreamCallback
    self.syncLocalCallback = syncLocalCallback
  }

  public func assignPlaceFilter(_ filter: PlaceFilter) {
    self.filter = filter
  }
}

public enum Event {
  case places([Place])
}
