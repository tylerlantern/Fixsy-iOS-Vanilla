import Combine
import Models
import SwiftUI

public struct DatabaseClient {
	public init(
		migrate: @escaping () -> Result<(), Error>,
		userProfileDB: UserProfileDB,
		carBrandDB: CarBrandDB,
		observeMapData: @escaping @Sendable (PlaceFilter,String) -> AsyncThrowingStream<[Place], Error>,
		fetchMapData: @escaping (PlaceFilter, String) async throws -> [Place],
		syncPlaces: @escaping @Sendable ([Place]) async throws -> Int,
		deleteAll: @escaping () async throws -> (),
		observePlaceDetail: @escaping (Int) -> AsyncThrowingStream<Place?, Error>,
		observePlaceFilter: @escaping () -> AsyncThrowingStream<PlaceFilter, Error>,
		syncPlaceFilter: @escaping (PlaceFilter) async throws -> (),
		reviewDB: ReviewDB
	) {
		self.migrate = migrate
		self.userProfileDB = userProfileDB
		self.carBrandDB = carBrandDB
		self.observeMapData = observeMapData
		self.fetchMapData = fetchMapData
		self.syncPlaces = syncPlaces
		self.deleteAll = deleteAll
		self.observePlaceDetail = observePlaceDetail
		self.observePlaceFilter = observePlaceFilter
		self.syncPlaceFilter = syncPlaceFilter
		self.reviewDB = reviewDB
	}
	
	public var migrate: () -> Result<(), Error>
	public var userProfileDB: UserProfileDB
	public var carBrandDB: CarBrandDB
	public var observeMapData: @Sendable (PlaceFilter,String) -> AsyncThrowingStream<[Place], Error>
	public var fetchMapData: (PlaceFilter, String) async throws -> [Place]
	public var syncPlaces: @Sendable ([Place]) async throws -> Int
	public var deleteAll: () async throws -> ()
	public var observePlaceDetail: (Int) -> AsyncThrowingStream<Place?, Error>
	public var observePlaceFilter: () -> AsyncThrowingStream<PlaceFilter, Error>
	public var syncPlaceFilter: (PlaceFilter) async throws -> ()
	public var reviewDB: ReviewDB
}

extension DatabaseClient: EnvironmentKey {
	public static var defaultValue: Self {
		Self(
			migrate: {
				.success(())
			},
			userProfileDB: .test,
			carBrandDB: .test,
			observeMapData: { _,_ in fatalError("\(Self.self).observeMapData is unimplemented") },
			fetchMapData: { _, _ in fatalError("\(Self.self).fetchMapData is unimplemented") },
			syncPlaces: { _ in fatalError("\(Self.self).syncPlaces is unimplemented") },
			deleteAll: { fatalError("\(Self.self).deleteAll is unimplemented") },
			observePlaceDetail: { _ in fatalError("\(Self.self).observePlaceDetail is unimplemented") },
			observePlaceFilter: { fatalError("\(Self.self).observePlaceFilter is unimplemente") },
			syncPlaceFilter: { _ in fatalError("\(Self.self).syncPlaceFilter is unimplemented") },
			reviewDB: .test
		)
	}
}

extension EnvironmentValues {
	public var databaseClient: DatabaseClient {
		get { self[DatabaseClient.self] }
		set { self[DatabaseClient.self] = newValue }
	}
}
