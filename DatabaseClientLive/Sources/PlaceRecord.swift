import Foundation
import GRDB
import Model

public struct PlaceRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "PLACE"
  }

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

  // MARK: - OpenCloseTime

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

  public let contributorName: String

  static let images = hasMany(ImageRecord.self).forKey("images")
  static let placeCarBrandRelation = hasMany(PlaceCarBrandRelationRecord.self)
  static let carBrands = hasMany(
    CarBrandRecord.self,
    through: placeCarBrandRelation,
    using: PlaceCarBrandRelationRecord.brand
  )
}

struct PlaceCarBrandRelationRecord: Codable, FetchableRecord, PersistableRecord {
  static var databaseTableName: String = "PLACE_CAR_BRAND_RELATION"
  let placeId: Int
  let brandId: Int
  static let place = belongsTo(PlaceRecord.self)
  static let brand = belongsTo(CarBrandRecord.self)
}

public struct ImageRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "IMAGE"
  }

  public let id: Int
  public let url: URL
  public let placeId: Int
}

struct PlaceInfo: Decodable, FetchableRecord {
  let place: PlaceRecord
  let images: [ImageRecord]
  let carBrands: [CarBrandRecord]
}

func fetchPlaces(
  db: Database,
  filter: PlaceFilter,
  keyword: String
) throws -> [Place] {
  let keywordFilter: SQLExpression = [
    Column("name").like("%\(keyword)%"),
    Column("address").like("%\(keyword)%")
  ].joined(operator: .or)

  let carGarages = filter.showCarGarage
    ? try PlaceInfo.fetchAll(
      db,
      PlaceRecord
        .filter(Column("hasCarGarage") == true)
        .filter(keywordFilter)
        .include()
    ).map(toPlace)
    : []

  let motorcycleGarages = filter.showMotorcycleGarages
    ? try PlaceInfo.fetchAll(
      db,
      PlaceRecord
        .filter(Column("hasMotorcycleGarage") == true)
        .filter(keywordFilter)
        .include()
    ).map(toPlace)
    : []

  let inflationStations = filter.showInflationPoints
    ? try PlaceInfo.fetchAll(
      db,
      PlaceRecord
        .filter(Column("hasInflationStation") == true)
        .filter(keywordFilter)
        .include()
    ).map(toPlace)
    : []

  let washStations = filter.showWashStations
    ? try PlaceInfo.fetchAll(
      db,
      PlaceRecord
        .filter(Column("hasWashStation") == true)
        .filter(keywordFilter)
        .include()
    ).map(toPlace)
    : []

  let patchtireStations = filter.showPatchTireStations
    ? try PlaceInfo.fetchAll(
      db,
      PlaceRecord
        .filter(Column("hasPatchTireStation") == filter.showPatchTireStations)
        .filter(keywordFilter)
        .include()
    ).map(toPlace)
    : []
  let allServices = carGarages +
    motorcycleGarages +
    inflationStations +
    washStations +
    patchtireStations

  return allServices.uniqued(comparator: ==)
}

func fetchPlaces(db: Database, by keyword: String, limit: Int?) throws -> [Place] {
  try PlaceInfo.fetchAll(
    db,
    query(keyword: keyword, limit: limit)
      .include()
  )
  .map(toPlace)
}

extension QueryInterfaceRequest<PlaceRecord> {
  func include() -> QueryInterfaceRequest<PlaceRecord> {
    self.including(all: PlaceRecord.carBrands.forKey("carBrands"))
      .including(all: PlaceRecord.images.forKey("images"))
  }
}

func query(
  keyword: String,
  limit: Int?
) ->
  QueryInterfaceRequest<PlaceRecord>
{
  let searchFilters: SQLExpression = [
    Column("name").like("%\(keyword)%"),
    Column("address").like("%\(keyword)%")
  ].joined(operator: .or)

  if let limit = limit {
    return PlaceRecord
      .filter(searchFilters)
      .limit(limit)
  }

  return PlaceRecord
    .filter(searchFilters)
}

func savePlaces(db: Database, places ps: [Place]) throws {
  try ps.map(toPlaceRecord(place:))
    .forEach { info in
      try info.place.save(db)
      try info.images.forEach({ image in
        try image.save(db)
      })
      try PlaceCarBrandRelationRecord
        .filter(Column("placeId") == info.place.id)
        .deleteAll(db)
      try info.carBrands.forEach({ carBrand in
        try carBrand.save(db)
        try PlaceCarBrandRelationRecord(
          placeId: info.place.id,
          brandId: carBrand.id
        ).save(db)
      })
    }
}

extension Sequence {
  /// Return the sequence with all duplicates removed.
  ///
  /// Duplicate, in this case, is defined as returning `true` from `comparator`.
  ///
  /// - note: Taken from stackoverflow.com/a/46354989/3141234
  func uniqued(comparator: @escaping (Element, Element) throws -> Bool) rethrows -> [Element] {
    var buffer: [Element] = []
    for element in self {
      // If element is already in buffer, skip to the next element
      if try buffer.contains(where: { try comparator(element, $0) }) {
        continue
      }

      buffer.append(element)
    }

    return buffer
  }
}
