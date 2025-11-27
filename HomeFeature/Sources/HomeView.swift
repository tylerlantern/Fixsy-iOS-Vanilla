import APIClient
import AsyncAlgorithms
import BannerCenterModule
import BottomSheetModule
import DatabaseClient
import LocationManagerClient
import MapKit
import Models
import PlaceStore
import Router
import SwiftUI

public struct HomeView: View {
  public enum SheetDisplay {
    case search
    case detail(_ placeId: Int)
  }

  enum Destination: Hashable { case detail }

  @State public var mapVisualChannel: MapVisualChannel
  @Namespace private var unionNamespace
  @State public var sheetDisplayIpad: BottomSheetDisplayIpadType = .none

  @State var detent: PresentationDetent = BottomSheetDetents.collapsed
  @Environment(\.router) var router
  @Environment(\.apiClient) var apiClient
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.locationManagerClient) var locationManagerClient
  @EnvironmentObject var bannerCenter: BannerCenter
  @EnvironmentObject var banners: BannerCenter

  @State private var showBottomSheet = false
  @State var navPath = NavigationPath()

  @State var observeTask: Task<(), Error>?
  @State var fetchTask: Task<(), Error>?
  @State var innerTask: Task<(), Error>?
  @State var locationTask: Task<(), Error>?
  @State var mapVisualActionTask: Task<(), Error>?
  @State var locationAuthStatusTask: Task<(), Error>?

  @State var sheetDisplay: SheetDisplay = .search
  @State private var sheetHeight: CGFloat = 0

  @State var isRefreshing: Bool = false

  public init() {
    let event = AsyncStream<MapVisualChannel.Event>.makeStream()
    let action = AsyncStream<MapVisualChannel.Action>.makeStream()
    self.mapVisualChannel = .init(
      eventStream: event.stream,
      eventCont: event.continuation,
      actionStream: action.stream,
      actionCon: action.continuation
    )
  }

  public var body: some View {
    if UIDevice.current.userInterfaceIdiom == .pad {
      ZStack {
        self.baseMapView

        GeometryReader { geometry in
          BottomSheetIpadView(
            displayType: self.$sheetDisplayIpad,
            maxHeight: geometry.size.height - 10,
            minHeight: 90
          ) {
            self.sheetContent
          }
        }
      }
    } else {
      self.baseMapView
        .ignoresSafeArea()
        .bottomSheet(
          detent: self.$detent,
          sheetHeight: self.$sheetHeight
        ) {
          self.sheetContent
        }
    }
  }
}

// MARK: - Subviews

private extension HomeView {
  @ViewBuilder
  var baseMapView: some View {
    MapVisualKitView(
      channel: self.mapVisualChannel
    )
    .task {
      self.handleLocationAuthorizationStatus()
      self.observeAuthStatus()
      self.observeLocalData()
      self.observeLocation()
      self.observeMapVisualChannelAction()
      self.fetchData()
    }
    .overlay(
      alignment: .bottomTrailing,
      content: {
        self.bottomToolbar
      }
    )
  }

  @ViewBuilder
  var bottomToolbar: some View {
    switch self.sheetDisplay {
    case .detail:
      EmptyView()
    case .search:
      BottomFloatinToolBar(
        isRefreshing: self.isRefreshing,
        sheetHeight: self.sheetHeight,
        unionNamespace: self.unionNamespace,
        onTapRefresh: {
          self.fetchData()
        },
        onTapUserLocation: {
          self.handleOnTapUserLocation()
        }
      )
    }
  }

  @ViewBuilder
  var sheetContent: some View {
    switch self.sheetDisplay {
    case .search:
      self.router.route(
        .app(
          .search(
            .root(
              detent: self.$detent,
              onFocusSearch: {},
              onTapItemById: { id in
                self.sheetDisplay = .detail(id)
                self.mapVisualChannel.sendEvent(.selectedId(id))
              }
            )
          )
        )
      )
    case let .detail(placeId):
      self.router.route(
        .app(
          .detail(
            .root(
              placeId,
              {
                self.sheetDisplay = .search
                self.detent = BottomSheetDetents.collapsed
              }
            )
          )
        )
      )
    }
  }
}

@ViewBuilder
func BottomFloatinToolBar(
  isRefreshing: Bool,
  sheetHeight: CGFloat,
  unionNamespace: Namespace.ID,
  onTapRefresh: @escaping () -> (),
  onTapUserLocation: @escaping () -> ()
) -> some View {
  GlassEffectContainer {
    VStack {
      Button {
        if !isRefreshing {
          onTapRefresh()
        }
      } label: {
        if isRefreshing {
          ProgressView()
            .padding(.top, 8)
        } else {
          Label(
            "Refresh",
            systemImage: "arrow.clockwise"
          )
          .labelStyle(.iconOnly)
          .padding(.top, 8)
        }
      }
      .buttonStyle(.glass)
      .glassEffectUnion(
        id: "mapOptions",
        namespace: unionNamespace
      )

      Button {
        onTapUserLocation()
      } label: {
        Label("Navigation", systemImage: "location")
          .labelStyle(.iconOnly)
          .padding(.bottom, 8)
      }
      .buttonStyle(.glass)
      .glassEffectUnion(id: "mapOptions", namespace: unionNamespace)
    }
    .font(.title3)
  }
  .offset(y: -sheetHeight)
  .padding(24)
}

#if DEBUG
  #Preview {
    HomeView()
  }
#endif
