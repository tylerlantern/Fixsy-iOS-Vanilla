import Foundation
import UIKit

public struct GoogleAuth {
  public var signIn: () async -> Result<SocialAccount, SocialSignInError>
  public var handleURL: (URL) -> ()
  public var logout: () -> ()
  public init(
    signIn: @escaping () async -> Result<SocialAccount, SocialSignInError>,
    handleURL: @escaping (URL) -> (),
    logout: @escaping () -> ()
  ) {
    self.signIn = signIn
    self.handleURL = handleURL
    self.logout = logout
  }
}
