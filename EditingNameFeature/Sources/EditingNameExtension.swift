import APIClient
import DatabaseClient
import Foundation
import SwiftUI

extension EditingNameView {
  func submit() {
    self.submitTask?.cancel()
    self.isSubmiting = true
    self.submitTask = Task {
      do {
        _ = try await self.apiClient.call(
          route: .editName(firstName: self.firstName, lastName: self.lastName),
          as: EmptyResponse.self
        )
        try await self.databaseClient.userProfileDB.updateName(
          self.firstName,
          self.lastName
        )
        banners.show(.success, String(localized: "Success"))
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
        self.isSubmiting = false
      }
    }
  }
}
