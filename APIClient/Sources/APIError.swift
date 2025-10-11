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
