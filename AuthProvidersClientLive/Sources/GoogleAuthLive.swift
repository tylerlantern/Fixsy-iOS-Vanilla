import Combine
import Configs
import Foundation
import AuthProvidersClient
import UIKit
import GoogleSignIn

public extension GoogleAuth {
	static func live(googleOAuthClientId: String) -> GoogleAuth {
		let gidSignIn = GIDSignIn.sharedInstance
		let gidConfiguration = GIDConfiguration(
			clientID: googleOAuthClientId
		)
		gidSignIn.configuration = gidConfiguration
		return Self(
			signIn: {
				guard let viewController = await UIApplication.shared.windows.first?.rootViewController
				else {
					return Result.failure(SocialSignInError.noViewController)
				}
				return await withCheckedContinuation { continuation in
					gidSignIn.signIn(withPresenting: viewController) { (
						result: GIDSignInResult?,
						error: Error?
					) in
						if let error = error {
							let socialSigninError: SocialSignInError = isSignInCancelled(error: error)
							? .cancelFlow
							: .error(error as NSError)
							continuation.resume(returning: .failure(socialSigninError))
							return
						}
						guard let user = result?.user else {
							return
						}
						let image: URL? = (user.profile?.hasImage ?? false)
						? user.profile?.imageURL(withDimension: 100)
						: nil
						guard let idToken = user.idToken?.tokenString,
									let userId = user.userID else {
							continuation.resume(returning: .failure(.accountInvalid))
							return
						}
						let account = 	SocialAccount(
							provider: .google,
							token: idToken,
							userId: userId,
							email: user.profile?.email,
							firstName: user.profile?.givenName,
							lastName: user.profile?.familyName,
							picture: user.profile?.imageURL(withDimension: 300)
						)
						continuation.resume(returning: .success(account))
					}
				}
				
			},
			handleURL: { gidSignIn.handle($0) },
			logout: { gidSignIn.signOut() }
		)
	}
}

private func isSignInCancelled(error: Error) -> Bool {
	(error as? GIDSignInError)?.code == .canceled
}
