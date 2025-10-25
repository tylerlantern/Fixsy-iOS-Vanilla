import Combine
import Foundation
import AuthProvidersClient
import UIKit
import GoogleSignIn

public extension GoogleAuth {
	
	@MainActor
	static func live(googleOAuthClientId: String) -> GoogleAuth {
		let gidSignIn = GIDSignIn.sharedInstance
		let gidConfiguration = GIDConfiguration(
			clientID: googleOAuthClientId
		)
		gidSignIn.configuration = gidConfiguration
		return Self(
			signIn: { @MainActor in
				let viewController = await MainActor.run {
					UIApplication.shared
						.connectedScenes
						.first(where: { $0 is UIWindowScene })
						.flatMap({ $0 as? UIWindowScene })?
						.windows
						.first(where: \.isKeyWindow)?
						.rootViewController
				}
				guard let viewController else {
					return Result.failure(SocialSignInError.noViewController)
				}
				let result: GIDSignInResult = try await GIDSignIn.sharedInstance
					.signIn(withPresenting: viewController)
				let user: GIDGoogleUser = try await result.user.refreshTokensIfNeeded()
				guard let idToken = user.idToken?.tokenString,
							let userId = user.userID
				else {
					return .failure(.accountInvalid)
				}
				return .success(
					SocialAccount(
						provider: .google,
						token: idToken,
						userId: userId,
						email: user.profile?.email,
						firstName: user.profile?.givenName,
						lastName: user.profile?.familyName,
						picture: user.profile?.imageURL(withDimension: 300)
					)
				)
			},
			handleURL: { gidSignIn.handle($0) },
			logout: { gidSignIn.signOut() }
		)
	}
}

private func isSignInCancelled(error: Error) -> Bool {
	(error as? GIDSignInError)?.code == .canceled
}
