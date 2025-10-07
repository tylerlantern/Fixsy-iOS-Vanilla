import Foundation

public enum Service: String, Equatable, CaseIterable, Identifiable {
  public var id: String { self.rawValue }

  case
    car,
    motorcycle,
    inflatingPoint,
    wash,
    patchTire
}
