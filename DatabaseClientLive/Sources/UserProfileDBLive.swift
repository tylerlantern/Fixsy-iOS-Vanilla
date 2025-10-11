import DatabaseClient
import GRDB
import Models
import UserProfileModel

extension UserProfileDB {
  static func live(cache: DatabaseWriter) ->
    UserProfileDB
  {
    .init(
      observeUserProfile: {
        AsyncThrowingStream { continuation in
          let cancellable = ValueObservation.tracking { db in
            try fetchUserProfile(db: db)
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
      saveUserProfile: { userProfile in
        try await cache.write { db in
          try syncUserProfile(db: db, userProfile)
        }
      },
      updateName: { firstName, lastName in
        _ = try await cache.write { db in
          try UserProfileRecord.updateAll(
            db,
            [
              Column("firstName").set(to: firstName),
              Column("lastName").set(to: lastName)
            ]
          )
        }
      },
      clearUserProfile: {
        try await cache.write { db in
          try UserProfileRecord.deleteAll(db)
        }
      }
    )
  }
}
