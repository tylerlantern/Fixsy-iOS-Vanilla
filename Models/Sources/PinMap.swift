import MapKit

public struct PinMap: Identifiable, Equatable {
  public var id = UUID().uuidString
  public var location: CLLocation

  public init(id: String, location: CLLocation) {
    self.id = id
    self.location = location
  }
}
