import Combine
import Foundation
import Models

public struct CarBrandDB {
  public var observe: () -> AnyPublisher<Result<[CarBrand], DBError>, Never>
  public var sync: ([CarBrand]) -> Result<(), Error>

  public init(
    observe: @escaping () -> AnyPublisher<Result<[CarBrand], DBError>, Never>,
    sync: @escaping ([CarBrand]) -> Result<(), Error>
  ) {
    self.observe = observe
    self.sync = sync
  }
}

public extension CarBrandDB {
  static var test: CarBrandDB {
    .init(observe: { fatalError("\(Self.self).observe is unimplemented") }) { _ in
      .success(())
    }
  }
}
