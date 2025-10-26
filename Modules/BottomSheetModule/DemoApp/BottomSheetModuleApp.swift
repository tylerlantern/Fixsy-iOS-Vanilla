import BottomSheetModule
import SwiftUI

@main
struct BottomSheetModuleApp: App {
  @State var showSheet: Bool = false

  var body: some Scene {
    WindowGroup {
      VStack {
        Text("Hello Hello Hello")
      }
      .bottomSheet {
        Text("INSIDE")
      }
    }
  }
}
