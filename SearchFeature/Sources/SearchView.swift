import DatabaseClient
import LocationManagerClient
import MapKit
import SwiftUI

public struct SearchView: View {
  @State private var isFocused: Bool = false
  @StateObject private var store = SearchStore()
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.locationManagerClient) var locationManagerClient

  public let onTapItemById: (Int) -> ()

  public init(onTapItemById: @escaping (Int) -> ()) {
    self.onTapItemById = onTapItemById
  }

  public var body: some View {
    ScrollView(.vertical) {
      VStack {
        SearchFilterView(
          filter: self.$store.filter
        ) { tap in
          self.store.handleOnTap(tap)
        }

        ForEach(self.store.items) { item in
          ItemView(item: item) { id in
            self.onTapItemById(id)
          }
        }
      }
    }
    .safeAreaInset(edge: .top, spacing: 0) {
      HStack(spacing: 10) {
        TextField("Search…", text: self.$store.searchText)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(.gray.opacity(0.25), in: .capsule)

        Button {
          self.isFocused.toggle()
        } label: {
          ZStack {
            if self.isFocused {
              Image(systemName: "xmark")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
                .frame(width: 48, height: 48)
                .glassEffect(in: .circle)
                .transition(.blurReplace)
            } else {
              Text("BV")
                .font(.title2.bold())
                .frame(width: 48, height: 48)
                .foregroundStyle(.white)
                .background(.gray, in: .circle)
                .transition(.blurReplace)
            }
          }
        }
      }
      .padding(
        .horizontal, 18
      )
      .frame(height: 80)
      .padding(.top, 5)
    }
    .task {
      self.store.observePlaceFilter(
        callback: self.databaseClient.observePlaceFilter
      )
      //			let locStream: AsyncStream<CLLocation?> = AsyncStream { continuation in
      //				let child = Task {
      //					for await event in self.locationManagerClient.delegate() {
      //						if case let .didUpdateLocations(list) = event {
      //							_ = continuation.yield(list.last)
      //						}
      //					}
      //					continuation.finish()
      //				}
      //				continuation.onTermination = { _ in
      //					child.cancel()
      //				}
      //			}
      //			self.store.observeLocalData(
      //				placeCallback: self.databaseClient.observeMapData,
      //				locationCallback: locStream
      //			)
    }
  }
}

#if DEBUG

  #Preview {
    SearchView(onTapItemById: { _ in })
  }

#endif
