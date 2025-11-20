import Combine
import Foundation
import Models

public struct ReviewDB {
  public var observe: @Sendable (Int) -> AsyncThrowingStream<[ReviewItem], Error>
	public var sync: (Int, [ReviewItem], Int) async throws -> Int
  public var syncItemsByBranchId: (Int, [ReviewItem]) async throws -> ()
  public var update: (Int, ReviewItem) async throws -> Int
  public var clearByBranchId: @Sendable (Int) async throws -> ()
  public init(
    observe: @escaping @Sendable (Int) -> AsyncThrowingStream<[ReviewItem], Error>,
    sync: @escaping @Sendable (Int, [ReviewItem], Int) async throws -> Int,
    syncItemsByBranchId: @escaping @Sendable (Int, [ReviewItem]) async throws -> (),
    update: @escaping @Sendable (Int, ReviewItem) async throws -> Int,
    clearByBranchId: @escaping @Sendable (Int) async throws -> ()
  ) {
    self.observe = observe
    self.sync = sync
    self.syncItemsByBranchId = syncItemsByBranchId
    self.update = update
    self.clearByBranchId = clearByBranchId
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
      syncItemsByBranchId: { _, _ in
        fatalError("\(Self.self).update")
      },
      update: { _, _ in
        fatalError("\(Self.self).update")
      }
    ) { _ in
      fatalError("\(Self.self).clearByBranchId")
    }
  }
}
