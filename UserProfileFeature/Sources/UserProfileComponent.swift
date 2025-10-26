import SwiftUI

public struct UserProfileComponentView: View {
  let uuid: String
  let url: URL?
  let fullName: String
  let point: Int
  let email: String

  let onEditName: () -> ()
  let onCopyUUID: (String) -> ()

  @State var showingEditingName: Bool = false
  @Environment(\.router) var router

  public init(
    uuid: String,
    url: URL?,
    fullName: String,
    point: Int,
    email: String,
    onEditName: @escaping () -> (),
    onCopyUUID: @escaping (String) -> () = { value in
      UIPasteboard.general.string = value
    }
  ) {
    self.uuid = uuid
    self.url = url
    self.fullName = fullName
    self.point = point
    self.email = email
    self.onEditName = onEditName
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
              Label(
                "Edit Name",
                systemImage: "square.and.pencil"
              )
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

          Text("\(self.point) $FXS")
            .bold()
            .foregroundStyle(Color(red: 212 / 255, green: 175 / 255, blue: 55 / 255))
        }

        Text(
          "Earn coins by creating form-requests pinned on the map. Once approved, you’ll receive $FXS."
        )
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)

        VStack(spacing: 0) {
          ItemRow(label: "UUID", display: self.uuid) {
            Button {
              self.onCopyUUID(self.uuid)
            } label: {
              Image(systemName: "doc.on.doc")
                .foregroundStyle(.white)
                .accessibilityLabel("Copy UUID")
            }
          }
          ItemRow(label: "Email", display: self.email)
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

  init(label: String, display: String, @ViewBuilder accessory: () -> Accessory = { EmptyView() }) {
    self.label = label
    self.display = display
    self.accessory = accessory()
  }

  var body: some View {
    VStack {
      HStack(alignment: .firstTextBaseline, spacing: 8) {
        VStack(alignment: .leading, spacing: 2) {
          HStack(spacing: 8) {
            Text(self.label).bold()
            self.accessory
          }
          .foregroundStyle(.white)

          Text(self.display)
            .lineLimit(1)
            .foregroundStyle(.white)
        }
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 6)

      Divider().overlay(Color.white.opacity(0.6))
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
        onEditName: { print("Edit name tapped") }
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
        onEditName: {}
      )
      .padding()
    }
    .preferredColorScheme(.dark)
  }

#endif
