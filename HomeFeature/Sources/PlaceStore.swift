import Foundation
import APIClient
import Models

public class PlaceStore : ObservableObject {
	
	@Published var places : [Place] = []
	
	public init() {}
	
	public  func fetchRemote (
		callNetwork : () async throws -> ([PlaceResponse])
	) async {
		do {
			let placeRespone =  try await callNetwork()
		} catch (let e) {
			
		}
	}
	
	
}
