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
      self.router.route(.home(.root))
        .navigationViewStyle(.stack)
        .navigationBarHidden(true)
        .tag(Tab.home)
        .tabItem {
          Label("Home", systemImage: "house.fill")
        }

      self.router.route(.explore(.root))
        .navigationViewStyle(.stack)
        .navigationBarHidden(true)
        .tag(Tab.explore)
        .tabItem {
          Label("Explore", systemImage: "magnifyingglass")
        }

      self.router.route(.chat(.root))
        .navigationViewStyle(.stack)
        .navigationBarHidden(true)
        .tag(Tab.chatList)
        .tabItem {
          Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
        }

      self.router.route(.profile(.root))
        .navigationViewStyle(.stack)
        .navigationBarHidden(true)
        .tag(Tab.profile)
        .tabItem {
          Label("Profile", systemImage: "person.crop.circle.fill")
        }
    }
  }
}
