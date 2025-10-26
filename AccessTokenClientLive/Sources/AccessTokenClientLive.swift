import AccessTokenClient
import Foundation
import KeychainAccess
import os
import Synchronization
import TokenModel

let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!,
  category: String(describing: AccessTokenClient.self)
)

public extension AccessTokenClient {
  static func live(
    accessGroup: String,
    service: String,
  ) -> Self {
    let accessTokenStore = AccessTokenStore(
      accessGroup: accessGroup,
      service: service
    )
    return AccessTokenClient(
      initialize: { @MainActor in
        try await accessTokenStore.initialize()
      },
      accessToken: { @MainActor in
        try await accessTokenStore.getAuthCredential()
      },
      updateAccessToken: { @MainActor token in
        try await accessTokenStore.updateToken(token: token)
      }
    )
  }
}

public actor AccessTokenStore {
  private let accessTokenKey: String
  private let refreshTokenKey: String

  let keychain: Keychain
  public init(
    accessGroup: String,
    service: String
  ) {
    self.accessTokenKey = "\(service).accessToken"
    self.refreshTokenKey = "\(service).refreshToken"
    self.keychain = Keychain(
      service: service,
      accessGroup: accessGroup
    )
    .accessibility(.afterFirstUnlock)
  }

  public func initialize() throws -> Token? {
    try self.getAuthCredential()
  }

  public func getAuthCredential() throws -> Token? {
    guard
      let accessToken = try self.keychain.get(self.accessTokenKey),
      let refreshToken = try self.keychain.get(self.refreshTokenKey)
    else {
      return nil
    }
    return Token(
      accessToken: accessToken,
      refreshToken: refreshToken
    )
  }

  @discardableResult
  func updateToken(token: Token?) throws -> Token? {
    if let token {
      try self.keychain.set(token.accessToken, key: self.accessTokenKey)
      try self.keychain.set(token.refreshToken, key: self.refreshTokenKey)
    } else {
      try self.keychain.remove(self.accessTokenKey)
      try self.keychain.remove(self.refreshTokenKey)
    }
    return token
  }
}
