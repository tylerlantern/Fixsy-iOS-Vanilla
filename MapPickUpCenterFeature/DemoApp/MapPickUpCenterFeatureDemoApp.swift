import MapKit
import MapPickUpCenterFeature
import SwiftUI

@main
struct MapPickUpCenterFeatureDemoApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        MapPickUpCenterView(
          coordinateRegion: .init(
            center: .init(latitude: 35.681236, longitude: 139.767125),
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
          )
        )
      }
    }
  }
}
