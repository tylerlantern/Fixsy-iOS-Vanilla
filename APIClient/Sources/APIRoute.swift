import Foundation
import UIKit

public enum APIRoute: Equatable {
  case login(
    username: String,
    password: String
  )
  case signUp(
    firstName: String,
    lastName: String,
    username: String,
    password: String
  )
  case mapData
  case socialSignIn(
    token: String,
    provider: String
  )
  case reviewList(
    pageNumber: Int,
    pageSize: Int,
    branchId: Int
  )
  case refreshToken(
		accessToken : String,
		refreshToken : String
	)
  case socialSignin(
    token: String,
    provider: String
  )
  case socialSignup(
    token: String,
    provider: String,
    firstname: String,
    lastname: String,
    username: String,
    picture: String?
  )
}

public enum APIUserRoute: Equatable {
	case editName(firstName: String, lastName: String)
  case delete
  case carBrands
  case userProfile
  case logout
  case requestForm(
    name: String,
    service: Service,
    phoneCode: String,
    phoneNumber: String,
    latitude: Double,
    longitude: Double,
    images: [UIImage],
    carBrands: [CarBrand]
  )
  case reviewForm(
    branchId: Int,
    text: String,
    rate: Float,
    images: [UIImage],
    carBrands: [CarBrand]
  )
	
	public enum Service: String, Equatable, CaseIterable, Identifiable {
		public var id: String { self.rawValue }
		case
			car,
			motorcycle,
			inflatingPoint,
			wash,
			patchTire
	}
	public struct CarBrand: Equatable, Identifiable {
		public let id: Int
		public let displayName: String

		public init(id: Int, displayName: String) {
			self.id = id
			self.displayName = displayName
		}
	}
	
}
