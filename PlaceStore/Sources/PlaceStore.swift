import SwiftUI
import Models
import DatabaseClient
import APIClient
import MapKit
import Observation

@Observable
public class PlaceStore  {
	
	public var filter: PlaceFilter = .identity
	
	let eventChannel = AsyncStream.makeStream(of: Event.self)
	let locationStreamCallback: @Sendable() -> AsyncStream<[CLLocation]>
	let syncLocalCallback: ([Place]) async throws -> Int
	
	@ObservationIgnored var taskCancelletions : Set<Task<(), Error>> = []
	
	let apiClient : APIClient
	public init(
		apiClient : APIClient,
		locationStreamCallback :  @escaping @Sendable ()  -> AsyncStream<[CLLocation]>,
		syncLocalCallback: @escaping @Sendable ([Place]) async throws -> Int,
	) {
		self.apiClient = apiClient
		self.locationStreamCallback = locationStreamCallback
		self.syncLocalCallback = syncLocalCallback
	}
	
	public func fetchRemote() async throws {
		let mapResponse = try await self.apiClient.call(
			route: .mapData,
			as: MapResponse.self
		)
		_ = try await self.syncLocalCallback(self.toPlaces(mapResponse.branches))
	}
	
	private func toPlaces(_ items: [PlaceResponse]) -> [Place] {
		items.map { item in
			let oct = item.openCloseTime
			return Place(
				id: item.id,
				name: item.name,
				latitude: item.latitude,
				longitude: item.longitude,
				address: item.address,
				hasMotorcycleGarage: item.hasMotorcycleGarage,
				hasInflationStation: item.hasInflationStation,
				hasWashStation: item.hasWashStation,
				hasPatchTireStation: item.hasPatchTireStation,
				hasCarGarage: item.hasCarGarage,
				averageRate: item.averageRate,
				carGarage: item.carGarage.map({ garage in
					let brands = garage.brands.map { brand in
						CarBrand(id: brand.id, displayName: brand.displayName)
					}
					return Place.CarGarage.init(brands: brands)
				}),
				openCloseTime: Place.OpenCloseTime(
					mondayOpen: oct.mondayOpen,
					mondayClose: oct.mondayOpen,
					tuesdayOpen: oct.tuesdayOpen,
					tuesdayClose: oct.tuesdayClose,
					wednesdayOpen: oct.wednesdayOpen,
					wednesdayClose: oct.wednesdayClose,
					thursdayOpen: oct.tuesdayOpen,
					thursdayClose: oct.tuesdayClose,
					fridayOpen: oct.fridayOpen,
					fridayClose: oct.fridayClose,
					saturdayOpen: oct.saturdayOpen,
					saturdayClose: oct.saturdayClose,
					sundayOpen: oct.sundayOpen,
					sundayClose: oct.sundayClose,
				),
				images: item.images.map({ image in
					Place.Image(
						id: image.id,
						url: image.url
					)
				}),
				contributorName: item.contributorName
			)
		}
	}
	
}

public enum Event {
	case places([Place])
}
