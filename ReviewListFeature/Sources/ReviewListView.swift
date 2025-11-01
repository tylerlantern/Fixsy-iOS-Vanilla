import DatabaseClient
import Models
import SwiftUI
import APIClient

public struct ReviewListView: View {
	@Environment(\.databaseClient) var databaseClient
	
	@State private var infiniteListStore : InfiniteListStore<
		ReviewItem,
		Int,
		ReviewPageResponse
	>
	
	public init(
		infiniteListStore: InfiniteListStore<ReviewItem, Int, ReviewPageResponse>
	) {
		self.infiniteListStore = infiniteListStore
	}
	
	public var body: some View {
		GeometryReader { _ in
			ScrollView {
				
			}
			.refreshable {}
		}
		.task {}
	}
}

public func mapResponseToItems(_ pageResponse : ReviewPageResponse) -> [ReviewItem] {
	return pageResponse.items.map { item in
		return ReviewItem(
			id: item.id,
			text: item.text,
			fullName: item.reviewerName,
			profileImage: item.reviewerProfileImage,
			givenRate: item.givenStar,
			images: item.images.map(
				{ image in
					return ReviewItem.Image.init(id: image.id, url: image.url)
				}
			),
			createdDate: item.createdDate,
			carBrands: item.brandCars.map({ carBrand in
				return	.init(id: carBrand.id, displayName: carBrand.displayName)
			})
		)
	}
}
