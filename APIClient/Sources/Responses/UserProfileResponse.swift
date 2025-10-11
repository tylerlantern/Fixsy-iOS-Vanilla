import Foundation

public struct UserProfileResponse: Decodable, Equatable {
  public let id: String
  public let email: String
  public let firstName: String
  public let lastName: String
  public let pictureUrl: URL?
  public let point: Int
}
