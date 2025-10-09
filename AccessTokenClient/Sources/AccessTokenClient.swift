import Foundation
import SwiftUI

public struct AccessTokenClient: Sendable {
  public var initialize: @Sendable () async throws -> AuthCredential?
  public var accessToken: @Sendable () async throws -> AuthCredential?
  public var updateAccessToken: @Sendable (AuthCredential?) async throws -> AuthCredential?

  public init(
    initialize: @escaping @Sendable () async throws -> AuthCredential?,
    accessToken: @escaping @Sendable () async throws -> AuthCredential?,
    updateAccessToken: @escaping @Sendable (AuthCredential?) async throws -> AuthCredential?
  ) {
    self.initialize = initialize
    self.accessToken = accessToken
    self.updateAccessToken = updateAccessToken
  }
}

extension AccessTokenClient: EnvironmentKey {
  public static var defaultValue: Self {
    AccessTokenClient(
      initialize: { .defaultValue },
      accessToken: { nil },
      updateAccessToken: { _ in .defaultValue }
    )
  }
}

#if DEBUG
  extension AccessTokenClient {
    public static var testValue: Self {
      AccessTokenClient(
        initialize: { .testValue },
        accessToken: { nil },
        updateAccessToken: { _ in .testValue }
      )
    }

    public static var previewValue: Self {
      AccessTokenClient(
        initialize: { .testValue },
        accessToken: { nil },
        updateAccessToken: { _ in .testValue }
      )
    }
  }
#endif

extension EnvironmentValues {
  public var accessTokenClient: AccessTokenClient {
    get { self[AccessTokenClient.self] }
    set { self[AccessTokenClient.self] = newValue }
  }
}
