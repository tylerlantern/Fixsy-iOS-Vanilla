import Foundation

public enum MigrationError: Error {
  /// database too old, database lacks expected migrations
  case requiresMigration(String)
  /// database too new, database contains unknown (future) migrations
  case migratedUnmatchsMigrator(String)
}
