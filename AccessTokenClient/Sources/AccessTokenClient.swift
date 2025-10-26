import Foundation
import SwiftUI
import TokenModel

public struct AccessTokenClient: Sendable {
  public var initialize: @Sendable () async throws -> Token?
  public var accessToken: @Sendable () async throws -> Token?
  public var updateAccessToken: @Sendable (Token?) async throws -> Token?

  public init(
    initialize: @escaping @Sendable () async throws -> Token?,
    accessToken: @escaping @Sendable () async throws -> Token?,
    updateAccessToken: @escaping @Sendable (Token?) async throws -> Token?
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
