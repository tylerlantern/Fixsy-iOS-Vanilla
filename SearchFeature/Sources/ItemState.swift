import Models
import SwiftUI

public struct Item: Identifiable, Equatable {
  static func parseService(
    _ place: Place
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
    } else {
      return .none
    }
  }

  static func parseImage(
    _ place: Place
  ) -> SwiftUI.Image {
    if place.hasCarGarage {
      return SearchFeatureAsset.Images.carIcon.swiftUIImage
    } else if place.hasMotorcycleGarage {
      return SearchFeatureAsset.Images.motorcycleIcon.swiftUIImage
    } else if place.hasPatchTireStation {
      return SearchFeatureAsset.Images.patchTireIcon.swiftUIImage
    } else if place.hasWashStation {
      return SearchFeatureAsset.Images.waterDropIcon.swiftUIImage
    } else if place.hasInflationStation {
      return SearchFeatureAsset.Images.psiIcon.swiftUIImage
    } else {
      return Image(systemName: "exclamationmark.circle")
    }
  }

  public enum Service {
    case car
    case motorcycle
    case patchTire
    case wash
    case inflationPoint
    case none
  }

  public let id: Int
  public let name: String
  public let image: SwiftUI.Image
  public let service: Service
  public let address: String
  public let displayDistance: String?

  init(
    id: Int,
    name: String,
    image: SwiftUI.Image,
    service: Service,
    address: String,
    displayDistance: String?
  ) {
    self.id = id
    self.name = name
    self.image = image
    self.service = service
    self.address = address
    self.displayDistance = displayDistance
  }
}
