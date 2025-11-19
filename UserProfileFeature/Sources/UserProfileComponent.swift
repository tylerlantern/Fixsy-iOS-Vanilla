import SwiftUI

public struct UserProfileComponentView: View {
  let uuid: String
  let url: URL?
  let fullName: String
  let point: Int
  let email: String
  let currentNativeLanguage: String

  let onEditName: () -> ()
  let onTapChangeAppLang: () -> ()
  let onCopyUUID: (String) -> ()

  @Environment(\.router) var router

  public init(
    uuid: String,
    url: URL?,
    fullName: String,
    point: Int,
    email: String,
    currentNativeLanguage: String,
    onEditName: @escaping () -> (),
    onTapChangeAppLang: @escaping () -> (),
    onCopyUUID: @escaping (String) -> () = { value in
      UIPasteboard.general.string = value
    }
  ) {
    self.uuid = uuid
    self.url = url
    self.fullName = fullName
    self.point = point
    self.email = email
    self.currentNativeLanguage = currentNativeLanguage
    self.onEditName = onEditName
    self.onTapChangeAppLang = onTapChangeAppLang
    self.onCopyUUID = onCopyUUID
  }

  public var body: some View {
    VStack(spacing: 8) {
      VStack(spacing: 16) {
        AvatarView(url: self.url)
        HStack(spacing: 8) {
          Text(self.fullName)
            .font(.title)
            .bold()
            .foregroundStyle(.white)
          Button(
            action: self.onEditName,
            label: {
              Label {
                Text(
                  String(
                    localized: "Edit Name",
                    bundle: .module
                  )
                )
              } icon: {
                Image(systemName: "square.and.pencil")
              }
              .labelStyle(.iconOnly)
              .font(.title2)
              .frame(width: 44, height: 44)
            }
          )
          .glassEffect()
        }

        HStack(spacing: 8) {
          Image(systemName: "dollarsign.circle.fill")
            .resizable()
            .frame(width: 36, height: 36)
            .foregroundStyle(Color(red: 212 / 255, green: 175 / 255, blue: 55 / 255))

          Text(
            String(
              format: String(
                localized: "%@ $FXS",
                bundle: .module
              ),
              self.point.formatted()
            )
          )
            .bold()
            .foregroundStyle(Color(red: 212 / 255, green: 175 / 255, blue: 55 / 255))
        }

        Text(
          String(
            localized: "Earn coins by creating form-requests pinned on the map. Once approved, you’ll receive $FXS.",
            bundle: .module
          )
        )
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)

        VStack(spacing: 0) {
          ItemRow(
            label: String(
              localized: "UUID",
              bundle: .module
            ),
            display: self.uuid,
            accessory: {
              Button {
                self.onCopyUUID(self.uuid)
              } label: {
                Image(systemName: "doc.on.doc")
                  .foregroundStyle(.white)
                  .accessibilityLabel(
                    Text(
                      String(
                        localized: "Copy UUID",
                        bundle: .module
                      )
                    )
                  )
              }
            }
          )
          ItemRow(
            label: String(
              localized: "Email",
              bundle: .module
            ),
            display: self.email
          )
          ItemRow(
            label: String(
              localized: "Change Language",
              bundle: .module
            ),
            display: self.currentNativeLanguage,
            accessory: {
              Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            },
            onTap: {
              self.onTapChangeAppLang()
            }
          )
        }
      }
      Spacer(minLength: 0)
    }
  }
}

// MARK: - Rows

private struct ItemRow<Accessory: View>: View {
  let label: String
  let display: String
  var accessory: Accessory
  var onTap: (() -> ())?
  init(
    label: String,
    display: String,
    @ViewBuilder accessory: () -> Accessory = { EmptyView() },
    onTap: (() -> ())? = nil
  ) {
    self.label = label
    self.display = display
    self.accessory = accessory()
    self.onTap = onTap
  }

  var body: some View {
    VStack {
      HStack(alignment: .center, spacing: 8) {
        VStack(alignment: .leading, spacing: 2) {
          Text(self.label).bold()
            .foregroundStyle(.white)

          Text(self.display)
            .lineLimit(1)
            .foregroundStyle(.white)
        }
        Spacer()
        self.accessory
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 6)

      Divider().overlay(Color.white.opacity(0.6))
    }
    .contentShape(Rectangle())
    .onTapGesture {
      self.onTap?()
    }
  }
}

// MARK: - Avatar

private var avatarPlaceholder: some View {
  Image(systemName: "person.crop.circle.fill")
    .resizable()
    .scaledToFit()
    .foregroundStyle(.white)
}

@ViewBuilder
private func AvatarView(url: URL?) -> some View {
  let size: CGFloat = 124
  if let url {
    AsyncImage(url: url, transaction: .init(animation: .easeInOut)) { phase in
      switch phase {
      case .empty:
        avatarPlaceholder
      case let .success(image):
        image.resizable().scaledToFill()
      case .failure:
        avatarPlaceholder
      @unknown default:
        avatarPlaceholder
      }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
  } else {
    avatarPlaceholder
      .frame(width: size, height: size)
      .clipShape(Circle())
  }
}

#if DEBUG
  #Preview("User Profile – With Avatar") {
    ZStack {
      UserProfileComponentView(
        uuid: "123e4567-e89b-12d3-a456-426614174000",
        url: URL(string: "https://picsum.photos/200"),
        fullName: "Jane Appleseed",
        point: 420,
        email: "jane@example.com",
        currentNativeLanguage: "English",
        onEditName: {},
        onTapChangeAppLang: {}
      )
      .padding()
    }
    .preferredColorScheme(.dark)
  }

  #Preview("User Profile – No Avatar") {
    ZStack {
      UserProfileComponentView(
        uuid: "00000000-0000-0000-0000-000000000000",
        url: nil,
        fullName: "John Doe",
        point: 0,
        email: "john@example.com",
        currentNativeLanguage: "English",
        onEditName: {},
        onTapChangeAppLang: {}
      )
      .padding()
    }
    .preferredColorScheme(.dark)
  }

#endif
