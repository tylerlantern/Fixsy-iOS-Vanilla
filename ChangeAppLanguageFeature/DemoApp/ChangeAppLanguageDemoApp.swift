import AccessTokenClient
import APIClient
import APIClientLive
import ChangeAppLanguageFeature
import Configs
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
