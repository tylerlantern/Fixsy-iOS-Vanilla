import Models
import SwiftUI

public struct InfoView: View {
  @State var place: Place
  let parentSize: CGSize
  public init(
    place: Place,
    parentSize: CGSize
  ) {
    self.place = place
    self.parentSize = parentSize
  }

  //	public struct ViewState: Equatable {
  //		public let images: [Place.Image]
  //		public let address: String
  //		public let showCarBrandsSection: Bool
  //		public let contributorName: String
  //		public init(state: PlaceInfoReducer.State) {
  //			self.images = state.place.images
  //			self.address = state.place.address
  //			self.showCarBrandsSection = state.place.hasCarGarage
  //			self.contributorName = state.place.contributorName
  //		}
  //	}

  public var body: some View {
    GeometryReader { proxy in
      ScrollView(.vertical, showsIndicators: true) {
        LazyVStack(alignment: .leading) {
          if self.place.contributorName.isEmpty {
            VStack(spacing: 0) {
              HStack {
                Text("Contributor")
                  .bold()

                Rectangle()
                  .frame(width: 1)
                  .foregroundColor(Color(uiColor: .tertiaryLabel))

                Text(self.place.contributorName)
                Spacer()
              }
              .padding(16)
              Divider()
            }
          }
          if self.place.hasCarGarage {
            //						CapsulesStackView<CarBrandItem, CarBrandItemView>(
            //							store: self.store.scope(
            //								state: \.carBrandItems,
            //								action: \.carBrandItems
            //							),
            //							demandedWidthSize: proxy.size.width - 32,
            //							contentEachStore: { store in
            //								CarBrandItemView(store: store)
            //							}
            //						)
            //						.padding(.horizontal, 16)
          }
          VStack(alignment: .leading) {
            Text(self.place.address)
              .font(.subheadline)
            Button {
              // TODO:
            } label: {
              HStack {
                Spacer()
                Image(systemName: "􀣺")
                  .resizable()
                  .frame(width: 30, height: 30)
                  .aspectRatio(1, contentMode: .fit)
                Text("Apple Map")
                  .bold()
                  .foregroundColor(Color.white)
                  .padding()
                Spacer()
              }
            }
            .background(DetailFeatureAsset.Colors.dodgleBlue.swiftUIColor)

            Button {
              // TODO:
            } label: {
              HStack {
                Spacer()
                DetailFeatureAsset.Images.googleMapIcon.swiftUIImage
                  .resizable()
                  .frame(width: 30, height: 30)
                  .aspectRatio(1, contentMode: .fit)
                Text("Google Map")
                  .bold()
                  .foregroundColor(Color.white)
                  .bold()
                  .padding()
                Spacer()
              }
            }
            .background(
              DetailFeatureAsset.Colors.waterMelon.swiftUIColor
            )

            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(self.place.images) { image in
                  let side = proxy.size.width * 0.5
                  AsyncImage(url: image.url, transaction: .init(animation: .default)) { phase in
                    switch phase {
                    case .empty:
                      ZStack {
                        ProgressView()
                      }
                      .frame(width: side, height: side)

                    case let .success(img):
                      img.resizable()
                        .scaledToFit()
                        .frame(width: side, height: side)

                    case .failure:
                      ZStack {
                        Image(systemName: "photo")
                          .imageScale(.large)
                          .foregroundStyle(.secondary)
                      }
                      .frame(width: side, height: side)

                    @unknown default:
                      EmptyView().frame(width: side, height: side)
                    }
                  }
                  .contentShape(Rectangle())
                  .onTapGesture {
                    // TODO:
                  }
                }
              }
            }
            .frame(
              height: proxy.size.width * 0.5
            )
          }
          .padding(.horizontal, 16)
        }
      }
    }
  }
}
