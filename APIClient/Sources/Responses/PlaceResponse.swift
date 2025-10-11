import Foundation

public struct MapResponse: Decodable {
  public let branches: [PlaceResponse]
}

public struct PlaceResponse: Decodable {
  public let id: Int
  public let name: String
  public let latitude: Double
  public let longitude: Double
  public let address: String
  public let hasMotorcycleGarage: Bool
  public let hasInflationStation: Bool
  public let hasWashStation: Bool
  public let hasPatchTireStation: Bool
  public let hasCarGarage: Bool
  public let averageRate: Double
  public let carGarage: CarGarageResponse?
  public let openCloseTime: OpenCloseTimeResponse
  public let images: [ImageResponse]
  public let contributorName: String
}

public struct CarGarageResponse: Decodable {
  public let brands: [CarBrandResponse]
}

public struct OpenCloseTimeResponse: Decodable {
  public let mondayOpen: String
  public let mondayClose: String
  public let tuesdayOpen: String
  public let tuesdayClose: String
  public let wednesdayOpen: String
  public let wednesdayClose: String
  public let thursdayOpen: String
  public let thursdayClose: String
  public let fridayOpen: String
  public let fridayClose: String
  public let saturdayOpen: String
  public let saturdayClose: String
  public let sundayOpen: String
  public let sundayClose: String
}

public struct ImageResponse: Decodable, Equatable {
  public let id: Int
  public let url: URL
}
