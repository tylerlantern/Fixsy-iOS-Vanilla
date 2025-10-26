import Router
import SwiftUI

enum Tab: Equatable {
  case home
  case explore
  case chatList
  case profile
}

public struct TabContainerView: View {
  @State var currentTab: Tab = .home
  @Environment(\.router) var router

  public init() {}

  public var body: some View {
    TabView(
      selection: self.$currentTab
    ) {
      self.router.route(.app(.root))
        .navigationViewStyle(.stack)
        .navigationBarHidden(true)
        .tag(Tab.home)
        .tabItem {
          Label("Home", systemImage: "house.fill")
        }
    }
  }
}
