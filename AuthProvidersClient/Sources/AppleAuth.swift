import Foundation

public struct AppleAuth{
  public init(signIn: @escaping () async -> Result<SocialAccount, SocialSignInError>) {
    self.signIn = signIn
  }

  public var signIn: () async -> Result<SocialAccount, SocialSignInError>
}
