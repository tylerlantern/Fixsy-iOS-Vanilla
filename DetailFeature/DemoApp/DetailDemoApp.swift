import DetailFeature
import Models
import SwiftUI

@main
struct DetailDemoApp: App {
  @State var showSheet: Bool = false

  var body: some Scene {
    WindowGroup {
      DetailView(
        place: Place.mock()
      )
    }
  }
}
