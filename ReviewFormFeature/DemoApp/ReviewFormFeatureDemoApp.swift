import ReviewFormFeature
import SwiftUI

@main
struct ReviewFormFeatureDemoApp: App {
  var body: some Scene {
    WindowGroup {
      ReviewFormView(
        carBrands: [],
        hasCarGarage: false
      )
    }
  }
}
