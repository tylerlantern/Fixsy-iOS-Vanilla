import AccessTokenClient
import AccessTokenClientLive
import APIClient
import APIClientLive
import Configs
import ConfigsLive
import DatabaseClient
import DatabaseClientLive
import LocationManagerClient
import LocationManagerClientLive
import Router
import RouterLive
import SwiftUI
import PlaceStore
import PlaceStore

@main
struct AppCore: App {
  @State var router: Router
  @State var apiClient: APIClient
  @State var accessTokenClient: AccessTokenClient
  @State var databaseClient: DatabaseClient
  @State var locationManagerClient: LocationManagerClient

	@State var placeStore : PlaceStore
	
  public init() {
    self.router = .liveValue
    self.accessTokenClient = .liveValue
		let apiClientLive = APIClient.live(
			url: Configs.live.mobileAPI.hostName,
			getToken: AccessTokenClient.liveValue.accessToken,
			updateToken: AccessTokenClient.liveValue.updateAccessToken
		)
    self.apiClient = apiClientLive
    self.databaseClient = .liveValue
    self.locationManagerClient = .liveValue
    
		self.placeStore = PlaceStore(
			apiClient: apiClientLive,
			locationStreamCallback: LocationManagerClient.liveValue.locationStream,
			syncLocalCallback: DatabaseClient.liveValue.syncPlaces
		)
		
		_ = self.databaseClient.migrate()
		
  }

  var body: some Scene {
    WindowGroup {
      Router.liveValue.route(.home(.root))
        .environment(\.router, self.router)
        .environment(\.apiClient, self.apiClient)
        .environment(\.accessTokenClient, self.accessTokenClient)
        .environment(\.databaseClient, self.databaseClient)
        .environment(\.locationManagerClient, self.locationManagerClient)
				.environment(placeStore)
    }
  }
}

