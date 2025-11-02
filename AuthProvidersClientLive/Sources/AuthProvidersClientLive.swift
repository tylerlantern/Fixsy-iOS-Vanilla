import AuthProvidersClient

public extension AuthProvidersClient {
  @MainActor
  static func live(googleOAuthClientId: String) -> Self {
    AuthProvidersClient(
      googleAuth: .live(googleOAuthClientId: googleOAuthClientId),
      appleAuth: .live
    )
  }
}
