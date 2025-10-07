import Foundation

public struct Token: Codable, Sendable, Equatable {
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

#if DEBUG
  public extension Token {
    static let mock: Self = .init(
      accessToken: "mock",
      refreshToken: "mock-refresh"
    )
  }
#endif
