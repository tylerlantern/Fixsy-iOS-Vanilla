import Foundation

public struct Token: Codable, Equatable, Sendable {
  public let accessToken: String
	public let refreshToken : String
  public init(
		accessToken: String,
		refreshToken : String
	) {
    self.accessToken = accessToken
		self.refreshToken = refreshToken
  }
}

extension Token {
  public static let defaultValue = Token(
    accessToken: "acccessToken",
		refreshToken: "refreshToken"
  )
}

#if DEBUG
  extension Token {
    public static let testValue = Token(
      accessToken: "acccessToken",
			refreshToken: "refreshToken"
    )
  }
#endif
