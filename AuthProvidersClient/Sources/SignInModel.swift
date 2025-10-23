import Foundation

public enum SocialSignInError: Error, Equatable {
  case accountInvalid
  case cancelFlow
  case noViewController
  case error(Error)

  public static func == (lhs: SocialSignInError, rhs: SocialSignInError) -> Bool {
    switch (lhs, rhs) {
    case (.accountInvalid, .accountInvalid):
      return true
    case (.cancelFlow, .cancelFlow):
      return true
    case (.noViewController, .noViewController):
      return true
    case let (.error(error1), .error(error2)):
      return "\(error1)" == "\(error2)"
    default:
      return false
    }
  }

  public var localizedDescription: String {
    switch self {
    case .accountInvalid:
      return "Invalid Account"
    case .cancelFlow:
      return "You have cancel the process"
    case .noViewController:
      return "No ViewController"
    case let .error(error):
      return error.localizedDescription
    }
  }
}

public struct SocialAccountInvalidError: Error {
  public init() {}
}

public struct SocialAccountCancelFlowError: Error {
  public init() {}
}
