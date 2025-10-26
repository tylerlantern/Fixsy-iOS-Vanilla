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
        self.display = .render(user)
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
      } catch {
        if let apiError = error as? APIError {
          self.banners.show(.error, title: apiError.title, body: apiError.body)
          return
        }
        self.banners.show(
          .error,
          title: String(localized: "Something went wrong."),
          body: error.localizedDescription
        )
      }
    }
  }

  func deleteAccount() {
    self.isSubmitting = true
    Task {
      do {
      } catch {}
    }
  }

  func cancelTasks() {
    self.observeTask?.cancel()
    self.fetchTask?.cancel()
  }
}
