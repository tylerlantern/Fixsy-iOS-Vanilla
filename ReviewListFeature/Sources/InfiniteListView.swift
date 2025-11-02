import SwiftUI

public struct InfiniteListView<
  Item: Identifiable,
  Cursor: Hashable,
  NetworkResponse: Equatable,
  ShimmerContent: View,
  Content: View,
>: View {
  @State private var store:
    InfiniteListStore<
      Item,
      Cursor,
      NetworkResponse
    >

  private let shimmerContent: () -> ShimmerContent
  private let itemContent: (Item) -> Content

  public init(
    store: InfiniteListStore<
      Item,
      Cursor,
      NetworkResponse
    >,
    @ViewBuilder shimmerContent: @escaping () -> ShimmerContent,
    @ViewBuilder itemContent: @escaping (Item) -> Content
  ) {
    self.store = store
    self.shimmerContent = shimmerContent
    self.itemContent = itemContent
  }

  public var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 12) {
        if self.store.showShimmer {
          self.shimmerContent()
        } else {
          ForEach(self.store.items) { item in
            self.itemContent(item)
              .onAppear {
                if item.id == self.store.items.last?.id {
                  self.store.fetch()
                }
              }
          }
        }

        if self.store.isFetchingNextCursor {
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
    .refreshable {
      self.store.refresh()
    }
    .task {
      self.store.initialize()
    }
  }
}
