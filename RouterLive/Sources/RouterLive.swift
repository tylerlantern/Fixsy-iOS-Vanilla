import ChatListFeature
import CommentFeature
import DatabaseClient
import DetailFeature
import ExpandedCommentFeature
import ExploreFeature
import HomeFeature
import LocationManagerClient
import ProfileFeature
import Router
import SearchFeature
import SwiftUI
import TabContainerFeature

extension Router {
  public static let liveValue: Router = .init { route in
    AnyView(RouteView(route: route))
  }
}

struct RouteView: View {
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.locationManagerClient) var locationManagerClient

  let route: Route

  var body: some View {
    switch self.route {
    case .tabContainer:
      TabContainerView()
    case .home(.root):
      HomeView(
        placeStore: .init(
          observeLocalDataCallback: self.databaseClient.observeMapData,
          syncLocalCallback: self.databaseClient.syncPlaces
        )
      )
    case let .home(
      .detail(.root(navPath, title))
    ):
      DetailView(navPath: navPath, title: title)
    case let .home(
      .search(
        detent,
        onFocusSearch,
        onTapItemById
      )
    ):
      SearchView(
        store: .init(
          placeCallback: self.databaseClient.observeMapData,
          filterCallback: self.databaseClient.observePlaceFilter,
          locationCallback: self.locationManagerClient.locationStream
        ),
        detent: detent,
        onFocusSearch: onFocusSearch,
        onTapItemById: onTapItemById
      )
    case let .home(.detail(.comment(.root(navPath)))):
      CommentView(navPath: navPath)
    case let .home(.detail(.comment(.expandedComment(.root(navPath))))):
      ExpandedCommentView(navPath: navPath)
    case .explore(.root):
      ExploreView()
    case .explore:
      EmptyView()
    case .chat(.root):
      ChatListView()
    case .chat(.detail(_)):
      EmptyView()
    case .profile(.root):
      ProfileView()
    }
  }
}
