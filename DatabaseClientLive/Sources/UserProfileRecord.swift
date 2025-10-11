import Foundation
import GRDB
import Models
import UserProfileModel

public struct UserProfileRecord: Codable, FetchableRecord, PersistableRecord {
  public static var databaseTableName: String {
    "USER_PROFILE"
  }

  public let id: String
  public let email: String
  public let firstName: String
  public let lastName: String
  public let pictureURL: URL?
  public let point: Int
}

func fetchUserProfile(db: Database) throws -> UserProfile? {
  func toUserProfile(_ r: UserProfileRecord) -> UserProfile {
    .init(
      id: r.id,
      email: r.email,
      firstName: r.firstName,
      lastName: r.lastName,
      pictureURL: r.pictureURL,
      point: r.point
    )
  }
  let userProfile = try UserProfileRecord
    .fetchOne(db)
    .map(toUserProfile)
  return userProfile
}

func syncUserProfile(db: Database, _ u: UserProfile) throws {
  try UserProfileRecord(
    id: u.id,
    email: u.email,
    firstName: u.firstName,
    lastName: u.lastName,
    pictureURL: u.pictureURL,
    point: u.point
  ).save(db)
}
