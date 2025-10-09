import Combine
import Foundation

public struct ReviewDB {
  public var observe: (Int) -> AnyPublisher<[ReviewItem], DBError>
  public var sync: (Int, [ReviewItem], Int) async throws -> Int
  public var update: (Int, ReviewItem) async throws -> Int

  public init(
    observe: @escaping (Int) -> AnyPublisher<[ReviewItem], DBError>,
    sync: @escaping (Int, [ReviewItem], Int) async throws -> Int,
    update: @escaping (Int, ReviewItem) async throws -> Int
  ) {
    self.observe = observe
    self.sync = sync
    self.update = update
  }
}

public extension ReviewDB {
  static var test: ReviewDB {
    .init(
      observe: { _ in
        fatalError("\(Self.self).observe")
      },
      sync: { _, _, _ in
        fatalError("\(Self.self).sync")
      },
      update: { _, _ in
        fatalError("\(Self.self).update")
      }
    )
  }
}
