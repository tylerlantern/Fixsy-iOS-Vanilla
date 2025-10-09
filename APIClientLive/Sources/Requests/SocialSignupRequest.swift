import Foundation

public struct SocialSignupRequest: Codable {
  public let token: String
  public let provider: String
  public let firstname: String
  public let lastname: String
  public let username: String
  public let picture: String

  public init(
    token: String,
    provider: String,
    firstname: String,
    lastname: String,
    username: String,
    picture: String
  ) {
    self.token = token
    self.provider = provider
    self.firstname = firstname
    self.lastname = lastname
    self.username = username
    self.picture = picture
  }
}
