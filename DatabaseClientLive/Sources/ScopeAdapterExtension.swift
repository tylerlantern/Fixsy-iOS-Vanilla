import GRDB

extension ScopeAdapter {
  static func from(_ columns: [(String, Int)]) -> ScopeAdapter {
    let (scopes, _) = columns.reduce(
      into: ([String: RowAdapter](), 0)
    ) { acc, column in
      acc.0[column.0] = RangeRowAdapter(acc.1 ..< (acc.1 + column.1))
      acc.1 += column.1
    }
    return ScopeAdapter(scopes)
  }
}
