import Router
import SwiftUI

public struct DetailView: View {
  enum Destination: Hashable {
    case comment
  }

  @Environment(\.router) var router
  @Binding var navPath: NavigationPath
  let title: String

  public init(
    navPath: Binding<NavigationPath>,
    title: String
  ) {
    self._navPath = navPath
    self.title = title
  }

  public var body: some View {
    VStack {
      Text("Hello, Home's Detail \(self.title)!")
      Button.init {
        self.navPath.append(Destination.comment)
      } label: {
        Text("Go to Comment")
      }
    }
    .navigationDestination(for: Destination.self) { destination in
      let route = switch destination {
      case .comment:
        Route.home(
          .detail(
            .comment(.root(self.$navPath))
          )
        )
      }
      self.router.route(route)
    }
  }
}

#Preview {
  DetailView(
    navPath: .constant(.init()),
    title: "MOCKSDAD"
  )
}
