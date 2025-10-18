import Models
import PlaceStore
import SwiftUI

struct SearchFilterView: View {
  @State private var observeFilterTask: Task<(), Error>?

  @Environment(\.databaseClient) var databaseClient
  @Environment(PlaceStore.self) private var placeStore
  @State var filter: PlaceFilter = .identity

  var body: some View {
    HStack(spacing: 24) {
      Button {
        self.filter.showMotorcycleGarages.toggle()
        Task {
          try await self.databaseClient.syncPlaceFilter(self.filter)
        }
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
        self.filter.showCarGarage.toggle()
        Task {
          try await self.databaseClient.syncPlaceFilter(self.filter)
        }
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
        self.filter.showInflationPoints.toggle()
        Task {
          try await self.databaseClient.syncPlaceFilter(self.filter)
        }
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
        self.filter.showWashStations.toggle()
        Task {
          try await self.databaseClient.syncPlaceFilter(self.filter)
        }
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
        self.filter.showPatchTireStations.toggle()
        Task {
          try await self.databaseClient.syncPlaceFilter(self.filter)
        }
      } label: {
        SearchFeatureAsset.Images.patchTireIcon.swiftUIImage
          .resizable()
          .foregroundColor(Color.white)
          .aspectRatio(1, contentMode: .fit)
          .padding(8)
      }
      .background(
        self.filter.showPatchTireStations
          ? SearchFeatureAsset.Colors.patchTireStation.swiftUIColor
          : Color(.systemGray4)
      )
      .clipShape(Capsule())
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 16)
    .task {
      Task {
        self.filter = try await self.databaseClient.getPlaceFilter()
      }
    }
  }

  func updateLocalPlaceFilter(_ value: PlaceFilter) async throws {
    try await self.databaseClient.syncPlaceFilter(
      value
    )
  }
}

#if DEBUG

  #Preview("Identity") {
    SearchFilterView()
  }

#endif
