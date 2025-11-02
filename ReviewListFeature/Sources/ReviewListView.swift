import APIClient
import DatabaseClient
import Models
import SwiftUI

public struct ReviewListView: View {
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.apiClient) var apiClient

  let placeId: Int
  let pageSize = 20
  public init(
    placeId: Int
  ) {
    self.placeId = placeId
  }

  public var body: some View {
    InfiniteListView(
      store: InfiniteListStore<ReviewItem, Int, ReviewPageResponse>(
        fetchClosure: { cursor in
          try await self.apiClient.call(
            route: .reviewList(
              pageNumber: cursor ?? 1,
              pageSize: self.pageSize,
              branchId: 1
            ),
            as: ReviewPageResponse.self
          )
        },
        observeAsyncStream: {
          self.databaseClient.reviewDB.observe(
            1
          )
        },
        parseResponse: { response in
          let nextPage = response.items.count >= self.pageSize
            ? response.page + 1 : response.page
          return (
            mapResponseToItems(response),
            nextPage
          )
        },
        syncItems: { items, _ in
          try await self.databaseClient.reviewDB.syncItemsByBranchId(
            self.placeId,
            items
          )
        },
        clearItems: {
          try await self.databaseClient.reviewDB.clearByBranchId(1)
        },
      ),
      shimmerContent: {
        ForEach(ReviewItem.shimmerList(count: 20)) { placeholder in
          ReviewItemView(item: placeholder, onTapImage: { _ in })
            .redacted(reason: .placeholder)
            .disabled(true)
            .shimmer()
        }
      },
      itemContent: { item in
        ReviewItemView(item: item) { _ in }
      }
    )
    .task {}
  }
}

public func mapResponseToItems(_ pageResponse: ReviewPageResponse) -> [ReviewItem] {
  pageResponse.items.map { item in
    ReviewItem(
      id: item.id,
      text: item.text,
      fullName: item.reviewerName,
      profileImage: item.reviewerProfileImage.flatMap({ URL(string: $0) }),
      givenRate: item.givenStar,
      images: item.images.map({
        ReviewItem.Image(id: $0.id, url: $0.url)
      }),
      createdDate: item.createdDate,
      carBrands: item.brandCars.map({ carBrand in
        .init(id: carBrand.id, displayName: carBrand.displayName)
      })
    )
  }
}
