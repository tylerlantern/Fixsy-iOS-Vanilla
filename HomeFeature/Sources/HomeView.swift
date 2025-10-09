import Router
import SwiftUI
import Models
import MapKit
import APIClient

public struct HomeView: View {
	enum Destination: Hashable { case detail }
	
	@Environment(\.router) var router
	@Environment(\.apiClient) var apiClient
	
	@State var navPath = NavigationPath()
	@State var store: MapVisualViewController.Store
	@StateObject var placeStore : PlaceStore = .init()
	
	public init() {
		
		let (placeStream, placeCont) =
		AsyncStream.makeStream(of: [Place].self)
		
		let (userRegionStream, userRegionCont) =
		AsyncStream.makeStream(of: MKCoordinateRegion.self)
		
		let (requestSelectedIdStream, requestSelectedIdCont) =
		AsyncStream.makeStream(of: Int?.self)
		
		let (requestDeselectedIdStream, requestDeselectedIdCont) =
		AsyncStream.makeStream(of: Int?.self)
		
		let (viewDidloadStream, viewDidloadCont) =
		AsyncStream.makeStream(of: Void.self)
		
		let (zoomStream, zoomCont) =
		AsyncStream.makeStream(of: CLLocationCoordinate2D.self)
		
		let (didChangeRegionStream, didChangeRegionCont) =
		AsyncStream.makeStream(of: MKCoordinateRegion.self)
		
		let (didDeselectStream, didDeselectCont) =
		AsyncStream.makeStream(of: Void.self)
		
		self._store = State(
			initialValue:
				MapVisualViewController.Store(
					placeContinuation: placeCont,
					placeStream: placeStream,
					
					userCoordinateRegionContinuation: userRegionCont,
					userCoordinateRegionStream: userRegionStream,
					
					requestSelectedIdContinuation: requestSelectedIdCont,
					requestSelectedIdStream: requestSelectedIdStream,
					
					requestDeselectedIdContinuation: requestDeselectedIdCont,
					requestDeselectedIdStream: requestDeselectedIdStream,
					
					viewDidloadContinuation: viewDidloadCont,
					viewDidloadStream: viewDidloadStream,
					
					zoomContinuation: zoomCont,
					zoomStream: zoomStream,
					
					didChangeCoordiateRegionContinuation: didChangeRegionCont,
					didChangeCoordiateRegionStream: didChangeRegionStream,
					
					didDeselectContinuation: didDeselectCont,
					didDeselectStream: didDeselectStream
				)
		)
	}
	
	public var body: some View {
		NavigationStack(path: self.$navPath) {
			VStack {
				MapVisualKitView(store: self.store)
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
			}
		}
	}
}

