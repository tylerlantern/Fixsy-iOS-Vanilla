import DatabaseClient
import GRDB
import Models

extension ReviewDB {
  static func live(cache: DatabaseWriter) -> ReviewDB {
    ReviewDB(
      observe: { placeId in
        AsyncThrowingStream { continuation in
          let cancellable = ValueObservation.tracking { db in
            try fetchReviewItems(db: db, placeId: placeId)
          }.start(
            in: cache,
            scheduling: .immediate,
            onError: { error in
              continuation.finish(throwing: error)
            },
            onChange: { items in
              continuation.yield(items)
            }
          )
          continuation.onTermination = { @Sendable _ in
            cancellable.cancel()
          }
        }
      },
      sync: { placeId, remoteItems, pageIndex in
        try await cache.write { db in
          if pageIndex == 0 {
            let localItems = try fetchReviewItems(db: db, placeId: placeId)
            let (removes, updates) = syncAllItems(
              localItems: localItems,
              remoteItems: remoteItems,
              isAscending: false,
              toComparable: { $0.createdDate }
            )
            let (numberOfUpdateItem, _) = try syncReviewItems(
              db: db,
              placeId: placeId,
              updates: updates,
              removes: removes
            )
            return numberOfUpdateItem
          } else {
            let (numberOfUpdateItem, _) = try syncReviewItems(
              db: db,
              placeId: placeId,
              updates: remoteItems,
              removes: []
            )
            return numberOfUpdateItem
          }
        }
      },
      syncItemsByBranchId: { placeId, items in
        _ = try await cache.write({ db in
          try items.forEach { item in
            let record = toReviewFetchableRecord(placeId: placeId, item)
            _ = try saveReviewFetchableRecrod(
              db: db,
              record
            )
          }
        })
      },
      update: { placeId, item in
        try await cache.write({ db in
          let reviewFetchableRecord = toReviewFetchableRecord(placeId: placeId, item)
          return try saveReviewFetchableRecrod(db: db, reviewFetchableRecord)
        })
      },
      clearByBranchId: { id in
        _ = try await cache.write({ db in
          try ReviewItemRecord
            .filter(Column("placeId") == id)
            .deleteAll(db)
        })
      }
    )
  }
}
