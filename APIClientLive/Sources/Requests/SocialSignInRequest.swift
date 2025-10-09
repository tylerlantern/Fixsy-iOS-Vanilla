import Foundation
import Model

public struct SocialSignInRequest: Codable {
  public let token: String
  public let provider: String

  public init(
    token: String,
    provider: String
  ) {
    self.token = token
    self.provider = provider
  }
}
