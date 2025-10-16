import BottomSheetModule
import DatabaseClient
import LocationManagerClient
import MapKit
import Models
import SwiftUI

public struct SearchView: View {
  @State private var isFocused: Bool = false
  @FocusState private var focusedField: Field?
  @Binding var detent: PresentationDetent

  enum Field { case search }

  @StateObject var store: SearchStore
  private let onFocusSearch: () -> ()
  private let onTapItemById: (Int) -> ()

  public init(
    store: SearchStore,
    detent: Binding<PresentationDetent>,
    onFocusSearch: @escaping () -> (),
    onTapItemById: @escaping (Int) -> ()
  ) {
    self._store = .init(wrappedValue: store)
    self._detent = detent
    self.onFocusSearch = onFocusSearch
    self.onTapItemById = onTapItemById
  }

  public var body: some View {
    ScrollView(.vertical) {
      VStack {
        SearchFilterView(filter: self.$store.filter) { tap in
          self.store.handleOnTap(tap)
        }
        if self.detent == BottomSheetDetents.expanded {
          ForEach(self.store.items) { item in
            ItemView(item: item) { id in self.onTapItemById(id) }
          }
        }
      }
    }
    .safeAreaInset(edge: .top, spacing: 0) {
      HStack(spacing: 10) {
        TextField("Search…", text: self.$store.searchText)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(.gray.opacity(0.25), in: .capsule)
          .focused(self.$focusedField, equals: .search)
          .submitLabel(.search)
          .onSubmit { self.store.observeLocalData() }
          .onChange(of: self.store.searchText) { _, _ in
            self.store.observeLocalData()
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
    .task(id: self.store.searchText) {
      self.store.observeLocalData()
    }
    .task {
      self.store.observePlaceFilter()
      self.store.observeLocalData()
    }
  }
}

#if DEBUG
  #Preview {
    SearchView(
      store: .init(
        placeCallback: { _, _ in
          AsyncThrowingStream<[Place], Error> { _ in }
        },
        filterCallback: {
          AsyncThrowingStream<PlaceFilter, Error> { _ in }
        },
        locationCallback: { .init(unfolding: { nil }) },
      ),
      detent: .constant(.large),
      onFocusSearch: {},
      onTapItemById: { _ in }
    )
  }
#endif
