import Foundation

public struct CarBrand: Equatable, Identifiable {
  public let id: Int
  public let displayName: String

  public init(id: Int, displayName: String) {
    self.id = id
    self.displayName = displayName
  }
}
