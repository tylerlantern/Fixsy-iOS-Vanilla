import GRDB
import Model

public struct MotorcycleGarageRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "MOTORCYCLE_GARAGE"
  }

  public let id: Int
  public let name: String
  public let address: String
  public let latitude: Double
  public let longtitude: Double
  static let images = hasMany(ImageRecord.self).forKey("images")
}

public struct InflatingPointRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "INFLATING_POINT"
  }

  public let id: Int
  public let name: String
  public let address: String
  public let latitude: Double
  public let longtitude: Double
  static let images = hasMany(ImageRecord.self).forKey("images")
}

public struct WashStationRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "WASH_STATION"
  }

  public let id: Int
  public let name: String
  public let address: String
  public let latitude: Double
  public let longtitude: Double
  static let images = hasMany(ImageRecord.self).forKey("images")
}

public struct PatchTireStationRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "PATCH_TIRE_STATION"
  }

  public let id: Int
  public let name: String
  public let address: String
  public let latitude: Double
  public let longtitude: Double
  static let images = hasMany(ImageRecord.self).forKey("images")
}

//
// func syncMapDataResponseToRecords(response: DataMapResponse, db: Database) throws {
//  try response.motorcycleGarages.forEach { m in
//    try MotorcycleGarageRecord(
//      id: m.id,
//      name: m.name,
//      address: m.address,
//      latitude: m.latitude,
//      longtitude: m.longtitude
//    ).save(db)
//    try m.images.forEach({ imageResponse in
//      try ImageRecord(
//        id: imageResponse.id,
//        url: imageResponse.url,
//        motorcycleGarageId: m.id
//      ).save(db)
//    })
//  }
//
//  try response.inflatingPoints.forEach { m in
//    try InflatingPointRecord(
//      id: m.id,
//      name: m.name,
//      address: m.address,
//      latitude: m.latitude,
//      longtitude: m.longtitude
//    ).save(db)
//    try m.images.forEach({ imageResponse in
//      try ImageRecord(
//        id: imageResponse.id,
//        url: imageResponse.url,
//        inflatingPointId: m.id
//      ).save(db)
//    })
//  }
//
//  try response.washStations.forEach { m in
//    try WashStationRecord(
//      id: m.id,
//      name: m.name,
//      address: m.address,
//      latitude: m.latitude,
//      longtitude: m.longtitude
//    ).save(db)
//    try m.images.forEach({ imageResponse in
//      try ImageRecord(
//        id: imageResponse.id,
//        url: imageResponse.url,
//        washStationId: m.id
//      ).save(db)
//    })
//  }
//
//  try response.patchTireStations.forEach { m in
//    try PatchTireStationRecord(
//      id: m.id,
//      name: m.name,
//      address: m.address,
//      latitude: m.latitude,
//      longtitude: m.longtitude
//    ).save(db)
//    try m.images.forEach({ imageResponse in
//      try ImageRecord(
//        id: imageResponse.id,
//        url: imageResponse.url,
//        patchTireStationId: m.id
//      ).save(db)
//    })
//  }
// }
//
// func toImageResponse(_ r: ImageRecord) -> ImageResponse {
//  .init(id: r.id, url: r.url)
// }
