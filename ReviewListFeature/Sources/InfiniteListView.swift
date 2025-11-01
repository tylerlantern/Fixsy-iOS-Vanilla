import SwiftUI

public struct InfiniteListView<
	Item: Identifiable,
	Cursor: Hashable,
	NetworkResponse: Equatable,
	Content: View
>: View {
	
	@Environment(
		InfiniteListStore<
		Item,
		Cursor,
		NetworkResponse
		>.self
	) private var store
	
	private let itemContent: (Item) -> Content
	
	public init(
		@ViewBuilder itemContent: @escaping (Item) -> Content
	) {
		self.itemContent = itemContent
	}
	
	public var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading, spacing: 12) {
				ForEach(self.store.items) { item in
					self.itemContent(item)
						.onAppear {
							if item.id == self.store.items.last?.id{
								self.store.fetch()
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
	}
}
