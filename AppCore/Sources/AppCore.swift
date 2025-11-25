import AccessTokenClient
import AccessTokenClientLive
import APIClient
import APIClientLive
import AuthProvidersClient
import AuthProvidersClientLive
import BannerCenterModule
import BannerToastComponent
import Configs
import ConfigsLive
import DatabaseClient
import DatabaseClientLive
import LocationManagerClient
import LocationManagerClientLive
import PlaceStore
import Router
import RouterLive
import SwiftUI

@main
struct AppCore: App {
  @Environment(\.scenePhase) private var scenePhase
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  //	@AppStorage("appLanguage") private var appLanguage =
  //	Locale.current.language.languageCode?.identifier ?? "en"

  @AppStorage("appLanguage") private var appLanguage = "en"

  @State var router: Router
  @State var apiClient: APIClient
  @State var accessTokenClient: AccessTokenClient
  @State var databaseClient: DatabaseClient
  @State var locationManagerClient: LocationManagerClient
  @State var authProvidersClient: AuthProvidersClient

  @State var placeStore: PlaceStore

  @StateObject var bannerCenter = BannerCenter()

  public init() {
    #if DEBUG
      let config = Configs.dev
    #else
      let config = Configs.prod
    #endif
    self.router = .liveValue
    let accessTokenClient = AccessTokenClient.live(
      accessGroup: config.appGroup.accessGroup,
      service: config.appGroup.identifier
    )
    self.accessTokenClient = accessTokenClient
    let apiClientLive = APIClient.live(
      url: config.mobileAPI.hostName,
      getToken: accessTokenClient.accessToken,
      updateToken: accessTokenClient.updateAccessToken
    )
    self.apiClient = apiClientLive
    self.authProvidersClient = AuthProvidersClient.live(
      googleOAuthClientId: config.googleOAuthClientId
    )
    self.databaseClient = .liveValue
    self.locationManagerClient = .liveValue

    self.placeStore = PlaceStore(
      apiClient: apiClientLive,
      locationStreamCallback: LocationManagerClient.liveValue.locationStream,
      syncLocalCallback: DatabaseClient.liveValue.syncPlaces
    )
    self.appDelegate.authProvidersClient = self.authProvidersClient
    _ = self.databaseClient.migrate()
  }

  var body: some Scene {
    WindowGroup {
      Router.liveValue.route(.app(.root))
        .environmentObject(self.bannerCenter)
        .environment(\.router, self.router)
        .environment(\.authProvidersClient, self.authProvidersClient)
        .environment(\.apiClient, self.apiClient)
        .environment(\.accessTokenClient, self.accessTokenClient)
        .environment(\.databaseClient, self.databaseClient)
        .environment(\.locationManagerClient, self.locationManagerClient)
        .environment(self.placeStore)
        .environment(\.locale, Locale(identifier: self.appLanguage))
        .onOpenURL { url in
          self.authProvidersClient.googleAuth.handleURL(url)
        }
        .onChange(of: self.scenePhase) { _, phase in
          if phase == .active {
            BannerOverlay.shared.install(center: self.bannerCenter)
          }
        }
    }
  }
}
