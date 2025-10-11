import Foundation
import UserProfileModel

public struct UserProfileDB {
  public init(
    observeUserProfile: @escaping () -> AsyncThrowingStream<UserProfile?, Error>,
    saveUserProfile: @escaping @Sendable (UserProfile) async throws -> (),
    updateName: @escaping (String, String) async throws -> (),
    clearUserProfile: @escaping () async throws -> Int
  ) {
    self.observeUserProfile = observeUserProfile
    self.saveUserProfile = saveUserProfile
    self.updateName = updateName
    self.clearUserProfile = clearUserProfile
  }

  public var observeUserProfile: () -> AsyncThrowingStream<UserProfile?, Error>
  public var saveUserProfile: @Sendable (UserProfile) async throws -> ()
  public var updateName: (String, String) async throws -> ()
  public var clearUserProfile: () async throws -> Int
}

public extension UserProfileDB {
  static var test: UserProfileDB {
    .init(
      observeUserProfile: { fatalError("\(Self.self).observeUserProfile is unimplemented") },
      saveUserProfile: { _ in fatalError("\(Self.self).saveUserProfile is unimplemented") },
      updateName: { _, _ in fatalError("\(Self.self).updateName is unimplemented") },
      clearUserProfile: { fatalError("\(Self.self).clearUserProfile is unimplemented") }
    )
  }
}
