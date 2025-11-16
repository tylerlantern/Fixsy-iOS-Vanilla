import CarBrandsFeature
import ChatListFeature
import CommentFeature
import DatabaseClient
import DetailFeature
import EditingNameFeature
import ExpandedCommentFeature
import ExploreFeature
import HomeFeature
import ImagesInspectorFeature
import LocationManagerClient
import Models
import ProfileFeature
import ReviewFormFeature
import ReviewListFeature
import Router
import SearchFeature
import SocialSignInFeature
import SwiftUI
import TabContainerFeature
import UserProfileFeature

extension Router {
  public static let liveValue: Router = .init { route in
    AnyView(RouteView(route: route))
  }
}

struct RouteView: View {
  let route: Route

  var body: some View {
    switch self.route {
    case .tabContainer:
      TabContainerView()
    case let .app(homeRoute):
      switch homeRoute {
      case .root:
        HomeView()
      case let .search(searchRoute):
        switch searchRoute {
        case let .root(
          detent: detent,
          onFocusSearch: onFocusSearch,
          onTapItemById: onTapItemById
        ):
          SearchView(
            detent: detent,
            onFocusSearch: onFocusSearch,
            onTapItemById: onTapItemById
          )
        case .socialSignIn:
          SocialSignInView()
        case let .userProfile(userProfileRoute):
          switch userProfileRoute {
          case .root:
            UserProfileView()
          case let .editingName(firstName, lastName):
            EditingNameView(
              firstName: firstName,
              lastName: lastName
            )
          }
        }
      case let .detail(detailRoute):
        switch detailRoute {
        case let .reviewList(reviewListRouter):
          switch reviewListRouter {
          case let .root(placeId):
            ReviewListView(placeId: placeId)
					case let .imagesInsepcter(imageRoute):
						imageRoute.makeView()
          }
        case let .root(placeId, dismiss):
          DetailView(
            placeId: placeId,
            dismiss: dismiss
          )
        case let .comment(commentRoute):
          switch commentRoute {
          case let .root(navPath):
            CommentView(navPath: navPath)
          case let .expandedComment(expanded):
            switch expanded {
            case let .root(navPath):
              ExpandedCommentView(navPath: navPath)
            }
          }
        case let .imagesInsepcter(imageRoute):
					imageRoute.makeView()
        case .socialSignIn:
          SocialSignInView()
        case let .reviewForm(
          .root(placeId, hasCarGarage)
        ):
          ReviewFormView(
            placeId: placeId,
            hasCarGarage: hasCarGarage
          )
        case let .reviewForm(
          .imageInspector(imageInspectorRoute)
        ):
					imageInspectorRoute.makeView()
        case let .reviewForm(.carBrands(.root(selectedIds, onTapSave))):
          CarBrandsView(
            selectedIds: selectedIds,
            onTapSave: onTapSave
          )
        }
      }
    }
  }
}

extension Route.ImagesInspectorRoute {
		@ViewBuilder
		func makeView() -> some View {
				switch self {
				case let .root(urls, index):
						ImagesInspectorView(
								urls: urls,
								initialIndex: index
						)
				}
		}
}
