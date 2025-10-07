import Router
import SwiftUI

public struct CommentView: View {
  enum Destination: Hashable {
    case expandedComment
  }

  @Binding var navPath: NavigationPath
  @Environment(\.router) var router

  public init(
    navPath: Binding<NavigationPath>
  ) {
    self._navPath = navPath
  }

  public var body: some View {
    VStack {
      Text("Hello, Comment View!")
      Button {
        self.navPath.append(Destination.expandedComment)
      } label: {
        Text("Go to Expanded Comment View")
      }
    }
    .navigationDestination(for: Destination.self) { destination in
      let route = switch destination {
      case .expandedComment:
        Route.home(
          .detail(
            .comment(
              .expandedComment(.root(self.$navPath))
            )
          )
        )
      }
      self.router.route(route)
    }
  }
}
