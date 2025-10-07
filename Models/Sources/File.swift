import Foundation

public struct IdentifiableURL: Identifiable, Equatable {
  public let id: URL

  public init(id: URL) {
    self.id = id
  }
}
