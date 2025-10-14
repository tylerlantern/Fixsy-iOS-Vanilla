
import SearchFeature
import SwiftUI

@main
struct HomeFeatureDemoApp: App {
  var body: some Scene {
    WindowGroup {
      SearchView.init(onTapItemById: { _ in })
    }
  }
}
