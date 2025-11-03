import APIClient
import AsyncAlgorithms
import BannerCenterModule
import BottomSheetModule
import CapsulesStackComponent
import CarBrandComponent
import DatabaseClient
import LocationManagerClient
import MapKit
import Models
import PlaceStore
import Router
import StarRatingComponent
import SwiftUI

public struct ReviewFormView: View {
  enum Field { case tellStory }
  let spacing: CGFloat = 8
  let maxRating: CGFloat = 5
  let padding: CGFloat = 16
  let maxCharTellStory: Int = 120

  @State var rating: Float = 0
  @State var tellStory: String = ""
  @State var showRateError: Bool = false
  @State var showCarBrandsError: Bool = false
  @State var isSubmiting: Bool = false
  @FocusState private var focusedField: Field?
  @Environment(\.dismiss) var dismiss
  @State var exceedLimit: Bool = false
  @Environment(\.colorScheme) var colorScheme

  public var countTextLabel: String {
    "\(self.tellStory.count)/\(self.maxCharTellStory)"
  }

  let hasCarGarage: Bool
  @State var carBrands: [CarBrand]

  public init(
    carBrands: [CarBrand],
    hasCarGarage: Bool
  ) {
    self.hasCarGarage = hasCarGarage
    self.carBrands = carBrands
  }

  func ratingHeight(width w: CGFloat) -> CGFloat {
    ((w - self.padding * 2) / 5) - self.spacing
  }

  public var body: some View {
    NavigationStack {
      GeometryReader { proxy in
        VStack {
          Form {
            Section("Rating") {
              StarRatingView(
                rating: self.$rating,
                spacing: 8
              )
              .frame(
                height: self.ratingHeight(width: proxy.size.width - 24)
              )
              if self.showRateError {
                Text("We need your satisfaction rate for this place")
                  .font(.system(size: 12, weight: .regular, design: .default))
                  .foregroundColor(Color.red)
                  .transition(.move(edge: .leading))
              }
            }

            if self.hasCarGarage {
              Section("Car Brands") {
                ZStack {
                  if !self.carBrands.isEmpty {
                    CapsulesStackView(items: self.carBrands) { chip in
                      CarBrandItemView(
                        displayName: chip.displayName, isSelected: .constant(true)
                      )
                    }
                    .frame(maxWidth: proxy.size.width, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {}
                  } else {
                    HStack {
                      Spacer()
                      Text("Click me to select at least one brand.")
                        .font(.body)
                        .foregroundStyle(Color(uiColor: .label))
                      Spacer()
                    }
                    .systemCard()
                    .contentShape(Rectangle())
                    .onTapGesture {}
                  }
                }

                if self.showCarBrandsError {
                  Text("Required at least 1 brand.")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(Color.red)
                    .transition(.move(edge: .leading))
                }
              }
              .onTapGesture {
                // TODO: Present car brand selection
              }
            }

            Section("Tell the community your story.") {
              TextField(
                "Tell us about this place's service.",
                text: self.$tellStory,
                axis: .vertical
              )
              .focused(self.$focusedField, equals: .tellStory)
              .lineLimit(5...)
              .textFieldStyle(.roundedBorder)
              .border(
                self.exceedLimit
                  ? Color.red
                  : Color.gray.opacity(0.5)
              )
              HStack {
                Spacer()
                Text(self.countTextLabel)
                  .font(.caption)
                  .foregroundColor(
                    self.exceedLimit
                      ? Color.red
                      : self.colorScheme == .dark ? Color.white : Color.black
                  )
              }
            }

            Section("Images") {
              //							DisplayImageListView(
              //								store: self.store.scope(
              //									state: \.displayImageList,
              //									action: ReviewForm.Action.displayImageList
              //								)
              //							)
            }
          }
          .scrollDismissesKeyboard(.interactively)

          HStack {
            Spacer()
            Button {
              // TODO: Submit
            } label: {
              HStack(spacing: 8) {
                Spacer()
                if self.isSubmiting {
                  ProgressView()
                    .tint(Color.white)
                }
                Text("Save")
                  .foregroundColor(Color.white)
                  .bold()
                  .padding()
                Spacer()
              }
            }
            .background(
              ReviewFormFeatureAsset.Colors.primary.swiftUIColor
            )
            .padding()
            .disabled(self.isSubmiting)
            Spacer()
          }
        }
        .onTapGesture {
          //					self.viewStore.send(.focusedField(nil))
        }
      }
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button(
            action: {
              self.dismiss()
            }, label: {
              Label("Dismiss", systemImage: "xmark")
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
            }
          )
          .glassEffect()
        }
      }
      //			.synchronize(
      //				self.viewStore.binding(
      //					get: \.focusedField,
      //					send: ReviewForm.Action.focusedField
      //				),
      //				self.$focusedField
      //			)
      //			.navigationDestination(
      //				store: self.store.scope(state: \.$carBrands, action: ReviewForm.Action.carBrands),
      //				destination: CarBrandsView.init
      //			)
      .navigationTitle("Review Form")
    }
  }
}

struct SystemCard: ViewModifier {
  var cornerRadius: CGFloat = 14
  func body(content: Content) -> some View {
    content
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .background(
        // iOS-native “card” background that adapts to Light/Dark
        RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
          .fill(Color(uiColor: .secondarySystemBackground))
      )
      .overlay(
        // Very subtle border like iOS grouped lists
        RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
          .stroke(Color(uiColor: .separator), lineWidth: 0.5)
      )
  }
}

extension View {
  /// Rounded card background that matches iOS forms in Light/Dark.
  func systemCard(cornerRadius: CGFloat = 14) -> some View {
    modifier(SystemCard(cornerRadius: cornerRadius))
  }
}

#if DEBUG
  extension CarBrand {
    static var mockPreview: [CarBrand] = [
      CarBrand(id: 1, displayName: "Honda"),
      CarBrand(id: 2, displayName: "Toyota"),
      CarBrand(id: 3, displayName: "BMW"),
      CarBrand(id: 4, displayName: "Benz")
    ]
  }

  #Preview {
    ReviewFormView(
      carBrands: [],
      hasCarGarage: true,
    )
  }
#endif
