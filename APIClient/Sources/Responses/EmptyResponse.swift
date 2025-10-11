import Foundation

public struct EmptyResponse: Codable, Equatable {
  public init() {}

  public init(from decoder: Decoder) throws {}
}
