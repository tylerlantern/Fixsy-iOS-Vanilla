import Foundation
import UIKit

public struct GoogleAuth {
  public var signIn: @Sendable () async throws -> Result<SocialAccount, SocialSignInError>
  public var handleURL: (URL) -> ()
  public var logout: () -> ()
  public init(
    signIn: @escaping @Sendable () async throws -> Result<SocialAccount, SocialSignInError>,
    handleURL: @escaping (URL) -> (),
    logout: @escaping () -> ()
  ) {
    self.signIn = signIn
    self.handleURL = handleURL
    self.logout = logout
  }
}
