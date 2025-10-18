import Models
import SwiftUI

struct SearchFilterView: View {
  @Binding var filter: PlaceFilter
  let onTap: @Sendable (Tap) -> ()

	private var observePlacesTask: Task<(), Error>?
	private var observeFilterTask: Task<(), Error>?
	private var transformTask: Task<(), Error>?
	
	public init(
		filter: Binding<PlaceFilter>,
		onTap: @Sendable @escaping (Tap) -> ()
	) {
		self._filter = filter
		self.onTap = onTap
	}
	
  var body: some View {
    HStack(spacing: 24) {
      Button {
        self.onTap(.motorcycle)
      } label: {
        SearchFeatureAsset.Images.motorcycleIcon.swiftUIImage
          .resizable()
          .foregroundColor(.white)
          .aspectRatio(1, contentMode: .fit)
          .padding(8)
      }
      .background(
        self.filter.showMotorcycleGarages
          ? SearchFeatureAsset.Colors.motorcycleGarage.swiftUIColor
          : Color(.systemGray4)
      )
      .clipShape(Capsule())

      Button {
        self.onTap(.car)
      } label: {
        SearchFeatureAsset.Images.carIcon.swiftUIImage
          .resizable()
          .foregroundColor(.white)
          .aspectRatio(1, contentMode: .fit)
          .padding(8)
      }
      .background(
        self.filter.showCarGarage
          ? SearchFeatureAsset.Colors.carGarage.swiftUIColor
          : Color(.systemGray4)
      )
      .clipShape(Capsule())

      Button {
        self.onTap(.inflationPoint)
      } label: {
        SearchFeatureAsset.Images.psiIcon.swiftUIImage
          .resizable()
          .foregroundColor(.white)
          .aspectRatio(1, contentMode: .fit)
          .padding(8)
      }
      .background(
        self.filter.showInflationPoints
          ? SearchFeatureAsset.Colors.inflationPoint.swiftUIColor
          : Color(.systemGray4)
      )
      .clipShape(Capsule())

      Button {
        self.onTap(.washStation)
      } label: {
        SearchFeatureAsset.Images.waterDropIcon.swiftUIImage
          .resizable()
          .foregroundColor(.white)
          .aspectRatio(1, contentMode: .fit)
          .padding(8)
      }
      .background(
        self.filter.showWashStations
          ? SearchFeatureAsset.Colors.washStation.swiftUIColor
          : Color(.systemGray4)
      )
      .clipShape(Capsule())

      Button {
        self.onTap(.patchTire)
      } label: {
        SearchFeatureAsset.Images.patchTireIcon.swiftUIImage
          .resizable()
          .foregroundColor(Color.white)
          .aspectRatio(1, contentMode: .fit)
          .padding(8)
      }
      .background(
        self.filter.showWashStations
          ? SearchFeatureAsset.Colors.patchTireStation.swiftUIColor
          : Color(.systemGray4)
      )
      .clipShape(Capsule())
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 16)
    .task {}
  }
}

#if DEBUG

  #Preview("Identity") {
		SearchFilterView(
			filter: .constant(.identity),
			onTap: { _ in }
		)
  }

#endif
