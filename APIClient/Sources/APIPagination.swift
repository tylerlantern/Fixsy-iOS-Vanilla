import Foundation

public struct ListResponse<Data: Decodable>: Decodable, Equatable where Data: Equatable {
  public var data: [Data]

  public init(data: [Data]) {
    self.data = data
  }
}

public struct PageResponse<Data: Decodable>: Decodable, Equatable where Data: Equatable {
  public var items: [Data]
  public let page: Int
  public let size: Int
  public let totalPages: Int

  public init(
    items: [Data],
    page: Int,
    size: Int,
    totalpages: Int
  ) {
    self.items = items
    self.page = page
    self.size = size
    self.totalPages = totalpages
  }
}

public struct PageMetaResponse: Decodable, Equatable {
  public let total: Int
  public let perPage: Int
  public let currentPage: Int
  public let lastPage: Int

  public init(total: Int, perPage: Int, currentPage: Int, lastPage: Int) {
    self.total = total
    self.perPage = perPage
    self.currentPage = currentPage
    self.lastPage = lastPage
  }
}
