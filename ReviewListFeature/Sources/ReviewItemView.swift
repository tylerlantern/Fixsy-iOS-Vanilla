import CapsulesStackComponent
import CarBrandComponent
import Models
import StarRatingComponent
import SwiftUI

public struct ReviewItemView: View {
  let item: ReviewItem
  let onTapImage: @Sendable (URL?) -> ()

  public init(
    item: ReviewItem,
    onTapImage: @Sendable @escaping (URL?) -> ()
  ) {
    self.item = item
    self.onTapImage = onTapImage
  }

  private let profileImageSize: CGSize = .init(width: 34, height: 34)

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      VStack(alignment: .leading, spacing: 8) {
        HStack(alignment: .bottom) {
          if let url = self.item.profileImage {
            AsyncImage(
              url: url,
              transaction: .init(animation: .default)
            ) { phase in
              switch phase {
              case .empty:
                ZStack { ProgressView() }
                  .frame(
                    width: self.profileImageSize.width,
                    height: self.profileImageSize.height
                  )

              case let .success(img):
                img.resizable()
                  .scaledToFit()
                  .frame(
                    width: self.profileImageSize.width,
                    height: self.profileImageSize.height
                  )

              case .failure:
                Image(systemName: "person.crop.circle.fill")
                  .resizable()
                  .frame(
                    width: self.profileImageSize.width,
                    height: self.profileImageSize.height
                  )

              @unknown default:
                EmptyView()
                  .frame(
                    width: self.profileImageSize.width,
                    height: self.profileImageSize.height
                  )
              }
            }
          } else {
            Image(systemName: "person.crop.circle.fill")
              .resizable()
              .frame(
                width: self.profileImageSize.width,
                height: self.profileImageSize.height
              )
          }

          Text(self.item.fullName)
            .font(.title3)
            .bold()

          Spacer()
        }

        StarRatingView(
          rating: 5,
          spacing: 8,
          color: ReviewListFeatureAsset.Colors.gold.swiftUIColor,
          maxRating: 5
        )
        .frame(width: 100, height: 25)
        .disabled(true)

        CapsulesStackView(
          items: self.item.carBrands
        ) { carBrand in
          CarBrandItemView(
            displayName: carBrand.displayName,
            isSelected: .constant(true)
          )
        }
      }
      if !self.item.images.isEmpty {
        ScrollView(.horizontal, showsIndicators: true) {
          LazyHStack(spacing: 8) {
            ForEach(
              self.item.images,
              id: \.id
            ) { image in
              AsyncImage(url: image.url) { phase in
                switch phase {
                case .empty:
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
                    .redacted(reason: .placeholder)
                    .shimmer()
                case let .success(image):
                  image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipped()
                case .failure:
                  Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.secondary)
                @unknown default:
                  EmptyView()
                }
              }
              .contentShape(Rectangle())
              .onTapGesture {
                self.onTapImage(image.url)
              }
              .transition(.opacity)
            }
          }
          .padding(.horizontal, 8)
        }
      }

      if !self.item.text.isEmpty {
        Text(self.item.text)
          .font(.body)
      }
    }
    .padding(16)
    .onAppear {}
    Divider()
      .background(Color(UIColor.systemGray6))
  }
}
