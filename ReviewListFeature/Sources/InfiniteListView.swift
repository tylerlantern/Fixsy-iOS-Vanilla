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
				switch self.store.state {
				case .emptyList:
					HStack {
						Spacer()
						Text(
							String(
								localized: "No Data.",
								bundle: .module
							)
						)
						Spacer()
					}
				case .shimmer:
					self.shimmerContent()
				case .items:
					ForEach(self.store.items) { item in
						self.itemContent(item)
							.onAppear {
								if item.id == self.store.items.last?.id {
									self.store.fetch()
								}
							}
					}
				case .errorFullPage:
					
					HStack {
						VStack(spacing: 16) {
							Spacer()
							Text(
								String(
									localized: "Please try again",
									bundle: .module
								)
							)
							Button {
								self.store.refresh()
							} label: {
								Text(
									String(
										localized: "Retry",
										bundle: .module
									)
								)
								.padding(.horizontal, 24)
								.padding(.vertical, 10)
							}
							.buttonStyle(.borderedProminent)
							
							Spacer()
						}
					}
					.padding(.top, 24)
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
		.onDisappear {
			self.store.handleOnDisappear()
		}
	}
}
