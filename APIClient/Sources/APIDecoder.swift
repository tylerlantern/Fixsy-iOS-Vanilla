import Combine
import Foundation

public extension JSONDecoder {
  static let apiDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()
}
