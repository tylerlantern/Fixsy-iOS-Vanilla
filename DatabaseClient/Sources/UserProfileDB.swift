import Combine
import Foundation
import UserProfileModel

public struct UserProfileDB {

	public init(
		observeUserProfile: @escaping () -> AsyncStream<UserProfile?>,
		saveUserProfile: @escaping (UserProfile) -> Void,
		updateName: @escaping (String, String) -> Void,
		clearUserProfile: @escaping () async throws -> Int) {
		self.observeUserProfile = observeUserProfile
		self.saveUserProfile = saveUserProfile
		self.updateName = updateName
		self.clearUserProfile = clearUserProfile
	}
	
  public var observeUserProfile: () -> AsyncStream<UserProfile?>
  public var saveUserProfile: (UserProfile) async throws -> ()
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
