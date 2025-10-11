import Foundation

public func OK<A: Encodable>(
  _ value: A, encoder: JSONEncoder = .init()
) throws -> (Data, URLResponse) {
  try (
    encoder.encode(value),
    HTTPURLResponse(
      url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil
    )!
  )
}

public func OK(_ jsonObject: Any) throws -> (Data, URLResponse) {
  try (
    JSONSerialization.data(withJSONObject: jsonObject, options: []),
    HTTPURLResponse(
      url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil
    )!
  )
}

public func response(
  statusCode: Int,
  headers: [String: String]? = nil,
  body data: Data = Data()
) -> (Data, URLResponse) {
  (
    data,
    HTTPURLResponse(
      url: URL(string: "/")!, statusCode: statusCode, httpVersion: nil, headerFields: headers
    )!
  )
}

public func ok(_ data: Data) -> (Data, URLResponse) {
  response(statusCode: 200, body: data)
}

public func unauthorized() -> (Data, URLResponse) {
  response(statusCode: 401, body: "".data(using: .utf8)!)
}
