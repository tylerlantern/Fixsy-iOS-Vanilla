import SwiftUI

public struct InfiniteListView<Item: Identifiable, Content: View>: View {
  //	@StateObject private var store = InfiniteListStore()

  public typealias LoadMore = () async -> ()

  private let items: [Item]
  private let isLoading: Bool
  private let canLoadMore: Bool
  private let loadMore: LoadMore?
  private let itemContent: (Item) -> Content

  public init(
    items: [Item],
    isLoading: Bool = false,
    canLoadMore: Bool = true,
    loadMore: LoadMore? = nil,
    @ViewBuilder itemContent: @escaping (Item) -> Content
  ) {
    self.items = items
    self.isLoading = isLoading
    self.canLoadMore = canLoadMore
    self.loadMore = loadMore
    self.itemContent = itemContent
  }

  public var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 12) {
        ForEach(self.items) { item in
          self.itemContent(item)
            .onAppear {
              if item.id == self.items.last?.id, self.canLoadMore, !self.isLoading {
                Task { await self.loadMore?() }
              }
            }
        }

        if self.isLoading {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
          .padding(.vertical, 12)
        }
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 16)
    }
  }
}
