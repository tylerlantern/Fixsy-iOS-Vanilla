import SwiftUI
import Models
import MapKit
import AsyncAlgorithms

@MainActor
class SearchStore: ObservableObject {
	
	enum Tap {
		case motorcycle
		case car
		case inflationPoint
		case patchTire
		case washStation
	}
	
	@Published var filter : PlaceFilter = .identity
	@Published var items : [Item] = []
	@Published var searchText: String = ""
	
	let locationEvent = AsyncStream.makeStream(of : CLLocation.self)
	
	private var observePlacesTask: Task<(), Error>?
	private var observeFilterTask : Task<(), Error>?
	private var transformTask : Task<(),Error>?
	
	func observePlaceFilter(
		callback : @escaping () -> AsyncThrowingStream<PlaceFilter, Error>
	) {
		observeFilterTask = Task {
			for try await localFilter in callback() {
				self.filter = localFilter
			}
		}
	}
	
	func observeLocalData(
		placeCallback: @escaping @Sendable (PlaceFilter,String) -> AsyncThrowingStream<[Place], Error>,
		locationCallback : AsyncStream<CLLocation?>
	) {
		observePlacesTask = Task {
			let placesSeq = placeCallback(self.filter,self.searchText)
			let locSeq    = locationCallback
			for try await (places, location) in combineLatest(placesSeq, locSeq) {
				self.transformTask?.cancel()
				self.transformTask = Task {
					let sortedItems = places.map({ place in
						guard let userLoc = location else {
							return (
								Item(
									id : place.id,
									name: place.name,
									image: Item.parseImage(place),
									service: Item.parseService(place),
									address: place.address,
									distance: nil
								)
							)
						}
						let distance = haversine(
							lat1: userLoc.coordinate.latitude,
							lon1: userLoc.coordinate.longitude,
							lat2: place.latitude,
							lon2: place.longitude
						)
						
						return Item(
							id : place.id,
							name: place.name,
							image: Item.parseImage(place),
							service: Item.parseService(place),
							address: place.address,
							distance: distance
						)
					})
						.sorted { item1, item2 in
							guard let distance1 = item1.distance,
										let distance2 = item2.distance else {
								return true
							}
							return distance1 > distance2
						}
					await MainActor.run {
						self.items = sortedItems
					}
				}
				
			}
		}
	}
	
	deinit {
		self.observePlacesTask?.cancel()
		self.observeFilterTask?.cancel()
		self.transformTask?.cancel()
	}
	
	func handleOnTap(_ tap : Tap) {

	}
	
}

func haversine(
	lat1: Double,
	lon1: Double,
	lat2: Double,
	lon2: Double
) -> Double {
	let radius: Double = 6_371
	let latDelta = (lat2 - lat1) * .pi / 180
	let lonDelta = (lon2 - lon1) * .pi / 180
	
	let a = sin(latDelta / 2) * sin(latDelta / 2) +
	cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
	sin(lonDelta / 2) * sin(lonDelta / 2)
	
	let c = 2 * atan2(sqrt(a), sqrt(1 - a))
	return radius * c
}


