import Combine
import DatabaseClient
import Foundation
import GRDB
import Models

extension DatabaseClient {
  public static var liveValue: DatabaseClient {
    let (pref, cache) = try! createDatabaseConnections()
    return Self(
      migrate: {
        let result = Result { try DatabaseMigrator.migrate(pref: pref, cache: cache) }
        switch result {
        case .success:
          break
        case let .failure(error):
          print("migrate error", error)
        }
        return result
      },
      userProfileDB: .live(cache: cache),
      carBrandDB: .live(cache: cache),
      observeMapData: { placeFilter, keyword in
        AsyncThrowingStream { continuation in
          final class Holder { var dbCancellable: AnyDatabaseCancellable? }
          let holder = Holder()
          let startTask = Task { @MainActor in
            holder.dbCancellable = ValueObservation
              .tracking { db in
                try fetchPlaces(db: db, filter: placeFilter, keyword: keyword)
              }
              .start(
                in: cache,
                scheduling: .immediate,
                onError: { error in
                  continuation.finish(throwing: error)
                },
                onChange: { items in
                  _ = continuation.yield(items)
                }
              )
          }
          continuation.onTermination = { @Sendable _ in
            Task { @MainActor in
              startTask.cancel()
              holder.dbCancellable?.cancel()
              holder.dbCancellable = nil
            }
          }
        }
      },
      fetchMapData: { placeFilter, keyword in
        try await cache.read { db in
          try fetchPlaces(db: db, filter: placeFilter, keyword: keyword)
        }
      },
      syncPlaces: { (places: [Place]) -> Int in
        try await cache.write({ db in
          try savePlaces(db: db, places: places)
          return places.count
        })
      },
      deleteAll: {
        try await cache.write { db in
          try MotorcycleGarageRecord.deleteAll(db)
          try InflatingPointRecord.deleteAll(db)
          try WashStationRecord.deleteAll(db)
          try PatchTireStationRecord.deleteAll(db)
        }
      },
      observePlaceDetail: { id in
        AsyncThrowingStream { continuation in
          let cancellable = ValueObservation.tracking { db in
            try PlaceInfo.fetchOne(
              db,
              PlaceRecord
                .filter(Column("id") == id)
                .include()
            ).map(toPlace)
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
      observePlaceFilter: {
        AsyncThrowingStream { continuation in
          final class Holder { var dbCancellable: AnyDatabaseCancellable? }
          let holder = Holder()
          let startTask = Task { @MainActor in
            holder.dbCancellable = ValueObservation.tracking { db in
              try fetchPlaceFilter(db: db)
            }
            .start(
              in: cache,
              scheduling: .immediate,
              onError: { error in
                continuation.finish(throwing: error)
              },
              onChange: { items in
                continuation.yield(items)
              }
            )
          }
          continuation.onTermination = { @Sendable _ in
            Task { @MainActor in
              startTask.cancel()
              holder.dbCancellable?.cancel()
              holder.dbCancellable = nil
            }
          }
        }
      },
      getPlaceFilter: {
        try await cache.read { db in
          try fetchPlaceFilter(db: db)
        }

      },
      syncPlaceFilter: { filter in
        try await cache.write({ db in
          try savePlaceFilter(db: db, filter)
        })
      },
      reviewDB: .live(cache: cache)
    )
  }
}

private func createDatabaseConnections() throws -> (pref: DatabaseWriter, cache: DatabaseWriter) {
  let fileManager = FileManager()
  let folderURL = try fileManager
    .url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    .appendingPathComponent("database", isDirectory: true)

  // Support for tests: delete the database if requested
  if CommandLine.arguments.contains("-reset") {
    try? fileManager.removeItem(at: folderURL)
  }

  try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

  let prefPath = folderURL.appendingPathComponent("pref.sqlite").path
  let cachePath = folderURL.appendingPathComponent("cache.sqlite").path

  #if DEBUG
    print("--- Database connection info ---")
    print("--- Pref:\nopen \"\(prefPath)\"")
    print("--- Cache:\nopen \"\(cachePath)\"")
  #endif

  return try (
    pref: DatabaseQueue(path: prefPath),
    cache: DatabaseQueue(path: cachePath)
  )
}
