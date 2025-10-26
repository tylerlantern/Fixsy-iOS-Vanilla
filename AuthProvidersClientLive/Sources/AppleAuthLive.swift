import AuthenticationServices
import AuthProvidersClient
import Combine
import Foundation
import SwiftUI

extension AppleAuth {
  @MainActor
  public static var live: AppleAuth {
    let delegate = AppleSignInDelegate()
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    let authorizationController =
      ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = delegate
    return Self(
      signIn: {
        await withCheckedContinuation { continuation in
          delegate.onAuthorized = { socialAccount in
            continuation.resume(returning: .success(socialAccount))
          }
          delegate.onError = { error in
            continuation.resume(returning: .failure(error))
          }
          authorizationController.performRequests()
        }
      }
    )
  }
}

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
  var onAuthorized: ((SocialAccount) -> ())?
  var onError: ((SocialSignInError) -> ())?

  func authorizationAppleID() {}

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard
      let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
      let clientSecret = credentials.identityToken.flatMap({ String(data: $0, encoding: .utf8) })
    else {
      self.onError?(.accountInvalid)
      return
    }

    let token = clientSecret
    let userId = credentials.user
    self.onAuthorized?(
      SocialAccount(
        provider: .apple,
        token: token,
        userId: userId,
        email: credentials.email ?? decodeRelayEmail(clientSecret: clientSecret),
        firstName: credentials.fullName?.givenName,
        lastName: credentials.fullName?.familyName,
        picture: nil
      )
    )
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    self.onError?(
      isSignInCancelled(error: error)
        ? .cancelFlow
        : .error(error as NSError)
    )
  }
}

private func isSignInCancelled(error: Error) -> Bool {
  let code = (error as NSError).code
  return [ASAuthorizationError.unknown, ASAuthorizationError.canceled]
    .map(\.rawValue)
    .contains(code)
}

private func decodeRelayEmail(clientSecret: String) -> String? {
  decode(jwtToken: clientSecret)["email"]
    .flatMap { $0 as? String }
}

private func decode(jwtToken jwt: String) -> [String: Any] {
  let segments = jwt.components(separatedBy: ".")
  return decodeJWTPart(segments[1]) ?? [:]
}

private func base64UrlDecode(_ value: String) -> Data? {
  var base64 = value
    .replacingOccurrences(of: "-", with: "+")
    .replacingOccurrences(of: "_", with: "/")

  let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
  let requiredLength = 4 * ceil(length / 4.0)
  let paddingLength = requiredLength - length
  if paddingLength > 0 {
    let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
    base64 = base64 + padding
  }
  return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
}

func decodeJWTPart(_ value: String) -> [String: Any]? {
  guard let bodyData = base64UrlDecode(value),
        let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
        let payload = json as? [String: Any]
  else {
    return nil
  }

  return payload
}
