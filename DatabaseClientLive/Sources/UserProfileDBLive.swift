import Combine
import ComposableArchitecture
import DatabaseClient
import GRDB
import Model

extension UserProfileDB {
  static func live(cache: DatabaseWriter) ->
    UserProfileDB
  {
    .init(
      observeUserProfile: {
//				// Define the observed value
//				let observation = ValueObservation.tracking { db in
//						try Player.fetchAll(db)
//				}
				
        ValueObservation.tracking { db in
          try fetchUserProfile(db: db)
        }
				.values(in: cache)
//        .publisher(in: cache)
//        .mapError(DBError.error)
//        .eraseToAnyPublisher()
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
