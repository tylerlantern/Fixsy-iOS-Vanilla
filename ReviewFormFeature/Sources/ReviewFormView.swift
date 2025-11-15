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
import PhotosUI
import PlaceStore
import Router
import StarRatingComponent
import SwiftUI
import UIKit

public struct ReviewFormView: View {
  enum Field { case tellStory }

  enum ScrollPosition: String {
    case imageSelection
  }

  let spacing: CGFloat = 8
  let maxRating: CGFloat = 5
  let padding: CGFloat = 16
  let maxCharTellStory: Int = 120

  private let maxNumberOfImages: Int = 2

  @State var isSubmiting: Bool = false
  @State var exceedLimit: Bool = false
  @State var tellStory: String = ""
  @State var rating: Float = 0
  @State var presentedCarBrandsScreen: Bool = false
  @State var showRateError: Bool = false
  @State var showCarBrandsError: Bool = false
  @State var showPhotoPicker: Bool = false
  @State private var selectedItems: [PhotosPickerItem] = []
  @State private var selectedImages: [UIImage] = []

  @FocusState private var focusedField: Field?
  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.router) var router

  public var countTextLabel: String {
    "\(self.tellStory.count)/\(self.maxCharTellStory)"
  }

  let placeId: Int
  let hasCarGarage: Bool
  @State var carBrands: [CarBrand] = []

  public init(
    placeId: Int,
    hasCarGarage: Bool,
    carBrands: [CarBrand] = []
  ) {
    self.placeId = placeId
    self.carBrands = carBrands
    self.hasCarGarage = hasCarGarage
  }

  func ratingHeight(width w: CGFloat) -> CGFloat {
    ((w - self.padding * 2) / 5) - self.spacing
  }

  func getImageSize(
    _ width: CGFloat,
    numberOfImages: Int
  ) -> CGSize {
    let totalWidth = width - 64 - CGFloat(numberOfImages - 1) * 16
    return CGSize(
      width: totalWidth / CGFloat(numberOfImages),
      height: totalWidth / CGFloat(numberOfImages)
    )
  }

  public var body: some View {
    NavigationStack {
      GeometryReader { proxy in
        VStack {
          ScrollViewReader { scrollProxy in
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
                    .foregroundColor(.red)
                    .transition(.move(edge: .leading))
                }
              }

              if self.hasCarGarage {
                Section("Car Brands") {
                  ZStack {
                    if self.carBrands.isEmpty {
                      Button {
                        self.handleOnTapOpeningCarBrandsScree()
                      } label: {
                        HStack {
                          Spacer()
                          Text("Click me to select at least one brand.")
                          Spacer()
                        }
                      }
                      .buttonStyle(.glass)

                    } else {
                      CapsulesStackView(
                        items: self.carBrands
                      ) { _, chip in
                        CarBrandItemView(
                          displayName: chip.displayName,
                          isSelected: true
                        )
                      }
                      .frame(maxWidth: proxy.size.width, alignment: .leading)
                      .contentShape(Rectangle())
                      .onTapGesture {}
                    }
                  }

                  if self.showCarBrandsError {
                    Text("Required at least 1 brand.")
                      .font(.system(size: 12, weight: .regular, design: .default))
                      .foregroundColor(.red)
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
                        ? .red
                        : (self.colorScheme == .dark ? .white : .black)
                    )
                }
              }

              Section("Images") {
                Button {
                  print("TAP IMAGES")
                  self.showPhotoPicker = true
                } label: {
                  HStack {
                    Spacer()
                    Text("Select Multiple Photos")
                    Spacer()
                  }
                }
                .buttonStyle(.glass)

                if !self.selectedImages.isEmpty {
                  ScrollView(.horizontal) {
                    LazyHStack(spacing: 16) {
                      ForEach(self.selectedImages, id: \.self) { image in
                        let size = self.getImageSize(
                          proxy.size.width,
                          numberOfImages: self.maxNumberOfImages
                        )
                        Image(uiImage: image)
                          .resizable()
                          .scaledToFill()
                          .frame(
                            width: size.width,
                            height: size.height
                          )
                          .clipped()
                      }
                    }
                  }
                  .id(ScrollPosition.imageSelection.rawValue)
                }
              }
            }
            .onChange(of: self.selectedItems) { _, _ in
              Task {
                self.selectedImages.removeAll()
                for item in self.selectedItems {
                  if let data = try? await item.loadTransferable(type: Data.self),
                     let uiImage = UIImage(data: data)
                  {
                    self.selectedImages.append(uiImage)
                  }
                }
                withAnimation {
                  scrollProxy.scrollTo(
                    ScrollPosition.imageSelection.rawValue,
                    anchor: .center
                  )
                }
              }
            }
            .scrollDismissesKeyboard(.interactively)
          }

          HStack {
            Spacer()
            Button {
              // TODO: Submit
            } label: {
              HStack(spacing: 8) {
                Spacer()
                if self.isSubmiting {
                  ProgressView()
                    .tint(.white)
                }
                Text("Save")
                  .foregroundColor(.white)
                  .bold()
                  .padding()
                Spacer()
              }
            }
            .background(
              ReviewFormFeatureAsset
                .Colors
                .primary
                .swiftUIColor
            )
            .padding()
            .disabled(self.isSubmiting)
            Spacer()
          }
        }

        .onTapGesture {
          // self.viewStore.send(.focusedField(nil))
        }
      }
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button(
            action: {
              self.dismiss()
            },
            label: {
              Label("Dismiss", systemImage: "xmark")
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
            }
          )
          .glassEffect()
        }
      }
      .navigationDestination(
        isPresented: self.$presentedCarBrandsScreen,
        destination: {
          self.router.route(
            .app(
              .detail(
                .reviewForm(
                  .carBrands(
                    .root(
                      self.carBrands.map(\.id),
                      { carBrands in
                        self.presentedCarBrandsScreen = false
                        self.carBrands = carBrands
                      }
                    )
                  )
                )
              )
            )
          )
        }
      )
      .navigationTitle("Review Form")
    }
    .photosPicker( // 👈 attached to the root view
      isPresented: self.$showPhotoPicker,
      selection: self.$selectedItems,
      maxSelectionCount: self.maxNumberOfImages,
      matching: .images
    )
  }
}

// MARK: - SystemCard

struct SystemCard: ViewModifier {
  var cornerRadius: CGFloat = 14
  func body(content: Content) -> some View {
    content
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(
          cornerRadius: self.cornerRadius,
          style: .continuous
        )
        .fill(Color(uiColor: .secondarySystemBackground))
      )
      .overlay(
        RoundedRectangle(
          cornerRadius: self.cornerRadius,
          style: .continuous
        )
        .stroke(
          Color(uiColor: .separator),
          lineWidth: 0.5
        )
      )
  }
}

extension View {
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
      placeId: 5,
      hasCarGarage: true
    )
  }

#endif
