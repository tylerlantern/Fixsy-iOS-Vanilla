import Combine
import Foundation
import Models

public struct CarBrandDB {
  public var observe: () -> AsyncThrowingStream<[CarBrand], Error>
  public var sync: ([CarBrand]) async throws -> ()

  public init(
    observe: @escaping () -> AsyncThrowingStream<[CarBrand], Error>,
    sync: @escaping ([CarBrand]) async throws -> ()
  ) {
    self.observe = observe
    self.sync = sync
  }
}

public extension CarBrandDB {
  static var test: CarBrandDB {
    .init(observe: { fatalError("\(Self.self).observe is unimplemented") }) { _ in
      fatalError("\(Self.self).sync is unimplemented")
    }
  }
}
