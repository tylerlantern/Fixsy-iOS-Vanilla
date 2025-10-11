import Foundation
import GRDB
import Model

public struct PlaceFilterRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "PLACE_FILTER"
  }

  public let id: Int
  public let showCarGarage: Bool
  public let showMotorcycleGarages: Bool
  public let showInflationPoints: Bool
  public let showWashStations: Bool
  public let showPatchTireStations: Bool
}

func getPlaceFilter(db: Database) throws -> PlaceFilter {
  func toPlaceFilter(_ r: PlaceFilterRecord) -> PlaceFilter {
    PlaceFilter(
      showCarGarage: r.showCarGarage,
      showMotorcycleGarages: r.showMotorcycleGarages,
      showInflationPoints: r.showInflationPoints,
      showWashStations: r.showWashStations,
      showPatchTireStations: r.showPatchTireStations
    )
  }

  return try PlaceFilterRecord.fetchOne(db, key: 1).map(
    toPlaceFilter
  ) ?? .identity
}

func savePlaceFilter(db: Database, _ f: PlaceFilter) throws {
  func toRecord(_ m: PlaceFilter) -> PlaceFilterRecord {
    PlaceFilterRecord(
      id: 1,
      showCarGarage: m.showCarGarage,
      showMotorcycleGarages: m.showMotorcycleGarages,
      showInflationPoints: m.showInflationPoints,
      showWashStations: m.showWashStations,
      showPatchTireStations: m.showPatchTireStations
    )
  }
  try toRecord(f).save(db)
}
