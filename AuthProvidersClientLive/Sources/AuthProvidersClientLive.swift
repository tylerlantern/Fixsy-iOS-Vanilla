import AuthProvidersClient

public extension AuthProvidersClient {
	@MainActor
	static func live( googleOAuthClientId : String ) -> Self {
		print("INIT LIVE")
		return AuthProvidersClient(
			googleAuth: .live(googleOAuthClientId: googleOAuthClientId),
			appleAuth: .live
		)
	}
	
}
