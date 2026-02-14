import APIClient
import AuthProvidersClient
import os
import SwiftUI

extension SocialSignInView {
  func handleOnTap(
    tap: SocialButtonTap
  ) {
    Task {
      let result = try await(
        tap == .apple
          ? self.authProvidersClient.appleAuth.signIn()
          : self.authProvidersClient.googleAuth.signIn()
      )
			
      guard case let .success(socialAccount) = result else {
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
      } catch {
        if let apiError = error as? APIError,
           case let .data(code, _) = apiError
        {
          if code == 601 {
            // TODO: Go to identity confirmation
            return
          }
          banners.show(.error, title: apiError.title, body: apiError.body)
          return
        }
        return
      }
      // Fetch user Profile and saved to local database.
      var user: UserProfileResponse
      do {
        user = try await self.apiClient.call(
          route: .userProfile, as: UserProfileResponse.self
        )
        try await self.databaseClient.userProfileDB.saveUserProfile(
          .init(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            pictureURL: user.pictureUrl,
            point: user.point
          )
        )
        banners.show(.success, String(localized: "Successfully login."))
        self.dismiss()
      } catch {
        if let apiError = error as? APIError {
          banners.show(.error, title: apiError.title, body: apiError.body)
          return
        }
        banners.show(
          .error,
          title: String(localized: "Something went wrong."),
          body: error.localizedDescription
        )
        return
      }
    }
  }
}
