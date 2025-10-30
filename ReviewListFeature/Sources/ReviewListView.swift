import DatabaseClient
import Models
import SwiftUI

public struct ReviewListView: View {
  @Environment(\.databaseClient) var databaseClient

  @State private var items: [ReviewItem] = []

  public init() {}

  public var body: some View {
    GeometryReader { _ in
      ScrollView {
        LazyVStack(alignment: .center) {
          ForEach(self.items, id: \.id) { item in
            ReviewItemView(
              item: item,
              onTapImage: { _ in }
            )
            .onAppear {}
          }
        }
      }
      .refreshable {}
    }
    .task {}
  }
}
