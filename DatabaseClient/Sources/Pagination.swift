import Foundation

public struct PageInfo<Cursor>: Equatable where Cursor: Equatable {
  public let pointer: Pointer<Cursor>
  public let totalCount: Int
  public let nextPageCursor: Cursor?
  public var hasNext: Bool { self.nextPageCursor != nil }

  public init(pointer: Pointer<Cursor>, totalCount: Int, nextPageCursor: Cursor?) {
    self.pointer = pointer
    self.totalCount = totalCount
    self.nextPageCursor = nextPageCursor
  }
}

public struct Pointer<Cursor>: Equatable where Cursor: Equatable {
  public var cursor: Cursor
  public var pageSize: Int

  public init(
    cursor: Cursor,
    pageSize: Int
  ) {
    self.cursor = cursor
    self.pageSize = pageSize
  }
}

public struct Page<Data, Cursor: Equatable> {
  public var data: [Data]
  public let info: PageInfo<Cursor>

  public init(data: [Data], info: PageInfo<Cursor>) {
    self.data = data
    self.info = info
  }

  public func map<B>(_ f: (Data) -> B) -> Page<B, Cursor> {
    Page<B, Cursor>(
      data: self.data.map(f),
      info: self.info
    )
  }

  public func compactMap<B>(_ f: (Data) -> B?) -> Page<B, Cursor> {
    Page<B, Cursor>(
      data: self.data.compactMap(f),
      info: self.info
    )
  }
}

extension Page: Equatable where Data: Equatable {
  public static func == (lhs: Page<Data, Cursor>, rhs: Page<Data, Cursor>) -> Bool {
    lhs.data == rhs.data && lhs.info == rhs.info
  }
}

public struct PageData<Data: Equatable, Cursor: Equatable>: Equatable {
  public var data: [Data]
  public let prevCursor: Cursor?
  public let nextCursor: Cursor?
}
