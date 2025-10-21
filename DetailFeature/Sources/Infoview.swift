import Models
import SwiftUI
import CapsulesStackComponent
import CarBrandComponent

public struct InfoView: View {
	@State var place: Place
	@State var carBrands : [CarBrand]
	
	public init(
		place: Place,
	) {
		self.place = place
		self.carBrands = place.carGarage?.brands ?? []
	}
	
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
					
					if self.carBrands.count > 0 {
						CapsulesStackView(items: self.carBrands) { chip in
							CarBrandItemView(
								displayName: chip.displayName, isSelected: .constant(true)
							)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.horizontal,16)
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
									let side = (proxy.size.width - 8 - 16 * 2) * 0.5
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

#Preview("Detail") {
	InfoView.init(place: .mock())
}

#Preview("Capsules") {
	VStack {
		CapsulesStackView(
			items:
				[
					CarBrand(id: 1, displayName: "Test"),
					CarBrand(id: 2, displayName: "Test2"),
					CarBrand(id: 3, displayName: "TestTest Test"),
					CarBrand(id: 4, displayName: "Apple"),
					CarBrand(id: 5, displayName: "Bannana"),
					CarBrand(id: 6, displayName: "TestTest Test"),
					CarBrand(id: 1, displayName: "AWS"),
					CarBrand(id: 2, displayName: "Blackpearl"),
					CarBrand(
						id: 3,
						displayName: "Flying Dutch man"
					),
				]
		) { chip in
			CarBrandItemView(
				displayName: chip.displayName, isSelected: .constant(true)
			)
		}
		.padding(.horizontal, 16)
	}
}

