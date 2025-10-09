import Foundation
import GRDB

public struct CarBrandRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "CAR_BRAND"
  }

  public let id: Int
  public let displayName: String
}
