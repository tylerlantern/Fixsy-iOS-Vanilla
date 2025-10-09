import Foundation

public let apiFetchTimeout: TimeInterval = 20
public let longFetchTimeout: TimeInterval = 60

public extension URLSessionConfiguration {
  static func create(
    timeoutIntervalForRequest: TimeInterval = apiFetchTimeout,
    timeoutIntervalForResource: TimeInterval = apiFetchTimeout
  ) -> URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default

    if let networkProxyHost = ProcessInfo.processInfo.environment["NETWORK_PROXY_HOST"] {
      configuration.connectionProxyDictionary = [
        "HTTPSEnable": 1,
        "HTTPSProxy": networkProxyHost,
        "HTTPSPort": 8_080
      ]
    }
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    configuration.waitsForConnectivity = true
    configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
    configuration.timeoutIntervalForResource = timeoutIntervalForResource
    return configuration
  }
}

public extension URLSession {
  static func create(
    timeoutIntervalForRequest: TimeInterval = apiFetchTimeout,
    timeoutIntervalForResource: TimeInterval = apiFetchTimeout
  ) -> URLSession {
    URLSession.init(configuration: URLSessionConfiguration.create(
      timeoutIntervalForRequest: timeoutIntervalForRequest,
      timeoutIntervalForResource: timeoutIntervalForResource
    ))
  }
}
