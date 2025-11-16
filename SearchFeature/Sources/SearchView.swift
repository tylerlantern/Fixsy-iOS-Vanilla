import AccessTokenClient
import APIClient
import BannerCenterModule
import BottomSheetModule
import ContentHeightSheetComponent
import DatabaseClient
import LocationManagerClient
import MapKit
import Models
import PlaceStore
import Router
import SwiftUI

public struct SearchView: View {
  @State var presentedSocialSignInScreen: Bool = false
  @State var presentedUserProfileScreen: Bool = false

  @State private var isFocused: Bool = false
  @FocusState private var focusedField: Field?
  @Binding var detent: PresentationDetent

  @State var items: [Item] = []
  @State var searchText: String = ""
  @State var filter: PlaceFilter = .identity

  @Environment(PlaceStore.self) private var placeStore

  enum Field { case search }

  private let onFocusSearch: () -> ()
  private let onTapItemById: (Int) -> ()

  @State var observeFilterTask: Task<(), Error>?
  @State var observePlaceTask: Task<(), Error>?
  @State var observeLocalUserTask: Task<(), Error>?

  @State var transformTask: Task<(), Error>?
  @State var searchTask: Task<(), Error>?
  @State var locTask: Task<(), Error>?

  @State var profileURL: URL? = nil
  @State var fetchLocalToken: Task<(), Error>?

  @EnvironmentObject var banners: BannerCenter

  @Environment(\.router) var router
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.locationManagerClient) var locationManagerClient
  @Environment(\.apiClient) var apiClient
  @Environment(\.accessTokenClient) var accessTokenClient

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
        SearchFilterView()
        if self.detent == BottomSheetDetents.expanded {
          ForEach(self.items) { item in
            ItemView(item: item) { id in self.onTapItemById(id) }
          }
        }
      }
    }
    .animation(.snappy(duration: 0.25), value: self.items)
    .onDisappear(perform: {
      self.observePlaceTask?.cancel()
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

        if self.focusedField == .search {
          Button {
            if self.focusedField == .search {
              self.focusedField = nil
            }
          } label: {
            Image(systemName: "xmark")
              .font(.title2).fontWeight(.semibold)
              .foregroundStyle(.primary)
              .frame(width: 48, height: 48)
              .glassEffect(in: .circle)
              .transition(.blurReplace)
          }
        } else {
          ProfileAvatar(
            url: self.profileURL
          ) {
            onTapAvartarProfile()
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
    .task {
      self.observeLocalData()
      self.observeUserProfile()
    }
    .onDisappear {
      self.fetchLocalToken?.cancel()
      self.observeFilterTask?.cancel()
      self.observePlaceTask?.cancel()
      self.transformTask?.cancel()
      self.searchTask?.cancel()
      self.locTask?.cancel()
      self.observeLocalUserTask?.cancel()
    }
    .sheet(
      isPresented: self.$presentedSocialSignInScreen
    ) {
      self.router.route(
        .app(
          .search(
            .socialSignIn
          )
        )
      )
      .adjustSheetHeightToContent()
    }
    .sheet(
      isPresented: self.$presentedUserProfileScreen
    ) {
      self.router.route(
        .app(
          .search(
            .userProfile(
              .root
            )
          )
        )
      )
    }
  }
}

private struct ProfileAvatar: View {
  let url: URL?
  let onTap: () -> ()
  var body: some View {
    Group {
      if let url {
        AsyncImage(url: url, transaction: .init(animation: .easeInOut)) { phase in
          switch phase {
          case .empty:
            ZStack {
              Circle().fill(.gray.opacity(0.25))
              ProgressView()
            }
            .frame(width: 44, height: 44)
          case let .success(image):
            image
              .resizable()
              .scaledToFill()
              .frame(width: 44, height: 44)
          case .failure:
            personCircle()
          @unknown default:
            personCircle()
          }
        }
      } else {
        personCircle()
      }
    }
    .clipShape(Circle())
    .contentShape(Circle())
    .onTapGesture {
      self.onTap()
    }
  }
}

@ViewBuilder
private func personCircle(
  size: CGFloat = 44,
  bg: Color = .gray,
  showProgress: Bool = false
) -> some View {
  ZStack {
    Circle().fill(bg)
    if showProgress {
      ProgressView()
    } else {
      Image(systemName: "person.fill")
        .resizable()
        .scaledToFit()
        .foregroundStyle(.white)
        .padding(size * 0.22) // keeps icon nicely inset
    }
  }
  .frame(width: size, height: size)
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
