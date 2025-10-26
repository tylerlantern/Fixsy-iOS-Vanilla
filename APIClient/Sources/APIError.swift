import Foundation

public enum APIError: Equatable, Error {
  case data(Int, APIErrorData?)
  case parse(Error)

  public static func == (lhs: APIError, rhs: APIError) -> Bool {
    switch (lhs, rhs) {
    case let (.data(code1, data1), .data(code2, data2)):
      return code1 == code2 && data1 == data2
    case let (.parse(error1), .parse(error2)):
      return "\(error1)" == "\(error2)"
    default:
      return false
    }
  }
}

public extension APIError {
  var localizedDescription: String {
    switch self {
    case let .data(code, data):
      return "APIError code \(code) \(data.debugDescription)"
    case let .parse(error):
      return error.localizedDescription
    }
  }

  var title: String {
    switch self {
    case let .data(code, _):
      return Self.title(for: code)
    case .parse:
      return String(localized: "Something went wrong.")
    }
  }

  var body: String {
    switch self {
    case let .data(_, data):
      return Self.bestMessage(from: data)
    case let .parse(error):
      return error.localizedDescription
    }
  }
}

public struct APIErrorData: Codable, Equatable {
  public let status: Int
  public let message: String?
  public let details: APIErrorDataDetail?

  public init(
    status: Int,
    message: String,
    details: APIErrorDataDetail?
  ) {
    self.status = status
    self.message = message
    self.details = details
  }
}

public struct APIErrorDataDetail: Codable, Equatable {
  public let code: Int
  public let message: String
}

private extension APIError {
  static func title(for code: Int) -> String {
    switch code {
    case 400: return "Bad Request"
    case 401: return "Unauthorized"
    case 403: return "Forbidden"
    case 404: return "Not Found"
    case 408: return "Request Timeout"
    case 409: return "Conflict"
    case 422: return "Unprocessable Entity"
    case 429: return "Too Many Requests"
    case 500: return "Server Error"
    case 501: return "Not Implemented"
    case 502: return "Bad Gateway"
    case 503: return "Service Unavailable"
    case 504: return "Gateway Timeout"
    case 400 ..< 500: return "Client Error (\(code))"
    case 500 ..< 600: return "Server Error (\(code))"
    default: return "API Error (\(code))"
    }
  }

  static func bestMessage(from data: APIErrorData?) -> String {
    let candidates: [String?] = [
      data?.details?.message,
      data?.message
    ]
    let trimmed = candidates
      .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
      .first { !$0.isEmpty }

    return trimmed ?? "Unexpected server response. Please try again."
  }
}
