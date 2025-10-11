import Foundation
import SwiftUI

public struct LocationCoordinate {
  public let latitude: Double
  public let longitude: Double

  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

public struct GeocodeResponse: Codable {
  public let results: [GeocodeResult]
  public let status: String
}

public struct GeocodeResult: Codable {
  public let formattedAddress: String
  public let addressComponents: [AddressComponent]
  public let geometry: Geometry
  public let placeId: String
  public let types: [String]

  enum CodingKeys: String, CodingKey {
    case formattedAddress = "formatted_address"
    case addressComponents = "address_components"
    case geometry
    case placeId = "place_id"
    case types
  }
}

public struct Geometry: Codable {
  public let location: Location
  public let locationType: String

  enum CodingKeys: String, CodingKey {
    case location
    case locationType = "location_type"
  }
}

public struct Location: Codable {
  public let lat: Double
  public let lng: Double
}

public struct AddressComponent: Codable {
  public let longName: String
  public let shortName: String
  public let types: [String]

  enum CodingKeys: String, CodingKey {
    case longName = "long_name"
    case shortName = "short_name"
    case types
  }
}
