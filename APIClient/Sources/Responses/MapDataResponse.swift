import Foundation

public struct MapDataResponse: Decodable {
  public let places: [PlaceResponse]

  public init(
    places: [PlaceResponse]
  ) {
    self.places = places
  }
}
