import ProjectDescription

extension Product {
  public static var type: Product {
    if case let .string(linking) = Environment.linking, linking == "static" {
      .staticFramework
    } else {
      .framework
    }
  }
}

public enum ProductKind {
  case framework
  case unitTests(of: String)

  public var product: Product {
    switch self {
    case .framework:
      .type
    case .unitTests:
      .unitTests
    }
  }
}
