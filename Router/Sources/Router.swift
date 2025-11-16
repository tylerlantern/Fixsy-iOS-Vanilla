import Models
import SwiftUI

public enum Route {
  case tabContainer

  case app(HomeRoute)

  public enum HomeRoute {
    case root
    case search(
      SearchRoute
    )
    case detail(
      DetailRoute
    )
  }

  public enum SearchRoute {
    case root(
      detent: Binding<PresentationDetent>,
      onFocusSearch: () -> (),
      onTapItemById: (Int) -> ()
    )
    case socialSignIn
    case userProfile(UserProfile)
  }

  public enum UserProfile {
    case root
    case editingName(_ firstName: String, _ lastName: String)
  }

  public enum DetailRoute {
    case root(
      _ placeId: Int,
      _ dismiss: () -> ()
    )
    case comment(CommentRoute)
    case imagesInsepcter(ImagesInspectorRoute)
    case reviewList(ReviewListRouter)
    case socialSignIn
    case reviewForm(ReviewForm)
    public enum CommentRoute {
      case root(Binding<NavigationPath>)
      case expandedComment(ExpandedCommentRout)
      public enum ExpandedCommentRout {
        case root(Binding<NavigationPath>)
      }
    }
  }

  public enum ReviewForm {
    case root(
      _ placeId: Int,
      _ hasCarGarage: Bool
    )
    case carBrands(CarBrandsRouter)
    case imageInspector(ImagesInspectorRoute)
  }

  public enum CarBrandsRouter {
    case root(_ selectedIds: [Int], _ onTapSave: ([CarBrand]) -> ())
  }

  public enum ReviewListRouter {
    case root(_ placeId: Int)
		case imagesInsepcter(ImagesInspectorRoute)
  }

  public enum ImagesInspectorRoute {
    case root([URL], Int)
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
