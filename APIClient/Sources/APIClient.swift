import SwiftUI
import Foundation

public struct APIClient {
  public var request: (APIRoute) async throws -> (data: Data, response: URLResponse)
  public var userRequest: (
    APIUserRoute
  ) async throws -> (data: Data, response: URLResponse)
  public init(
    request: @escaping (APIRoute) async throws -> (data: Data, response: URLResponse),
    userRequest: @escaping (
      APIUserRoute
    ) async throws -> (data: Data, response: URLResponse)
  ) {
    self.request = request
    self.userRequest = userRequest
  }

  public func call<A: Decodable>(
    route: APIUserRoute,
    as: A.Type,
		decoder: JSONDecoder = JSONDecoder.init(),
    file: StaticString = #file,
    line: UInt = #line
  ) async throws -> A {
    let (data, response) = try await self.userRequest(route)
    let statusCode = (response as! HTTPURLResponse).statusCode
    switch statusCode {
    case 200 ..< 300:
      return try decoder.decode(
        A.self,
        from: data.isEmpty
          ? "{}".data(using: .utf8)!
          : data
      )
    default:
      throw self.handleAPIError(
        decoder: decoder,
        statusCode: statusCode,
        data: data
      )
    }
  }

  public func call<A: Decodable>(
    route: APIRoute,
    as: A.Type,
    decoder: JSONDecoder = JSONDecoder.apiDecoder,
    file: StaticString = #file,
    line: UInt = #line
  ) async throws -> A {
    let (data, response) = try await self.request(route)
    let statusCode = (response as! HTTPURLResponse).statusCode
    switch statusCode {
    case 200 ..< 300:
      return try decoder.decode(
        A.self,
        from: data.isEmpty
          ? "{}".data(using: .utf8)!
          : data
      )
    default:
      throw self.handleAPIError(
        decoder: decoder,
        statusCode: statusCode,
        data: data
      )
    }
  }

  private func handleAPIError(decoder: JSONDecoder, statusCode: Int, data: Data) -> APIError {
    // MARK: - After Confirm New Error Parser Model `APIErrorData`
    let message = String(decoding: data, as: UTF8.self)
    return .data(
      statusCode,
      APIErrorData(
        status: statusCode,
        message: message,
        details: nil
      )
    )
  }
}

extension APIClient: EnvironmentKey {
	public static let defaultValue: APIClient = .init { route in
		fatalError("\(Self.self).request is unimplemented")
	} userRequest: { _ in
		fatalError("\(Self.self).userRequest is unimplemented")
	}

}

extension EnvironmentValues {
	public var apiClient: APIClient {
		get { self[APIClient.self] }
		set { self[APIClient.self] = newValue }
	}
}

public extension APIClient {
  mutating func override(
    route matchingRoute: APIRoute,
    withResponse: @escaping () -> (data: Data, response: URLResponse)
  ) throws {
    self.request = { [request] route in
      if route == matchingRoute {
        return withResponse()
      } else {
        return try await request(route)
      }
    }
  }

  mutating func override(
    route matchingRoute: APIUserRoute,
    withResponse: @escaping () -> (data: Data, response: URLResponse)
  ) {
    self.userRequest = { [userRequest] route in
      if route == matchingRoute {
        return withResponse()
      } else {
        return try await userRequest(route)
      }
    }
  }
}
