import Foundation
import SwiftUI

private func _unimplemented(_ where_: StaticString = #function) -> Never {
  fatalError("\(where_) is unimplemented. Inject a real AuthProvidersClient before use.")
}

public struct AuthProvidersClient {
  public init(
    googleAuth: GoogleAuth,
    appleAuth: AppleAuth
  ) {
    self.googleAuth = googleAuth
    self.appleAuth = appleAuth
  }

  public var googleAuth: GoogleAuth
  public var appleAuth: AppleAuth
}

extension GoogleAuth {
  static let unimplemented = Self(
    signIn: { _unimplemented("AuthProvidersClient.GoogleAuth.signIn") },
    handleURL: { _ in _unimplemented("AuthProvidersClient.GoogleAuth.handleURL") },
    logout: { _unimplemented("AuthProvidersClient.GoogleAuth.logout") }
  )
}

extension AppleAuth {
  static let unimplemented = Self(
    signIn: { _unimplemented("AuthProvidersClient.AppleAuth.signIn") }
  )
}

// MARK: -

extension AuthProvidersClient: EnvironmentKey {
  public static var defaultValue: Self {
    .init(
      googleAuth: .unimplemented,
      appleAuth: .unimplemented
    )
  }
}

extension EnvironmentValues {
  public var authProvidersClient: AuthProvidersClient {
    get { self[AuthProvidersClient.self] }
    set { self[AuthProvidersClient.self] = newValue }
  }
}
