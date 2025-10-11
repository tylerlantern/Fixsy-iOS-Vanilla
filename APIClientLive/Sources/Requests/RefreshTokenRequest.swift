import Foundation
import Models

public struct RefreshTokenRequest: Codable {
  public let accessToken: String
  public let refreshToken: String

  public init(
    accessToken: String,
    refreshToken: String
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}
