import Combine
import Foundation

public struct Request {
  public let urlRequest: URLRequest
}

public extension Request {
  init(get url: URL, headers: HttpHeaders = .init()) {
    var urlRequest = URLRequest(url: url)
    headers.forEach { field in
      urlRequest.addValue(field.value, forHTTPHeaderField: field.key.header)
    }
    self.urlRequest = urlRequest
  }

//  init<Body: Encodable>(
//    post url: URL,
//    method: HttpMethod<Body>,
//    headers: HttpHeaders = .init()
//  ) {
//    var urlRequest = URLRequest(url: url)
//    urlRequest.httpMethod = method.httpMethod
//    // swiftlint:disable:next force_try
//    urlRequest.httpBody = method.data { body in try! JSONEncoder().encode(body) }
//    headers.forEach { field in
//      urlRequest.addValue(field.value, forHTTPHeaderField: field.key.header)
//    }
//
//    self.urlRequest = urlRequest
//  }

  init(
    upload url: URL,
    multipartForm: MultipartFormData,
    headers: HttpHeaders = .init()
  ) {
    var urlRequest = URLRequest(url: url)
    headers.forEach { field in
      urlRequest.addValue(field.value, forHTTPHeaderField: field.key.header)
    }
    urlRequest.httpMethod = "POST"
    urlRequest.setValue(
      multipartForm.headerValue,
      forHTTPHeaderField: multipartForm.headerFeild
    )

    urlRequest.httpBody = multipartForm.data
    self.urlRequest = urlRequest
  }
}
