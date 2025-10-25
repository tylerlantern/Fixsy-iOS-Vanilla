import SwiftUI
import APIClient
import BannerToastComponent
import AuthProvidersClient
import os

extension SocialSignInView {
	
	func handleOnTap(
		tap : SocialButtonTap
	) {
		Task {
			let result = await (
				tap == .apple
				? self.authProvidersClient.appleAuth.signIn()
				: try self.authProvidersClient.googleAuth.signIn()
			)
			guard case let  .success(socialAccount) = result else {
				banners.show(.error, String(localized: "Provider Authentication failed."))
				return
			}
			do {
				let tokenRes = try await self.apiClient.call(
					route: .socialSignin(
						token: socialAccount.token,
						provider: socialAccount.provider.rawValue
					),
					as: TokenResponse.self
				)
				_ = try await self.accessTokenClient.updateAccessToken(
					.init(accessToken: tokenRes.accessToken, refreshToken: tokenRes.refreshToken)
				)
			}
			catch(let error) {
				if let apiError = error as? APIError,
					 case let .data(code, _) = apiError,
					 code == 601
				{
					//TODO: Go to identity confirmation
					return
				}
				banners.show(.error,  String(localized: "Something went wrong."))
				return;
			}
			//Fetch user Profile and saved to local database.
			var user : UserProfileResponse
			do {
				user =	try await self.apiClient.call(
					route: .userProfile, as: UserProfileResponse.self
				)
				try await self.databaseClient.userProfileDB.saveUserProfile(
					.init(id: user.id, email: user.email, firstName: user.firstName, lastName: user.lastName, pictureURL: user.pictureUrl, point: user.point)
				)
				banners.show(.success,  String(localized: "Successfully login."))
				self.dismiss()
			} catch(let error) {
				if let apiError = error as? APIError
				{
				
					banners.show(.error, apiError.localizedDescription)
					return
				}
				banners.show(.error,  String(localized: "Something went wrong."))
				return
			}
		}
		
	}
	
}

