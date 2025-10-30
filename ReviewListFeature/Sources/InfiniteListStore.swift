import SwiftUI

@Observable
public class InfiniteListStore<
  Item: Identifiable,
  Cursor: Hashable,
  NetworkResponse: Equatable
> {
  public enum State {
    case shimmer,
         items,
         errorFullPage,
         emptyList
  }

  public var state: State
  public let fetchClosure: (Cursor?) async throws -> NetworkResponse
  public let observeAsyncStream: () -> AsyncThrowingStream<[Item], Error>
  public let parseResponse: (NetworkResponse) -> ([Item], _nextCursor: Cursor)
  public let syncItems: @Sendable ([Item]) async throws -> ()
  public let clearItems: @Sendable () async throws -> ()

  public var currentCursor: Cursor?
  public var isFetching: Bool = false
  public var showErrorOnNextPage: Bool = false

  public var items: [Item] = []

  public var observeTask: Task<(), Error>?

  public init(
    state: State = .shimmer,
    fetchClosure: @escaping @Sendable (Cursor?) async throws -> NetworkResponse,
    observeAsyncStream: @escaping @Sendable () -> AsyncThrowingStream<[Item], Error>,
    parseResponse: @escaping @Sendable (NetworkResponse) -> ([Item], _nextCursor: Cursor),
    syncItems: @escaping @Sendable ([Item]) async throws -> (),
    clearItems: @escaping @Sendable () async throws -> ()
  ) {
    self.state = state
    self.fetchClosure = fetchClosure
    self.observeAsyncStream = observeAsyncStream
    self.parseResponse = parseResponse
    self.syncItems = syncItems
    self.clearItems = clearItems
  }

  public func refresh() {
    self.items = []
    self.isFetching = false
    self.showErrorOnNextPage = false
    self.currentCursor = nil
  }

  public func fetch() {
    guard !self.isFetching else {
      return
    }
    self.isFetching = true
    Task {
      do {
        let response = try await self.fetchClosure(self.currentCursor)
        self.isFetching = false
        let (parsedItems, nextCursor) = self.parseResponse(response)
        try await self.syncItems(parsedItems)
        self.currentCursor = nextCursor
      } catch {
        self.isFetching = false
        // First page error show full screen error instead
        if self.currentCursor == nil {
          self.state = .errorFullPage
          return
        }
        self.showErrorOnNextPage = true
      }
    }
  }

  public func observe() {
    self.observeTask?.cancel()
    self.observeTask = Task {
      for try await items in self.observeAsyncStream() {
        self.items = items
      }
    }
  }
}
