import Router
import SwiftUI

public struct HomeView: View {
  enum Destination: Hashable {
    case detail
  }

  @Environment(\.router) var router
  @State var navPath = NavigationPath()

  public init() {}

  public var body: some View {
    NavigationStack(path: self.$navPath) {
      VStack {
        Text("Hello, Home!")
        Button.init {
          self.navPath.append(Destination.detail)
        } label: {
          Text("Go to Detail")
        }
      }
      .navigationDestination(for: Destination.self) { destination in
        let route = switch destination {
        case .detail:
          Route.home(
            .detail(
              .root(self.$navPath, "DAMN TAKE")
            )
          )
        }
        self.router.route(route)
      }
    }
  }
}
