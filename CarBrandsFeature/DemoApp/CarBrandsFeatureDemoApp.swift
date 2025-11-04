import CarBrandsFeature
import APIClient
import AccessTokenClient
import DatabaseClient
import SwiftUI
import Configs
import ConfigsLive
import DatabaseClientLive
import APIClientLive

@main
struct CarBrandsFeatureDemoApp: App {
	
	@State var apiClient: APIClient
	@State var databaseClient: DatabaseClient
	@State var accessTokenClient: AccessTokenClient
	
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
	}
	
  var body: some Scene {
		WindowGroup {
			CarBrandsView(selectedIds: [])
				.environment(\.apiClient, self.apiClient)
				.environment(\.accessTokenClient, self.accessTokenClient)
				.environment(\.databaseClient, self.databaseClient)
		}
  }
}
