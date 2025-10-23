import AuthProvidersClient

extension AuthProvidersClient {	
	@MainActor
	static func live( googleOAuthClientId : String ) -> Self {
		return AuthProvidersClient.init(
			googleAuth: .live(googleOAuthClientId: googleOAuthClientId),
			appleAuth: .live
		)
	}
	
}
