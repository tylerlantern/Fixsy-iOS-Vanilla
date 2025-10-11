import Foundation

public typealias ReviewPageResponse = PageResponse<ReviewItemResponse>

public struct ReviewItemResponse: Decodable, Equatable {
	public let id: Int
	public let text: String
	public let reviewerName: String
	public let reviewerProfileImage: URL?
	public let createdDate: Date
	public let givenStar: Double
	public let brandCars: [CarBrandResponse]
	public let images: [ImageResponse]
}


