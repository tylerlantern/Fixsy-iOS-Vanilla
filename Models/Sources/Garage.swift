import Foundation

public struct Image {
  let id: Int
  let url: URL?
}

public struct Garage {
  public let id: Int
  public let name: String
  public let address: String
  public let images: [Image]
  public let latitude: Double
  public let longtitude: Double
  public init(
    id: Int,
    name: String,
    address: String,
    images: [Image],
    latitude: Double,
    longtitude: Double
  ) {
    self.id = id
    self.name = name
    self.address = address
    self.images = images
    self.latitude = latitude
    self.longtitude = longtitude
  }
}
