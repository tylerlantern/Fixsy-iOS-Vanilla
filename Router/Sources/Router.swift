import Models
import SwiftUI

public enum Route {
  case tabContainer

  case home(HomeRoute)
  case explore(ExploreRoute)
  case chat(ChatRoute)
  case profile(ProfileRoute)

  public enum HomeRoute {
    case root
    case search(
      detent: Binding<PresentationDetent>,
      onFocusSearch: () -> (),
      onTapItemById: (Int) -> ()
    )
    case detail(
      DetailRoute
    )
    public enum DetailRoute {
      case root(
        _ placeId: Int,
        _ dismiss: () -> (),
        _ onTapReviewButton: () -> ()
      )
      case comment(CommentRoute)
      case imagesInsepcter(ImageInspectorRoute)

      public enum CommentRoute {
        case root(Binding<NavigationPath>)
        case expandedComment(ExpandedCommentRout)
        public enum ExpandedCommentRout {
          case root(Binding<NavigationPath>)
        }
      }
    }
  }

  public enum ImageInspectorRoute {
    case root([URL], _ index: Int)
  }

  public enum ExploreRoute {
    case root
    case detail(String)
  }

  public enum ChatRoute {
    case root
    case detail(String)
  }

  public enum ProfileRoute {
    case root
  }
}

public struct Router {
  public let route: (Route) -> AnyView

  public init(route: @escaping (Route) -> AnyView) {
    self.route = route
  }
}

extension Router: EnvironmentKey {
  public static let defaultValue: Router = .init { _ in
    AnyView(EmptyView())
  }
}

extension EnvironmentValues {
  public var router: Router {
    get { self[Router.self] }
    set { self[Router.self] = newValue }
  }
}
