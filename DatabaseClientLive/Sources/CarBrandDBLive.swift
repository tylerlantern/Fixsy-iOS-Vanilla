import DatabaseClient
import GRDB
import Models

extension CarBrandDB {
  static func live(cache: DatabaseWriter) -> CarBrandDB {
    CarBrandDB(
      observe: {
        AsyncThrowingStream { continuation in
          let cancellable = ValueObservation.tracking { db in
            try fetchCarBrands(db: db)
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
          continuation.onTermination = { @Sendable _ in
            cancellable.cancel()
          }
        }
      },
      sync: { carBrands in
        try cache.write { db in
          try syncCarBrands(db: db, carBrands)
        }
      }
    )
  }
}

func fetchCarBrands(db: Database) throws -> [CarBrand] {
  func toCarBrand(record r: CarBrandRecord) -> CarBrand {
    CarBrand(id: r.id, displayName: r.displayName)
  }
  return try CarBrandRecord.fetchAll(db).map(toCarBrand(record:))
}

func syncCarBrands(db: Database, _ cbs: [CarBrand]) throws {
  func toRecord(_ m: CarBrand) -> CarBrandRecord {
    CarBrandRecord(id: m.id, displayName: m.displayName)
  }
  try cbs.map(toRecord(_:)).forEach({ record in
    try record.save(db, onConflict: .replace)
  })
}
