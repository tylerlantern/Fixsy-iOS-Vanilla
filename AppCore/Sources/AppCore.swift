import Router
import RouterLive
import SwiftUI

@main
struct AppCore: App {
  var body: some Scene {
    WindowGroup {
		Router.liveValue.route(.home(.root))
        .environment(\.router, Router.liveValue)
    }
  }
}
