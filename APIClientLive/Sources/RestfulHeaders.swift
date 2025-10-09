import Foundation
import Prelude

public struct EmptyRequest: Codable {
  public static func isEmpty(_ request: Any) -> Bool {
    request is EmptyRequest
  }
}

public enum HttpMethod<Body> {
  case get
  case post(Body)
  case put(Body)
  case patch(Body)
  case delete(Body)
}

extension HttpMethod {
  var httpMethod: String {
    switch self {
    case .get: return "GET"
    case .post: return "POST"
    case .put: return "PUT"
    case .patch: return "PATCH"
    case .delete: return "DELETE"
    }
  }

  func data<B>(_ fn: (Body) -> B?) -> B? {
    switch self {
    case .get:
      return nil
    case let .put(body), let .post(body), let .patch(body), let .delete(body):
      return (
        body
          |> { (body: Body) -> Body? in
            body is EmptyRequest ? .none : .some(body)
          }
      ).flatMap(fn)
    }
  }
}

public enum HttpHeaderName: Hashable {
  case authorization
  case contentType
}

public enum ContentType {
  case json

  public var value: String {
    switch self {
    case .json: return "application/json"
    }
  }
}

public extension HttpHeaderName {
  var header: String {
    switch self {
    case .authorization: return "Authorization"
    case .contentType: return "Content-Type"
    }
  }
}

public typealias HttpHeaders = [HttpHeaderName: String]

public struct RestfulHeaders {
  public var publicHeaders: () -> (HttpHeaders) = {
    [.contentType: ContentType.json.value]
  }

  public var privateHeaders: (String) -> (HttpHeaders) = { token in
    [
      .contentType: ContentType.json.value,
      .authorization: "Bearer \(token)"
    ]
  }

  public init() {}
}
