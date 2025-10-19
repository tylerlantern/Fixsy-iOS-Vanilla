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

  @Environment(\.router) var router
  @Environment(\.databaseClient) var databaseClient
  @State var place: Place

  @State var selectedTab: SwipableTabView.Tab = .info

  public init(
    place: Place
  ) {
    self.place = place
  }

  func getServiceLocalizableKey() -> String {
    if self.place.hasCarGarage {
      return "Car Garage"
    } else if self.place.hasMotorcycleGarage {
      return "Motorcycle Garage"
    } else if self.place.hasPatchTireStation {
      return "Patch Tire Station"
    } else if self.place.hasWashStation {
      return "Wash Staton"
    } else {
      return "Inflation Point"
    }
  }

  var rate: String {
    String(format: "%.1f", self.place.averageRate)
  }

  public var body: some View {
    GeometryReader { proxy in
      VStack(spacing: 0) {
        VStack {
          HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading) {
              Text(self.place.name)
                .font(.largeTitle)
              Text(
                self.getServiceLocalizableKey()
              )
              .lineLimit(2)
              .font(.headline)
            }
            Spacer()
            VStack(alignment: .leading) {
              HStack(alignment: .center) {
                Image(systemName: "star.fill")
                  .resizable()
                  .frame(width: 24, height: 24)
                  .foregroundColor(Color(red: 1, green: 215 / 255, blue: 0))
                Text(self.rate)
                  .font(.system(size: 28, weight: .bold, design: .monospaced))
                  .font(.largeTitle)
                  .foregroundColor(
                    DetailFeatureAsset.Colors.primary.swiftUIColor
                  )
              }

              Button(action: {
                // TODO:
              }, label: {
                Image(systemName: "plus.app.fill")
                  .resizable()
                  .frame(width: 33, height: 33)
                  .foregroundColor(.white)
                  .padding(8)
                  .background(
                    DetailFeatureAsset.Colors.primary.swiftUIColor
                  )
              })
            }
            Button(action: {
              // TODO:
            }, label: {
              Image(systemName: "xmark")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.25))
                .clipShape(Circle())
            })
          }
          .padding(.horizontal, 16)

          SwipableTabView(
            geoWidth: proxy.size.width,
            onChangeTab: { tab in
              handleOnChangeTab(tab)
            }
          )
        }
        .background(Color.clear)

        switch self.selectedTab {
        case .info:
          Text("Info")
        case .review:
          Text("Review")
        }
      }
      .padding(.vertical, 8)
    }
    .ignoresSafeArea()
    .background(Color(.secondarySystemBackground))
    .task {}
    .onDisappear {}
    //		.sheet(
    //			item: self.$store.scope(
    //				state: \.destination?.reviewForm,
    //				action: \.destination.reviewForm
    //			),
    //			content: { (store: StoreOf<ReviewForm>) in
    //				ReviewFormView(store: store)
    //			}
    //		)
    //		.fullScreenCover(
    //			item: self.$store.scope(
    //				state: \.destination?.imagesInspector,
    //				action: \.destination.imagesInspector
    //			),
    //			content: { (store: StoreOf<ImagesInspector>) in
    //				ImagesInspectorView(store: store)
    //			}
    //		)
  }
}

#Preview {
  DetailView(
    place: Place.mock()
  )
}

public extension Place {
  /// One-off mock with sensible defaults (override what you need).
  static func mock(
    id: Int = 1,
    name: String = "Mock Place",
    latitude: Double = 13.7563, // Bangkok
    longitude: Double = 100.5018,
    address: String = "123 Mockingbird Lane",
    hasMotorcycleGarage: Bool = true,
    hasInflationStation: Bool = true,
    hasWashStation: Bool = false,
    hasPatchTireStation: Bool = false,
    hasCarGarage: Bool = true,
    averageRate: Double = 4.2,
    carGarage: CarGarage? = .init(brands: [
      CarBrand(id: 1, displayName: "Toyota"),
      CarBrand(id: 2, displayName: "Honda")
    ]),
    openCloseTime: OpenCloseTime = .empty,
    images: [Image] = [Image(id: 1, url: URL(string: "https://picsum.photos/300")!)],
    contributorName: String = "Fixsy"
  ) -> Place {
    Place(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      hasMotorcycleGarage: hasMotorcycleGarage,
      hasInflationStation: hasInflationStation,
      hasWashStation: hasWashStation,
      hasPatchTireStation: hasPatchTireStation,
      hasCarGarage: hasCarGarage,
      averageRate: averageRate,
      carGarage: carGarage,
      openCloseTime: openCloseTime,
      images: images,
      contributorName: contributorName
    )
  }

  /// A couple of named samples for quick previews/tests.
  static let sampleA = Place.mock(id: 101, name: "Downtown Garage")
  static let sampleB = Place.mock(id: 102, name: "Riverside Auto", averageRate: 3.8)
}

// MARK: - Helpers

private func randomLatLonOffset(meters: Double) -> (lat: Double, lon: Double) {
  // Rough conversion near the equator; good enough for previews/tests.
  let metersPerDegLat = 111_320.0
  let metersPerDegLonAtLat = 111_320.0
  let rLat = Double.random(in: -meters ... meters) / metersPerDegLat
  let rLon = Double.random(in: -meters ... meters) / metersPerDegLonAtLat
  return (rLat, rLon)
}

#if DEBUG
  #Preview {
    DetailView(place: .mock())
  }
#endif
