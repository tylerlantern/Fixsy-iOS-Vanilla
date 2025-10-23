import ChatListFeature
import CommentFeature
import DatabaseClient
import DetailFeature
import ExpandedCommentFeature
import ExploreFeature
import HomeFeature
import ImagesInspectorFeature
import LocationManagerClient
import Models
import ProfileFeature
import Router
import SearchFeature
import SwiftUI
import TabContainerFeature
import SocialSignInFeature

extension Router {
  public static let liveValue: Router = .init { route in
    AnyView(RouteView(route: route))
  }
}

import Models
import SwiftUI

struct RouteView: View {
  let route: Route

  var body: some View {
    switch self.route {
    case .tabContainer:
      TabContainerView()

    case let .home(homeRoute):
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
				case .userProfile:
					Text("User Profile Screen")
				}
      case let .detail(detailRoute):
        switch detailRoute {
        case let .root(placeId, dismiss, onTapReviewButton):
          DetailView(
            placeId: placeId,
            dismiss: dismiss,
            onTapReviewButton: onTapReviewButton
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
          switch imageRoute {
          case let .root(
            urls, index
          ):
            ImagesInspectorView(
              urls: urls,
              initialIndex: index
            )
          }
        }
      }

    case let .explore(exploreRoute):
      switch exploreRoute {
      case .root:
        ExploreView()
      case .detail:
        EmptyView()
      }

    case let .chat(chatRoute):
      switch chatRoute {
      case .root:
        ChatListView()
      case .detail:
        EmptyView()
      }

    case let .profile(profileRoute):
      switch profileRoute {
      case .root:
        ProfileView()
      }
    }
  }
}
