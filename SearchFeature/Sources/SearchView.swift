import BottomSheetModule
import DatabaseClient
import LocationManagerClient
import MapKit
import Models
import SwiftUI
import PlaceStore

public struct SearchView: View {
	
  @State private var isFocused: Bool = false
  @FocusState private var focusedField: Field?
  @Binding var detent: PresentationDetent

	@State var filter: PlaceFilter = .identity
	@State var items: [Item] = []
	@State var searchText: String = ""
	@Environment(PlaceStore.self) private var placeStore
	
  enum Field { case search }

  private let onFocusSearch: () -> ()
  private let onTapItemById: (Int) -> ()

	@State var observePlacesTask: Task<(), Error>?
	@State var observeFilterTask: Task<(), Error>?
	@State var transformTask: Task<(), Error>?
	@State var searchTask: Task<(), Error>?
	@State var locTask: Task<(), Error>?
	
	@Environment(\.databaseClient) var databaseClient
	@Environment(\.locationManagerClient) var locationManagerClient
	
  public init(
    detent: Binding<PresentationDetent>,
    onFocusSearch: @escaping () -> (),
    onTapItemById: @escaping (Int) -> ()
  ) {
    self._detent = detent
    self.onFocusSearch = onFocusSearch
    self.onTapItemById = onTapItemById
  }
	
  public var body: some View {
		@Bindable var placeStore = self.placeStore
    ScrollView(.vertical) {
      VStack {
        SearchFilterView(
					filter: $placeStore.filter
				) { tap in
//          self.store.handleOnTap(tap)
        }
        if self.detent == BottomSheetDetents.expanded {
          ForEach(self.items) { item in
            ItemView(item: item) { id in self.onTapItemById(id) }
          }
        }
      }
    }
		.onDisappear(perform: {
			self.observePlacesTask?.cancel()
			self.observeFilterTask?.cancel()
			self.transformTask?.cancel()
		})
    .safeAreaInset(edge: .top, spacing: 0) {
      HStack(spacing: 10) {
        TextField("Search…", text: self.$searchText)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(.gray.opacity(0.25), in: .capsule)
          .focused(self.$focusedField, equals: .search)
          .submitLabel(.search)
          .onSubmit { self.observeLocalData() }
          .onChange(of: self.searchText) { _, _ in
            self.observeLocalData()
          }

        Button {
          if self.focusedField == .search {
            self.focusedField = nil
          }
        } label: {
          ZStack {
            if self.focusedField == .search {
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
    .onChange(of: self.focusedField) { _, newField in
      if newField == .search {
        self.detent = .large
      } else {
        self.detent = .medium
      }
    }
    .onChange(
      of: self.detent,
      { _, newValue in
        if newValue != BottomSheetDetents.expanded {
          self.focusedField = nil
        }
      }
    )
    .task(id: self.searchText) {
      self.observeLocalData()
    }
    .task {
      self.observePlaceFilter()
      self.observeLocalData()
    }
  }
}

#if DEBUG
  #Preview {
    SearchView(
      detent: .constant(.large),
      onFocusSearch: {},
      onTapItemById: { _ in }
    )
  }
#endif
