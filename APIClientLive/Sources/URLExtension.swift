import Foundation

extension URL {
  func appendingQuery(_ query: URLQueryItem) -> URL {
    self.appendingQueries([query])
  }

  func appendingQueries(_ queries: [URLQueryItem]) -> URL {
    guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)
    else { return self }

    var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
    for query in queries {
      queryItems.append(query)
    }
    urlComponents.queryItems = queryItems
    if let url = urlComponents.url {
      return url
    }
    return self
  }
}
