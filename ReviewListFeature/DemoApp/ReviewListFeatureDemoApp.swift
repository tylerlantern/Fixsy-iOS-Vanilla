import ReviewListFeature
import SwiftUI
import Models
import APIClient
import APIClientLive
import DatabaseClient
import DatabaseClientLive
import AccessTokenClient
import Configs
import ConfigsLive

@main
struct ReviewListFeatureDemoApp: App {
	
	@State var apiClient: APIClient
	@State var databaseClient: DatabaseClient
	@State var accessTokenClient : AccessTokenClient
	
	var placeId = 2;
	
	public init() {
		let accessTokenClient = AccessTokenClient.live(
			accessGroup: Configs.live.appGroup.accessGroup,
			service: Configs.live.appGroup.identifier
		)
		self.accessTokenClient = accessTokenClient
		let apiClientLive = APIClient.live(
			url: Configs.live.mobileAPI.hostName,
			getToken: accessTokenClient.accessToken,
			updateToken: accessTokenClient.updateAccessToken
		)
		self.apiClient = apiClientLive
		self.databaseClient = DatabaseClient.liveValue
		_ = self.databaseClient.migrate()
	}
	
  var body: some Scene {
    WindowGroup {
			ReviewListView(
				infiniteListStore: InfiniteListStore<
				ReviewItem,
				Int,
				ReviewPageResponse>(
					fetchClosure: { cursor in
						return try await self.apiClient.call(
							route: .reviewList(
								pageNumber: cursor ?? 1,
								pageSize: 20,
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
						return response.items.m
					},
					syncItems: <#T##([ReviewItem]) async throws -> ()#>,
					clearItems: <#T##() async throws -> ()#>
				)
			)
    }
  }
}
