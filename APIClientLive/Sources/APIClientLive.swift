import AccessTokenClient
import AccessTokenClientLive
import APIClient
import Combine
import Foundation
import TokenModel

public extension APIClient {
  static func live(
    url: URL,
    accessTokenClient: AccessTokenClient
  ) -> Self {
    Self(
      request: { route in try await anonymousRequest(url: url, route: route) },
      userRequest: { route in
        let token = try await accessTokenClient.accessToken()
        guard let token = token else {
          throw URLError(
            URLError.Code(rawValue: 901),
            userInfo: ["message": "token access is not available"]
          )
        }
        return try await apiUserRequest(
          url,
          token,
          route,
          accessTokenClient.updateAccessToken,
          blockBeforeRefetchRequest
        )
      }
    )
  }
}

public var blockBeforeRefetchRequest: (() async -> ())?

public func anonymousRequest(url: URL, route: APIRoute)
  async throws -> (Data, URLResponse)
{
  let (data, response) = try await URLSession
    .shared
    .data(for: route.urlRequest(url: url))
  return (data, response)
}

public var userRequest: (
  Token,
  APIUserRoute,
  URL
) async throws -> (Data, URLResponse) = { token, userRoute, url in
  let (data, response) = try await URLSession
    .shared
    .data(for: userRoute.urlRequest(url: url, token: token))
  return (data, response)
}

public var apiUserRequest: (
  URL,
  Token,
  APIUserRoute,
  @escaping @Sendable (Token?) async throws -> Token?,
  (() async -> ())?
) async throws
  -> (data: Data, response: URLResponse) = { url, currentToken, route, tokenUpdated, block in
    let (data, response) = try await userRequest(
      currentToken,
      route,
      url
    )
    if (response as? HTTPURLResponse)?.statusCode == 401 {
      let (data, response) = try await refreshTokenRequest(url, currentToken)
      let statusCode = (response as! HTTPURLResponse).statusCode
      switch statusCode {
      case 200:
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
				let newToken = Token(
					accessToken: tokenResponse.accessToken,
					refreshToken: tokenResponse.refreshToken
				)
        await block?()
        return try await refetchRequest(url, newToken, route, tokenUpdated)
      case 401:
        _ = try await tokenUpdated(nil)
        return (data, response)
      default:
        return (data, response)
      }
    }
    return (data, response)
  }

public var refetchRequest: (
  URL,
  Token,
  APIUserRoute,
  @escaping @Sendable (Token?) async throws -> Token?
) async throws -> (data: Data, response: URLResponse) = { url, refreshToken, route, tokenUpdating in
  _ = try await tokenUpdating(refreshToken)
  let (data, response) = try await userRequest(
    refreshToken,
    route,
    url
  )
  return (data, response)
}

public var refreshTokenRequest: (URL, Token) async throws -> (Data, URLResponse) = { url, token in
  try await anonymousRequest(
		url: url,
		route: APIRoute.refreshToken(
			accessToken: token.accessToken, refreshToken: token.refreshToken
		)
	)
}
