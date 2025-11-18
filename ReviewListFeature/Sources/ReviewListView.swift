import APIClient
import DatabaseClient
import Models
import Router
import SwiftUI

public struct ReviewListView: View {
  public enum SheetDisplay: Identifiable {
    case imagesInspector([URL], Int)

    public var id: String {
      switch self {
      case .imagesInspector:
        return "imagesInspector"
      }
    }

    @ViewBuilder
    func destination(
      router: Router
    ) -> some View {
      switch self {
      case let .imagesInspector(urls, idx):
        router.route(
          .app(
            .detail(
              .reviewList(
                .imagesInsepcter(
                  .root(
                    urls,
                    idx
                  )
                )
              )
            )
          )
        )
      }
    }
  }

  @Environment(\.databaseClient) var databaseClient
  @Environment(\.apiClient) var apiClient
  @Environment(\.router) var router

  @State private var sheet: SheetDisplay? = nil

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
              branchId: self.placeId
            ),
            as: ReviewPageResponse.self
          )
        },
        observeAsyncStream: {
          self.databaseClient.reviewDB.observe(
            self.placeId
          )
        },
        parseResponse: { response in
          if response.items.isEmpty, response.page == 1 {
            return ([], nil)
          }
          let nextPage = response.items.count >= self.pageSize
            ? response.page + 1
            : response.page
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
          ReviewItemView(item: placeholder, onTapImage: { _, _ in })
            .redacted(reason: .placeholder)
            .disabled(true)
            .shimmer()
        }
      },
      itemContent: { item in
        ReviewItemView(item: item) {
          urls, index in
          self.sheet = .imagesInspector(urls, index)
        }
      }
    )
    .fullScreenCover(
      item: self.$sheet,
      onDismiss: {
        self.sheet = nil
      },
      content: { sheet in
        sheet.destination(
          router: self.router
        )
      }
    )
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
