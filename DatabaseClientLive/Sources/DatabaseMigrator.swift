import GRDB

extension DatabaseMigrator {
  static func migrate(pref: DatabaseWriter, cache: DatabaseWriter) throws {
    let prefMigrator = DatabaseMigrator.pref
    try prefMigrator.migrate(pref)
    try pref.read { db in
      if try prefMigrator.hasCompletedMigrations(db) == false {
        throw MigrationError.requiresMigration("pref database")
      }

      if try prefMigrator.hasBeenSuperseded(db) {
        throw MigrationError.migratedUnmatchsMigrator("pref database")
      }
    }

    let cacheMigrator = DatabaseMigrator.cache
    try cacheMigrator.migrate(cache)
    try cache.read { db in
      if try cacheMigrator.hasCompletedMigrations(db) == false {
        throw MigrationError.requiresMigration("cache database")
      }

      if try cacheMigrator.hasBeenSuperseded(db) {
        throw MigrationError.migratedUnmatchsMigrator("cache database")
      }
    }
  }

  static var pref: Self {
    var migrator = DatabaseMigrator()
    migrator.registerMigration("v1") { _ in }
    return migrator
  }

  static var cache: Self {
    var migrator = DatabaseMigrator()
    migrator.eraseDatabaseOnSchemaChange = true
    migrator.registerMigration("v1") { db in
      try createMapDataTables(db: db)
      try createReviewTables(db: db)
    }
    return migrator
  }
}

func createMapDataTables(db: Database) throws {
  try db.create(table: "PLACE") { t in
    t.column("id", .integer)
      .primaryKey(onConflict: .replace)
      .notNull()
      .indexed()
    t.column("name", .text).notNull()
    t.column("latitude", .double).notNull()
    t.column("longitude", .double).notNull()
    t.column("address", .text).notNull()

    t.column("hasMotorcycleGarage", .boolean).notNull()
    t.column("hasInflationStation", .boolean).notNull()
    t.column("hasWashStation", .boolean).notNull()
    t.column("hasPatchTireStation", .boolean).notNull()
    t.column("hasCarGarage", .boolean).notNull()

    t.column("averageRate", .double).notNull()

    t.column("mondayOpen", .text).notNull()
    t.column("mondayClose", .text).notNull()
    t.column("tuesdayOpen", .text).notNull()
    t.column("tuesdayClose", .text).notNull()
    t.column("wednesdayOpen", .text).notNull()
    t.column("wednesdayClose", .text).notNull()
    t.column("thursdayOpen", .text).notNull()
    t.column("thursdayClose", .text).notNull()
    t.column("fridayOpen", .text).notNull()
    t.column("fridayClose", .text).notNull()
    t.column("saturdayOpen", .text).notNull()
    t.column("saturdayClose", .text).notNull()
    t.column("sundayOpen", .text).notNull()
    t.column("sundayClose", .text).notNull()

    t.column("contributorName", .text).notNull()
  }

  try db.create(table: "PLACE_FILTER") { t in
    t.column("id", .integer)
      .primaryKey(onConflict: .replace)
      .notNull()
      .indexed()
    t.column("showCarGarage", .boolean).notNull()
    t.column("showMotorcycleGarages", .boolean).notNull()
    t.column("showInflationPoints", .boolean).notNull()
    t.column("showWashStations", .boolean).notNull()
    t.column("showPatchTireStations", .boolean).notNull()
  }

  try db.create(
    table: "CAR_BRAND",
    body: { t in
      t.column("id", .integer)
        .primaryKey(onConflict: .replace)
        .notNull()
        .indexed()
      t.column("displayName", .text)
        .notNull()
    }
  )

  try db.create(
    table: "PLACE_CAR_BRAND_RELATION",
    body: { t in
      t.primaryKey(["placeId", "brandId"])
      t.column("placeId", .integer)
        .notNull()
        .indexed()
        .references("PLACE", onDelete: .cascade)
      t.column("brandId", .integer)
        .notNull()
        .indexed()
        .references("CAR_BRAND", onDelete: .cascade)
    }
  )

  try db.create(
    table: "IMAGE",
    body: { t in
      t.column("id", .integer)
        .primaryKey(onConflict: .replace)
        .notNull()
        .indexed()
      t.column("url", .text)
        .notNull()
      t.column("placeId", .integer)
        .notNull()
        .indexed()
        .references("PLACE", onDelete: .cascade)
    }
  )

  try db.create(
    table: "USER_PROFILE",
    body: { t in
      t.column("id", .text)
        .primaryKey(onConflict: .replace)
        .notNull()
        .indexed()
      t.column("email", .text)
        .notNull()
      t.column("firstName", .text)
        .notNull()
      t.column("lastName", .text)
        .notNull()
      t.column("pictureURL", .text)
      t.column("point", .integer)
    }
  )
}

func createReviewTables(db: Database) throws {
  try db.create(table: "REVIEW_ITEM") { t in
    t.column("id", .integer)
      .primaryKey(onConflict: .replace)
      .notNull()
      .indexed()
    t.column("placeId", .integer)
      .notNull()
      .indexed()
    t.column("text", .text).notNull()
    t.column("fullName", .text).notNull()
    t.column("profileImage", .text)
    t.column("givenRate", .double).notNull()
    t.column("createdDate", .datetime).notNull()
  }

  try db.create(table: "REVIEW_ITEM_IMAGE") { t in
    t.column("id", .integer)
      .primaryKey(onConflict: .replace)
      .notNull()
      .indexed()
    t.column("reviewItemId", .integer)
      .notNull()
      .indexed()
      .references("REVIEW_ITEM", onDelete: .cascade)
    t.column("url", .text)
  }

  try db.create(
    table: "REVIEW_ITEM_RELATING_CAR_BRAND",
    body: { t in
      t.primaryKey(["reviewItemId", "brandId"])
      t.column("reviewItemId", .integer)
        .notNull()
        .indexed()
        .references("REVIEW_ITEM", onDelete: .cascade)
      t.column("brandId", .integer)
        .notNull()
        .indexed()
        .references("CAR_BRAND", onDelete: .cascade)
    }
  )
}
