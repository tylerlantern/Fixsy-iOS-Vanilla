import APIClient
import SwiftUI
import UserProfileModel

extension UserProfileView {
  func initialize() {
    self.observeTask = Task {
      for try await user in self.databaseClient.userProfileDB.observeUserProfile() {
        guard let user = user else {
          continue
        }
        let preferredLocalization = Bundle.main.preferredLocalizations.first
        self.display = .render(
          user,
          preferredLocalization.map(getNativeLanguageNameText)
            ?? String(
              localized: "Unknown",
              bundle: .module
            )
        )
      }
    }
    self.fetchTask = Task {
      do {
        let response = try await self.apiClient.call(
          route: .userProfile,
          as: UserProfileResponse.self
        )
        try await self.databaseClient.userProfileDB.saveUserProfile(
          UserProfile(
            id: response.id,
            email: response.email,
            firstName: response.firstName,
            lastName: response.lastName,
            pictureURL: response.pictureUrl,
            point: response.point
          )
        )
      } catch is CancellationError {}
      catch {
        if let apiError = error as? APIError {
          self.banners.show(.error, title: apiError.title, body: apiError.body)
          return
        }
        self.banners.show(
          .error,
          title: String(
            localized: "Something went wrong.",
            bundle: .module
          ),
          body: error.localizedDescription
        )
      }
    }
  }

  func processSubmit(_ action: SubmitAction) {
    self.isSubmitting = true
    Task {
      do {
        _ = action == .logout
          ? try await self.apiClient.call(route: .logout, as: EmptyResponse.self)
          : try await self.apiClient.call(route: .delete, as: EmptyResponse.self)
        _ = try await self.accessTokenClient.updateAccessToken(nil)
        _ = try await self.databaseClient.userProfileDB.clearUserProfile()
        self.authProvidersClient.googleAuth.logout()
        self.dismiss()
      } catch {
        self.isSubmitting = false
        if let apiError = error as? APIError {
          self.banners.show(.error, title: apiError.title, body: apiError.body)
          return
        }
        self.banners.show(
          .error,
          title: String(
            localized: "Something went wrong.",
            bundle: .module
          ),
          body: error.localizedDescription
        )
      }
    }
  }

  func cancelTasks() {
    self.observeTask?.cancel()
    self.fetchTask?.cancel()
  }
}

func getNativeLanguageNameText(localization: String) -> String {
  if localization.hasPrefix("en") {
    return "English"
  } else if localization.hasPrefix("th") {
    return "ไทย"
  } else {
    return "English"
  }
}
