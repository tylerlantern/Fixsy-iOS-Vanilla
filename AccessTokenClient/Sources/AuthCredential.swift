import Foundation

public struct AuthCredential: Codable, Equatable, Sendable {
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

extension AuthCredential {
  public static let defaultValue = AuthCredential(
    accessToken: "acccessToken",
		refreshToken: "refreshToken"
  )
}

#if DEBUG
  extension AuthCredential {
    public static let testValue = AuthCredential(
      accessToken: "acccessToken",
			refreshToken: "refreshToken"
    )
  }
#endif
