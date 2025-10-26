import APIClient
import AsyncAlgorithms
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
    case search,
         detail(_ placeId: Int)
  }

  @State public var mapVisualChannel: MapVisualChannel

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

  @Environment(PlaceStore.self) private var placeStore

  enum Destination: Hashable { case detail }
  @State var detent: PresentationDetent = BottomSheetDetents.collapsed
  @Environment(\.router) var router
  @Environment(\.apiClient) var apiClient
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.locationManagerClient) var locationManagerClient

  @State private var showBottomSheet = false
  @State var navPath = NavigationPath()

  @State var observeTask: Task<(), Error>?
  @State var fetchTask: Task<(), Error>?
  @State var innerTask: Task<(), Error>?

  @State var hasFocusRegionFirstTime: Bool = false

  @State var sheetDisplay: SheetDisplay = .search

  public var body: some View {
    VStack {
      MapVisualKitView(
        channel: self.mapVisualChannel
      )
    }
    .ignoresSafeArea()
    .task {
      self.observeTask?.cancel()
      self.fetchTask?.cancel()
      self.handleLocationAuthorizationStatus()
      self.fetchTask = Task {
        do {
          try await self.placeStore.fetchRemote()
        } catch {
          // TODO: Show tosat error
        }
      }

      let clock = ContinuousClock()
      Task {
        for try await filter in self.databaseClient
          .observePlaceFilter()
          .removeDuplicates()
          .debounce(for: .milliseconds(200), clock: clock)
        {
          self.innerTask?.cancel()
          self.innerTask = Task {
            do {
              for try await localPlaces in self.databaseClient.observeMapData(filter, "") {
                self.mapVisualChannel.sendEvent(.places(localPlaces))
              }
            } catch is CancellationError {
            } catch {}
          }
        }
        self.innerTask?.cancel()
      }

      Task {
        for await locs in self.locationManagerClient.locationStream() {
          guard !self.hasFocusRegionFirstTime, let loc = locs.first else { continue }
          self.hasFocusRegionFirstTime = true
          let region = MKCoordinateRegion(
            center: loc.coordinate,
            latitudinalMeters: 750,
            longitudinalMeters: 750
          )
          self.mapVisualChannel.sendEvent(
            .userRegion(region)
          )
        }
      }

      Task {
        for await action in self.mapVisualChannel.actionStream {
          handlePlaceStoreChannelAction(action: action)
        }
      }
    }
    .bottomSheet(
      detent: self.$detent
    ) {
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
                },
                {
                  // TODO: Open review form
                }
              )
            )
          )
        )
      }
    }
  }
}

#if DEBUG
  #Preview {
    HomeView()
  }
#endif
