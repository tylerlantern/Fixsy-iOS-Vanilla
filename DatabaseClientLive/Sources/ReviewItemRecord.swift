import DatabaseClient
import Foundation
import GRDB
import Model

public struct ReviewItemRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "REVIEW_ITEM"
  }

  public let id: Int
  public let placeId: Int
  public let text: String
  public let fullName: String
  public let profileImage: URL?
  public let givenRate: Double
  public let createdDate: Date

  static let images = hasMany(ReviewItemImageRecord.self).forKey("images")
  static let reviewItemRelatingCarBrand = hasMany(ReviewItemRelatingCarBrandRecord.self)
  static let carBrands = hasMany(
    CarBrandRecord.self,
    through: reviewItemRelatingCarBrand,
    using: ReviewItemRelatingCarBrandRecord.brand
  )
}

public struct ReviewItemImageRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "REVIEW_ITEM_IMAGE"
  }

  public let id: Int
  public let reviewItemId: Int
  public let url: URL?
}

struct ReviewItemRelatingCarBrandRecord: Codable, FetchableRecord, PersistableRecord {
  static var databaseTableName: String = "REVIEW_ITEM_RELATING_CAR_BRAND"
  let reviewItemId: Int
  let brandId: Int
  static let reviewItem = belongsTo(ReviewItemRecord.self)
  static let brand = belongsTo(CarBrandRecord.self)
}

func fetchReviewItems(db: Database, placeId: Int) throws -> [ReviewItem] {
  func toItem(_ r: ReviewItemFetchableRecord) -> ReviewItem {
    func toImage(_ r: ReviewItemImageRecord) -> ReviewItem.Image {
      ReviewItem.Image(id: r.id, url: r.url)
    }

    return ReviewItem(
      id: r.item.id,
      text: r.item.text,
      fullName: r.item.fullName,
      profileImage: r.item.profileImage,
      givenRate: r.item.givenRate,
      images: r.images.map(toImage),
      createdDate: r.item.createdDate,
      carBrands: r.carBrands.map(toCarBrand)
    )
  }
  return try ReviewItemFetchableRecord.fetchAll(
    db,
    ReviewItemRecord
      .filter(Column("placeId") == placeId)
      .including(all: ReviewItemRecord.images.forKey("images"))
      .including(
        all: ReviewItemRecord.carBrands.forKey("carBrands")
          .order(Column("displayName").asc)
      )
      .order(Column("createdDate").desc)
  ).map(toItem)
}

func toReviewFetchableRecord(placeId: Int, _ m: ReviewItem) -> ReviewItemFetchableRecord {
  func toImage(_ m: ReviewItem.Image, reviewId: Int) -> ReviewItemImageRecord {
    ReviewItemImageRecord(id: m.id, reviewItemId: reviewId, url: m.url)
  }

  return ReviewItemFetchableRecord(
    item: ReviewItemRecord(
      id: m.id,
      placeId: placeId,
      text: m.text,
      fullName: m.fullName,
      profileImage: m.profileImage,
      givenRate: m.givenRate,
      createdDate: m.createdDate
    ),
    images: m.images.map({ toImage($0, reviewId: m.id) }),
    carBrands: m.carBrands.map(toCarBrandRecord)
  )
}

func saveReviewFetchableRecrod(db: Database, _ f: ReviewItemFetchableRecord) throws -> Int {
  try f.item.save(db)
  try f.images.forEach({
    try $0.save(db)
  })

  try f.carBrands.forEach({
    try $0.save(db)
    try ReviewItemRelatingCarBrandRecord(
      reviewItemId: f.item.id, brandId: $0.id
    ).save(db)
  })
  return 1
}

func syncReviewItems(
  db: Database,
  placeId: Int,
  updates: [ReviewItem],
  removes: [ReviewItem]
) throws -> (Int, Int) {
  try updates.map({ toReviewFetchableRecord(placeId: placeId, $0) }).forEach({ f in
    _ = try saveReviewFetchableRecrod(db: db, f)
  })

  let numberOfRemoveItems = try ReviewItemRecord.deleteAll(db, keys: removes.map(\.id))

  return (updates.count, numberOfRemoveItems)
}

struct ReviewItemFetchableRecord: Decodable, FetchableRecord {
  let item: ReviewItemRecord
  let images: [ReviewItemImageRecord]
  let carBrands: [CarBrandRecord]
}
