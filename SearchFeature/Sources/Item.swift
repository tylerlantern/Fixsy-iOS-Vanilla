import Models
import SwiftUI

struct ItemView: View {
  let item: Item
  let onTap: (Int) -> ()
  init(item: Item, onTap: @escaping (Int) -> ()) {
    self.item = item
    self.onTap = onTap
  }

  var serviceColor: SwiftUI.Color {
    switch self.item.service {
    case .car:
      return SearchFeatureAsset.Colors.carGarage.swiftUIColor
    case .motorcycle:
      return SearchFeatureAsset.Colors.motorcycleGarage.swiftUIColor
    case .patchTire:
      return SearchFeatureAsset.Colors.patchTireStation.swiftUIColor
    case .wash:
      return SearchFeatureAsset.Colors.washStation.swiftUIColor
    case .inflationPoint:
      return SearchFeatureAsset.Colors.inflationPoint.swiftUIColor
    case .none:
      return Color.init(.systemGray2)
    }
  }

  public var body: some View {
		VStack {
			HStack(spacing: 12) {
				self.item.image
					.renderingMode(.template)
					.resizable()
					.foregroundColor(.white)
					.frame(width: 24, height: 24)
					.padding(12)
					.background(
						Circle().fill(self.serviceColor) // round background
					)
					
				VStack(alignment: .leading, spacing: 8) {
					HStack(alignment: .firstTextBaseline, spacing: 4) {
						Text(self.item.name)
							.font(.title3)
							.bold()
							.lineLimit(1)

						Spacer()

						if let displayKmAways = self.item.displayKmAways {
							Text(
								displayKmAways
							)
							.font(.callout)
						}
					}

					Text(self.item.address)
						.font(.body).lineLimit(2)
				}
				Spacer()
			}
			Divider()
		}
		.padding(.horizontal)
    .onTapGesture {}
  }
}

#if DEBUG
#Preview {
	ItemView.init(
		item: .init(
			id: 1,
			name: "Palonto",
			image: SearchFeatureAsset.Images.carIcon.swiftUIImage,
			service: .car,
			address: "1/25 Param 3 road, Bangkok",
			distance: 20)
	) { _ in
			
		}
}
#endif
