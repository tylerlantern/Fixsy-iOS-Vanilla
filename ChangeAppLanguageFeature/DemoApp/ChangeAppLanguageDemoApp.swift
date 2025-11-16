import AccessTokenClient
import APIClient
import APIClientLive
import Configs
import ChangeAppLanguageFeature
import SwiftUI

@main
struct ChangeApplicationLanguageDemoApp: App {

  public init() {}

  var body: some Scene {
    WindowGroup {
			ChangeApplicationLanguageView()
    }
  }
}
