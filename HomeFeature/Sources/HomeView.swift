import APIClient
import DatabaseClient
import LocationManagerClient
import MapKit
import Models
import Router
import SwiftUI

public struct HomeView: View {
  enum Destination: Hashable { case detail }

  @Environment(\.router) var router
  @Environment(\.apiClient) var apiClient
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.locationManagerClient) var locationManagerClient

  @State var navPath = NavigationPath()
  @State var mapChannel: MapChannel
  @State var hasFocusRegionFirstTime: Bool = false
  @StateObject var placeStore: PlaceStore

  public init(
    placeStore: PlaceStore
  ) {
    let mapChannelEvent =
      AsyncStream.makeStream(of: MapChannel.Event.self)
    let mapChannelAction =
      AsyncStream.makeStream(of: MapChannel.Action.self)
    self.mapChannel = .init(
      eventChannel: mapChannelEvent,
      actions: mapChannelAction.continuation
    )
    _placeStore = StateObject(wrappedValue: placeStore)
  }

  public var body: some View {
    NavigationStack(path: self.$navPath) {
      VStack {
        MapVisualKitView(
          channel: self.mapChannel
        )
      }
      .ignoresSafeArea()
      .navigationDestination(for: Destination.self) { destination in
        let route = switch destination {
        case .detail:
          Route.home(.detail(.root(self.$navPath, "DAMN TAKE")))
        }
        self.router.route(route)
      }
      .task {
        Task {
          for await event in self.placeStore.eventChannel.stream {
            switch event {
            case let .places(places):
              self.mapChannel.sendEvent(
                .places(places)
              )
            }
          }
        }
        Task {
          for await event in self.locationManagerClient.delegate() {
            switch event {
            case let .didUpdateLocations(locations):
              print("didUpdateLocations", locations)
              guard !self.hasFocusRegionFirstTime, let loc = locations.first else { continue }
              self.hasFocusRegionFirstTime = true
              let region = MKCoordinateRegion(
                center: loc.coordinate,
                latitudinalMeters: 750,
                longitudinalMeters: 750
              )
              self.mapChannel.sendEvent(
                .userRegion(region)
              )
            case let .didFailWithError(error):
              print("ERROR", error)
            case let .didChangeAuthorization(status):
              print("STATUS", status)
            }
          }
        }
        self.handleLocationAuthorizationStatus()
        self.placeStore.observeLocalData()
        await self.placeStore.fetchRemote {
          try await self.apiClient.call(
            route: .mapData,
            as: MapResponse.self
          )
        }
      }
    }
  }
}
