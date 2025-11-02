import Foundation

public struct ReviewItem: Equatable, Identifiable {
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

public extension ReviewItem {
  /// A single placeholder/shimmer item
  static func shimmer(
    id: Int = -1,
    imageCount: Int = 3,
    brandCount: Int = 2
  ) -> ReviewItem {
    ReviewItem(
      id: id,
      text: "SHIMMERSHIMMERSHIMMER", // keep strings non-empty so redaction reserves space
      fullName: "██████████",
      profileImage: nil,
      givenRate: 0,
      images: [],
      createdDate: Date(),
      carBrands: []
    )
  }

  /// Multiple placeholder/shimmer items
  static func shimmerList(
    count: Int = 3,
    imageCount: Int = 3,
    brandCount: Int = 2
  ) -> [ReviewItem] {
    (0 ..< count).map { i in
      ReviewItem.shimmer(id: -1_000 - i, imageCount: imageCount, brandCount: brandCount)
    }
  }
}
