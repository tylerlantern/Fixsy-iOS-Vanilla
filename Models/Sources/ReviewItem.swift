import Foundation

public struct ReviewItem: Equatable,Identifiable {
  public let id: Int
  public let text: String
  public let fullName: String
  public let profileImage: URL?
  public let givenRate: Double
  public let images: [Image]
  public let createdDate: Date
  public let carBrands: [CarBrand]
  public init(
    id: Int,
    text: String,
    fullName: String,
    profileImage: URL?,
    givenRate: Double,
    images: [Image],
    createdDate: Date,
    carBrands: [CarBrand]
  ) {
    self.id = id
    self.text = text
    self.fullName = fullName
    self.profileImage = profileImage
    self.givenRate = givenRate
    self.images = images
    self.createdDate = createdDate
    self.carBrands = carBrands
  }

  public struct Image: Equatable, Identifiable {
    public let id: Int
    public let url: URL?

    public init(id: Int, url: URL?) {
      self.id = id
      self.url = url
    }
  }
}
