import AccessTokenClient
import APIClient
import ContentHeightSheetComponent
import DatabaseClient
import MapKit
import Models
import Router
import SwiftUI

public struct DetailView: View {
  @State var presentedSocialSignInScreen: Bool = false
  @State var presentedReviewScreen: Bool = false

  enum Destination: Hashable {
    case comment
  }

  enum Display {
    case shimmer, render(Place)
  }

  @Environment(\.router) var router
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.accessTokenClient) var accessTokenClient

  let placeId: Int

  @State var selectedTab: SwipableTabView.Tab = .info
  @State var display: Display = .shimmer

  let dismiss: () -> ()

  public init(
    placeId: Int,
    dismiss: @Sendable @escaping () -> (),
  ) {
    self.placeId = placeId
    self.dismiss = dismiss
  }

  public var body: some View {
    VStack {
      switch self.display {
      case .shimmer:
        DetailComponentView(
          place: .shimmer(),
          dismiss: {},
          onTapReviewButton: {}
        )
        .redacted(reason: .placeholder)
      case let .render(place):
        DetailComponentView(
          place: place,
          dismiss: self.dismiss,
          onTapReviewButton: {
            handleOnTapReviewButton()
          }
        )
      }
    }
    .sheet(
      isPresented: self.$presentedSocialSignInScreen
    ) {
      self.router.route(
        .app(
          .detail(.socialSignIn)
        )
      )
      .adjustSheetHeightToContent()
    }
    .sheet(
      isPresented: self.$presentedReviewScreen
    ) {
      switch self.display {
      case let .render(place):
        self.router.route(
          .app(
            .detail(.reviewForm(.root(place.id, place.hasCarGarage)))
          )
        )
      case .shimmer:
        EmptyView()
      }
    }
    .task {
      Task {
        for try await place in self.databaseClient.observePlaceDetail(self.placeId) {
          if let place = place {
            self.display = .render(place)
          }
        }
      }
    }
  }
}

extension DetailView {
  func handleOnTapReviewButton() {
    Task {
      do {
        guard let _ = try await self.accessTokenClient.accessToken() else {
          self.presentedSocialSignInScreen = true
          return
        }
        self.presentedReviewScreen = true
      } catch {}
    }
  }
}
