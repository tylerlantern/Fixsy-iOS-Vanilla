import Foundation

public struct SocialAccount: Equatable {
  public enum Provider: String, Equatable {
    case google
    case apple
  }

  public init(
    provider: Provider,
    token: String,
    userId: String,
    email: String?,
    firstName: String?,
    lastName: String?,
    picture: URL?
  ) {
    self.provider = provider
    self.token = token
    self.userId = userId
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.picture = picture
  }

  public let provider: Provider
  public let token: String
  public let userId: String
  public let email: String?
  public let firstName: String?
  public let lastName: String?
  public let picture: URL?
}

public enum ProviderSignInError: Error, Equatable {
  case missingUsername(
    provider: SocialAccount.Provider,
    token: String,
    userId: String,
    firstName: String,
    lastName: String
  )
  case something
}

public func isValidEmail(email: String) -> Bool {
  // Regular expression for email validation
  let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
  let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
  return emailPredicate.evaluate(with: email)
}
