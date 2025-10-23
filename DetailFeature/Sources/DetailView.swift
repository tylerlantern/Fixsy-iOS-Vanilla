import APIClient
import DatabaseClient
import MapKit
import Models
import Router
import SwiftUI

public struct DetailView: View {
  enum Destination: Hashable {
    case comment
  }

  enum Display {
    case shimmer, render(Place)
  }

  @Environment(\.router) var router
  @Environment(\.databaseClient) var databaseClient
  let placeId: Int

  @State var selectedTab: SwipableTabView.Tab = .info
  @State var display: Display = .shimmer

  let dismiss: () -> ()
  let onTapReviewButton: () -> ()

  public init(
    placeId: Int,
    dismiss: @Sendable @escaping () -> (),
    onTapReviewButton: @Sendable @escaping () -> ()
  ) {
    self.placeId = placeId
    self.dismiss = dismiss
    self.onTapReviewButton = onTapReviewButton
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
          onTapReviewButton: self.onTapReviewButton
        )
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
