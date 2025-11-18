import APIClient
import AsyncAlgorithms
import DatabaseClient
import Models
import ShimmerComponent
import SwiftOverlayShims
import SwiftUI

public struct CarBrandsView: View {
  public enum Display {
    case shimmer, render, fullScreenError
  }

  @State var store: CarBrandsStore
  @State var display: Display = .shimmer
  @State var disableSaveButton: Bool = false
  @State var disableClearButton: Bool = false

  @Environment(\.apiClient) var apiClient
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.dismiss) var dismiss

  @State var fetchTask: Task<(), Never>?
  @State var observeTask: Task<(), Never>?
  @State var hasReceiveData: Bool = false

  public let onTapSave: ([CarBrand]) -> ()

  public init(
    selectedIds: [Int],
    onTapSave: @escaping ([CarBrand]) -> ()
  ) {
    self.store = .init(selectedIds: [])
    self.onTapSave = onTapSave
  }

  public var body: some View {
    VStack {
      switch self.display {
      case .shimmer:
        CarBrandsComponentView(
          store: CarBrandsStore.shimmer()
        )
        .redacted(reason: .placeholder)
      case .render:
        CarBrandsComponentView(store: self.store)
      case .fullScreenError:
        Text("Error")
          .font(.title2)
      }
      Spacer()
      HStack(spacing: 16) {
        Button {
          self.dismiss()
        } label: {
          HStack {
            Spacer()
            Text("Clear", bundle: .module)
              .foregroundColor(
                self.disableSaveButton
                  ? Color.gray.opacity(0.8)
                  : Color.white
              )

            Spacer()
          }
        }
        .disabled(self.disableClearButton)
        .padding()
        .background(
          self.disableSaveButton
            ? Color.gray.opacity(0.5)
            : CarBrandsFeatureAsset.Colors.primary.swiftUIColor
        )

        Button {
          self.onTapSave(
            self.store.getSelectedBrandCars()
          )
        } label: {
          Spacer()
          Text(
            "Save",
            bundle: .module
          )
          .foregroundColor(
            self.disableSaveButton
              ? Color.gray.opacity(0.8)
              : Color.white
          )
          Spacer()
        }
        .disabled(self.disableSaveButton)
        .padding()
        .background(
          self.disableSaveButton
            ? Color.gray.opacity(0.5)
            : CarBrandsFeatureAsset.Colors.primary.swiftUIColor
        )
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 4)
    }
    .task {
      self.observe()
      self.fetch()
    }
    .onDisappear {
      self.handleOnDisappear()
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

// 1) A fixed, human-readable set
extension CarBrand {
  static let shimmers: [CarBrand] = [
    .init(id: 1, displayName: "Toyota"),
    .init(id: 2, displayName: "Honda"),
    .init(id: 3, displayName: "Nissan"),
    .init(id: 4, displayName: "Mazda"),
    .init(id: 5, displayName: "Mitsubishi"),
    .init(id: 6, displayName: "Suzuki"),
    .init(id: 7, displayName: "Subaru"),
    .init(id: 8, displayName: "Isuzu"),
    .init(id: 9, displayName: "Ford"),
    .init(id: 10, displayName: "Chevrolet"),
    .init(id: 11, displayName: "BMW"),
    .init(id: 12, displayName: "Mercedes-Benz"),
    .init(id: 13, displayName: "Volkswagen"),
    .init(id: 14, displayName: "Hyundai"),
    .init(id: 15, displayName: "Kia"),
    .init(id: 16, displayName: "Lexus"),
    .init(id: 17, displayName: "Volvo"),
    .init(id: 18, displayName: "Porsche"),
    .init(id: 19, displayName: "Audi"),
    .init(id: 20, displayName: "Tesla"),
    .init(id: 21, displayName: "BMW"),
    .init(id: 22, displayName: "Mercedes-Benz"),
    .init(id: 23, displayName: "Volkswagen"),
    .init(id: 24, displayName: "Hyundai"),
    .init(id: 25, displayName: "Kia"),
    .init(id: 26, displayName: "Lexus"),
    .init(id: 27, displayName: "Volvo"),
    .init(id: 28, displayName: "Porsche"),
    .init(id: 29, displayName: "Audi"),
    .init(id: 30, displayName: "Tesla")
  ]
}
