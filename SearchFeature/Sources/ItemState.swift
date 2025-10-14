import Models
import SwiftUI

struct Item : Identifiable {
	static func parseService (
		_ place : Place
	) -> Service {
		if place.hasCarGarage {
			return .car
		} else if place.hasMotorcycleGarage {
			return .motorcycle
		} else if place.hasPatchTireStation {
			return .patchTire
		} else if place.hasWashStation {
			return .wash
		} else if place.hasInflationStation {
			return .inflationPoint
		} else  {
			return .none
		}
	}
	
	static func parseImage(
		_ place : Place
	) -> SwiftUI.Image {
		if place.hasCarGarage {
			return  SearchFeatureAsset.Images.carIcon.swiftUIImage
		} else if place.hasMotorcycleGarage {
			return SearchFeatureAsset.Images.motorcycleIcon.swiftUIImage
		} else if place.hasPatchTireStation {
			return SearchFeatureAsset.Images.patchTireIcon.swiftUIImage
		} else if place.hasWashStation {
			return SearchFeatureAsset.Images.waterDropIcon.swiftUIImage
		} else if place.hasInflationStation {
			return SearchFeatureAsset.Images.psiIcon.swiftUIImage
		} else  {
			return Image(systemName: "exclamationmark.circle")
		}
	}
	
	enum Service {
		case car
		case motorcycle
		case patchTire
		case wash
		case inflationPoint
		case none
	}
	
	let id : Int
	let name : String
	let image : SwiftUI.Image
	let service : Service
	let address : String
	let distance : Double?
	
	var displayKmAways : String? {
		guard let distance = distance else {
			return nil
		}
		return distance.formatted(.number.precision(.fractionLength(0...2)))
	}
	
	init(
		id : Int,
		name : String,
		image: SwiftUI.Image,
		service: Service,
		address : String,
		distance : Double?
	) {
		self.id = id
		self.name = name
		self.image = image
		self.service = service
		self.address = address
		self.distance = distance
	}
	
}
