import Foundation

public struct UserProfile: Equatable, Codable {
  public var id: String
  public var email: String
  public var firstName: String
  public var lastName: String
  public var pictureURL: URL?
  public var point: Int

  public init(
    id: String,
    email: String,
    firstName: String,
    lastName: String,
    pictureURL: URL?,
    point: Int
  ) {
    self.id = id
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.pictureURL = pictureURL
    self.point = point
  }
}
