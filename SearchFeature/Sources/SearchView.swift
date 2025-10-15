import DatabaseClient
import LocationManagerClient
import MapKit
import SwiftUI
import Models

public struct SearchView: View {
	@State private var isFocused: Bool = false
	@FocusState private var focusedField: Field?

	enum Field { case search }

	@StateObject var store: SearchStore
	private let onFocusSearch: () -> ()
	private let onTapItemById: (Int) -> ()
	
	public init(
		store: SearchStore,
		onFocusSearch : @escaping () -> (),
		onTapItemById: @escaping (Int) -> ()
	) {
		self._store = .init(wrappedValue: store)
		self.onFocusSearch = onFocusSearch
		self.onTapItemById = onTapItemById
	}

	public var body: some View {
		ScrollView(.vertical) {
			VStack {
				SearchFilterView(filter: $store.filter) { tap in
					store.handleOnTap(tap)
				}
				ForEach(store.items) { item in
					ItemView(item: item) { id in onTapItemById(id) }
				}
			}
		}
		.safeAreaInset(edge: .top, spacing: 0) {
			HStack(spacing: 10) {
				TextField("Search…", text: $store.searchText)
					.padding(.horizontal, 20)
					.padding(.vertical, 12)
					.background(.gray.opacity(0.25), in: .capsule)
					.focused($focusedField, equals: .search)
					.submitLabel(.search)
					.onSubmit { store.observeLocalData() }
					.onChange(of: store.searchText) { _, _ in
						store.observeLocalData()
					}

				Button {
					if focusedField == .search {
						focusedField = nil
					}
				} label: {
					ZStack {
						if focusedField == .search {
							Image(systemName: "xmark")
								.font(.title2).fontWeight(.semibold)
								.foregroundStyle(.primary)
								.frame(width: 48, height: 48)
								.glassEffect(in: .circle)
								.transition(.blurReplace)
						} else {
							Text("BV")
								.font(.title2.bold())
								.frame(width: 48, height: 48)
								.foregroundStyle(.white)
								.background(.gray, in: .circle)
								.transition(.blurReplace)
						}
					}
				}
			}
			.padding(.horizontal, 18)
			.frame(height: 80)
			.padding(.top, 5)
		}
		.onChange(of: focusedField) { _,newField in
			if focusedField == .search {
				
			}
		}
		.task(id: store.searchText) {
			store.observeLocalData()
		}
		.task {
			store.observePlaceFilter()
			store.observeLocalData()
		}
	}
}


#if DEBUG
#Preview {
	SearchView(
		store : .init(
			placeCallback: { _, _ in
				return AsyncThrowingStream<[Place], Error> { _ in}
			},
			filterCallback: {
				return AsyncThrowingStream<PlaceFilter, Error> { _ in}
			} ,
			locationCallback: { .init(unfolding: { nil }) },
		),
		onFocusSearch : {},
		onTapItemById: { _ in }
	)
}
#endif
