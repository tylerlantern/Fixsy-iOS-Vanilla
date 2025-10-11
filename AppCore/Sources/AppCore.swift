import Router
import RouterLive
import SwiftUI
import APIClient
import APIClientLive
import AccessTokenClient
import AccessTokenClientLive
import Configs
import ConfigsLive

@main
struct AppCore: App {
	 
	@State var apiClient : APIClient
	@State var accessTokenClient : AccessTokenClient
	
	public init(){
		self.accessTokenClient = .liveValue
		self.apiClient = .live(
			url: Configs.live.mobileAPI.hostName,
			getToken: AccessTokenClient.liveValue.accessToken,
			updateToken: AccessTokenClient.liveValue.updateAccessToken
		)
	}
	
  var body: some Scene {
    WindowGroup {
		Router.liveValue.route(.home(.root))
        .environment(\.router, Router.liveValue)
				.environment(\.apiClient, self.apiClient)
				.environment(\.accessTokenClient,self.accessTokenClient)
    }
  }
}
