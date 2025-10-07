import UIKit
import SwiftUI

//@Reducer
//public struct MapVisual {
//  public init() {}
//
//  public enum Action: Equatable {
//    case
//      deselectAnnotation(id: Int),
//      viewDidLoad,
//      fetchResponse(TaskResult<[Place]>),
//      showDetail(Int),
//      updateLocation(CLLocation),
//      observeLocal(Result<[Place], DBError>),
//      observeFilter(PlaceFilter),
//      centerUserRegion,
//      didChangeCoordiateRegion(MKCoordinateRegion),
//      syncPlaces(TaskResult<Int>),
//      didDeselect,
//      refetch,
//      fetch,
//      zoom(_ lat: Double, _ lng: Double),
//      observeAuthStatus(CLAuthorizationStatus),
//      start,
//      setMapRegion(latitude: Double, longitude: Double)
//  }
//
//  @ObservableState
//  public struct State: Equatable {
//    public var places: [Place]
//    public var userCoordinateRegion: MKCoordinateRegion?
//    public var coordinateRegion: MKCoordinateRegion?
//    public var currentUserLocation: CLLocation?
//    public var hasCenterUserRegionOnce: Bool
//    public var requestSelectedId: Int?
//    public var requestDeselectId: Int?
//    public init(
//      places: [Place] = [],
//      userCoordinateRegion: MKCoordinateRegion? = nil,
//      coordinateRegion: MKCoordinateRegion? = nil,
//      currentUserLocation: CLLocation? = nil,
//      hasCenterUserRegionOnce: Bool = false,
//      requestSelectedId: Int? = nil,
//      requestDeselectId: Int? = nil
//    ) {
//      self.places = places
//      self.userCoordinateRegion = userCoordinateRegion
//      self.coordinateRegion = coordinateRegion
//      self.currentUserLocation = currentUserLocation
//      self.hasCenterUserRegionOnce = hasCenterUserRegionOnce
//      self.requestSelectedId = requestSelectedId
//      self.requestDeselectId = requestDeselectId
//    }
//  }
//
//  @Dependency(\.alertMessageClient) var alertMessageClient
//  @Dependency(\.apiClient) var apiClient
//  @Dependency(\.mainQueue) var mainQueue
//  @Dependency(\.locationManagerClient) var locationManagerClient
//  @Dependency(\.databaseClient.observeMapData) var observeMapData
//  @Dependency(\.databaseClient.observePlaceFilter) var observePlaceFilter
//  @Dependency(\.databaseClient.syncPlaces) var syncPlaces
//  @Dependency(\.userDefaultClient) var userDefaultClient
//
//  struct FetcherID: Hashable {}
//  struct ObserveId: Hashable {}
//
//  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
//    switch action {
//    case let .deselectAnnotation(id):
//      state.requestDeselectId = id
//      return .none
//    case let .setMapRegion(lat, lng):
//      state.userCoordinateRegion = .init(
//        center: .init(latitude: lat, longitude: lng),
//        latitudinalMeters: 200,
//        longitudinalMeters: 200
//      )
//      return .none
//    case .fetch:
//      return Effect<Action>.run { send in
//        await send(
//          Action.fetchResponse(
//            await TaskResult {
//              try await self.apiClient.call(
//                route: .mapData,
//                as: MapDataResponse.self
//              )
//              .branches
//              .map(\.value)
//            }
//          )
//        )
//      }
//      .cancellable(id: FetcherID())
//    case .refetch:
//      return Effect.send(Action.fetch)
//    case .start:
//      return Effect.merge(
//        .run(operation: { send in
//          for await status in self.locationManagerClient.authStatusStream() {
//            await send(.observeAuthStatus(status))
//          }
//        }),
//        Effect.send(Action.fetch)
//      )
//    case .viewDidLoad:
//
//      // MARK: Leave it empty here because it ran viewDidload before ViewModifier .task of SwiftUI
//
//      return .none
//    case let .updateLocation(location):
//      state.currentUserLocation = location
//      if !state.hasCenterUserRegionOnce {
//        state.hasCenterUserRegionOnce = true
//        state.userCoordinateRegion = MKCoordinateRegion(
//          center: .init(
//            latitude: location.coordinate.latitude,
//            longitude: location.coordinate.longitude
//          ),
//          latitudinalMeters: .init(exactly: 5_000)!,
//          longitudinalMeters: .init(exactly: 5_000)!
//        )
//      }
//      return .none
//    case .centerUserRegion:
//      guard let region = state.coordinateRegion,
//            let location = state.currentUserLocation
//      else {
//        return .none
//      }
//      state.userCoordinateRegion = MKCoordinateRegion(center: .init(
//        latitude: location.coordinate.latitude,
//        longitude: location.coordinate.longitude
//      ), span: region.span)
//      return .none
//    case let .didChangeCoordiateRegion(region):
//      state.coordinateRegion = region
//      return .none
//    case let .fetchResponse(.success(places)):
//      return Effect.run { send in
//        await send(
//          Action.syncPlaces(
//            TaskResult {
//              try await self.syncPlaces(places)
//            }
//          )
//        )
//      }
//    case let .fetchResponse(.failure(error)):
//      self.alertMessageClient.showMessage(
//        alertMessageError(error: error),
//        .destructive
//      )
//      return .none
//    case let .observeLocal(.success(places)):
//      state.places = places
//      return .none
//    case .observeLocal(.failure):
//      return .none
//    case .showDetail:
//      return .none
//    case let .observeFilter(filter):
//      return Effect.publisher {
//        self.observeMapData(filter)
//          .removeDuplicates()
//          .castToResult()
//          .map(Action.observeLocal)
//      }
//      .cancellable(id: ObserveId())
//    case .syncPlaces:
//      return .none
//    case .didDeselect:
//      return .none
//    case let .zoom(lat, lng):
//      guard let coordinateRegion = state.coordinateRegion else {
//        return .none
//      }
//      let multiplier = coordinateRegion.span.latitudeDelta > 0.5 ? 0.1 : 0.3
//      let newLatitudeDelta = coordinateRegion.span.latitudeDelta * multiplier
//      let newLongitudeDelta = coordinateRegion.span.longitudeDelta * multiplier
//      state.userCoordinateRegion = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
//        span: MKCoordinateSpan(
//          latitudeDelta: newLatitudeDelta,
//          longitudeDelta: newLongitudeDelta
//        )
//      )
//      return .none
//    case .observeAuthStatus:
//      return .merge(
//        Effect.run(operation: { send in
//          for await location in self.locationManagerClient.startUpdateLocation()
//            .compactMap({ $0 })
//          {
//            await send(Action.updateLocation(location))
//          }
//        }),
//        Effect.run(operation: { send in
//          for try await placeFilter in self.observePlaceFilter().removeDuplicates() {
//            await send(.observeFilter(placeFilter))
//          }
//        })
//      )
//    }
//  }
//}
//
public struct MapVisualKitView: UIViewControllerRepresentable {
	let store: MapVisualViewController.Store

  public init(store: MapVisualViewController.Store) {
    self.store = store
  }

  public func makeUIViewController(context: Context) -> UIViewController {
    MapVisualViewController(store: self.store)
  }

  public func updateUIViewController(
    _ uiViewController: UIViewController,
    context: Context
  ) {}
}
