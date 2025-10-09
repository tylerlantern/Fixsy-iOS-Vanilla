import Configs
import Foundation

public enum RestfulConfigs {
  public static var urlSession = URLSession.create(
    timeoutIntervalForRequest: apiFetchTimeout,
    timeoutIntervalForResource: apiFetchTimeout
  )
}
