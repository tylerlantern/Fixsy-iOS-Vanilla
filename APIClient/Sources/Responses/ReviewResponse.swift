import Foundation

public typealias ReviewPageResponse = PageResponse<ReviewItemResponse>

public struct ReviewItemResponse: Codable, Equatable {
  public let id: Int
  public let text: String
  public let reviewerName: String
  public let reviewerProfileImage: String?
  public let createdDate: Date
  public let givenStar: Double
  public let brandCars: [CarBrandResponse]
  public let images: [ImageResponse]

  public init(
    id: Int,
    text: String,
    reviewerName: String,
    reviewerProfileImage: String?,
    createdDate: Date,
    givenStar: Double,
    brandCars: [CarBrandResponse],
    images: [ImageResponse]
  ) {
    self.id = id
    self.text = text
    self.reviewerName = reviewerName
    self.reviewerProfileImage = reviewerProfileImage
    self.createdDate = createdDate
    self.givenStar = givenStar
    self.brandCars = brandCars
    self.images = images
  }
}
