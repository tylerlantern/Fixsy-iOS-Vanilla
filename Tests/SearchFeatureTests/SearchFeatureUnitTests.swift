@testable import SearchFeature
import Models
import Testing
import MapKit

@MainActor
struct SortItemsByNearestTests {

	// Helpers
	private func place(id: Int, name: String, lat: Double, lon: Double) -> Place {
		Place(
			id: id,
			name: name,
			latitude: lat,
			longitude: lon,
			address: "addr",
			hasMotorcycleGarage: false,
			hasInflationStation: false,
			hasWashStation: false,
			hasPatchTireStation: false,
			hasCarGarage: false,
			averageRate: 0,
			carGarage: nil,
			openCloseTime: .empty,
			images: [],
			contributorName: "Example Contributor"
		)
	}

	// MARK: - 1) Sorts ascending by distance when user location is present
	@Test
	func sortsAscending_withUserLocation() {
		// User in Bangkok
		let userLoc = CLLocation(latitude: 13.7563, longitude: 100.5018)

		// Pathum Thani (near Bangkok) vs Chiang Mai (far)
		let near  = place(id: 1, name: "Pathum Thani", lat: 14.017,  lon: 100.530)
		let far   = place(id: 2, name: "Chiang Mai",   lat: 18.7883, lon: 98.9853)

		let items = sortItesmByNearest([userLoc], places: [far, near])

		// Expect nearest first
		#expect(items.map(\.id) == [1, 2])
		// Distances should be non-nil and ascending
		#expect(items[0].distance != nil && items[1].distance != nil)
		#expect(items[0].distance! <= items[1].distance!)
	}

	// MARK: - 2) When no user location, keep order and put nil distances
	@Test
	func noLocation_keepsOrderAndNilDistances() {
		let a = place(id: 10, name: "A", lat: 15.0, lon: 100.0)
		let b = place(id: 20, name: "B", lat: 16.0, lon: 101.0)

		let items = sortItesmByNearest([], places: [a, b])

		#expect(items.map(\.id) == [10, 20])               // stable order
		#expect(items[0].distance == nil && items[1].distance == nil)
	}

}
