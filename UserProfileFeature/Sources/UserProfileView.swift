import APIClient
import BannerCenterModule
import DatabaseClient
import Models
import Router
import SwiftUI
import UserProfileModel
import AccessTokenClient

public struct UserProfileView: View {
	
	enum SubmitAction {
		case delete,logout
	}
	
  public enum Display {
    case shimmer, render(UserProfile)
  }

  @State var display: Display
  @State var showingConfirmationDialog: Bool = false
  @State var showingEditingName: Bool = false
  @State var isSubmitting: Bool = false

  @Environment(\.router) var router
  @Environment(\.apiClient) var apiClient
  @Environment(\.databaseClient) var databaseClient
	@Environment(\.accessTokenClient) var accessTokenClient
  @Environment(\.dismiss) var dismiss

  @State var observeTask: Task<(), Error>?
  @State var fetchTask: Task<(), Error>?

  @EnvironmentObject var banners: BannerCenter

  public init(display: Display = .shimmer) {
    self.display = display
  }

  public var body: some View {
    NavigationStack {
      VStack(spacing: 8) {
        switch self.display {
        case let .render(user):
          UserProfileComponentView(
            uuid: user.id,
            url: user.pictureURL,
            fullName: user.fullName,
            point: user.point,
            email: user.email,
            onEditName: {
              self.showingEditingName = true
            }
          )
        case .shimmer:
          UserProfileComponentView(
            uuid: "XXXX-XXXX-XXXX-XXXX",
            url: nil,
            fullName: "SHIMMER SHIMMER",
            point: 100,
            email: "SHIMMER@SHIMMER.com",
            onEditName: {}
          )
          .redacted(reason: .placeholder)
          .disabled(true)
        }
        Spacer()
        VStack(spacing: 8) {
          Button(
            action: {
							self.processSubmit(.delete)
            },
            label: {
              HStack {
                Spacer()
                if self.isSubmitting {
                  ProgressView()
                    .progressViewStyle(
                      CircularProgressViewStyle(tint: Color.white)
                    )
                }
                Text("Delete Account")
                  .foregroundColor(.white)
                  .bold().padding()
                Spacer()
              }
            }
          )
          .background(Color.red)
          .disabled(self.isSubmitting)

          Button(
            action: {
							self.processSubmit(.logout)
						},
            label: {
              HStack {
                Spacer()
                if self.isSubmitting {
                  ProgressView()
                    .progressViewStyle(
                      CircularProgressViewStyle(
                        tint: UserProfileFeatureAsset.Colors.primary.swiftUIColor
                      )
                    )
                }
                Text("Sign Out").bold().padding()
                Spacer()
              }
            }
          )
          .background(Color.white)
          .disabled(self.isSubmitting)
        }
      }
      .background(UserProfileFeatureAsset.Colors.primary.swiftUIColor)
      .task {
        self.initialize()
      }
      .onDisappear {
        self.cancelTasks()
      }
      .confirmationDialog(
        "Delete Account",
        isPresented: self.$showingConfirmationDialog
      ) {
        Button("Confirm", role: .destructive) {
          // Perform delete action here
        }
        Button("Cancel", role: .cancel) {
          // Dismiss dialog without action
        }
      } message: {
        Text("Are you sure to permanently delete the account ?")
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(
            action: {
              self.dismiss()
            }, label: {
              Label(
                "Dismiss",
                systemImage: "xmark"
              )
              .labelStyle(.iconOnly)
              .frame(width: 44, height: 44)
            }
          )
          .glassEffect()
        }
      }
      .navigationDestination(
        isPresented: self.$showingEditingName
      ) {
        switch self.display {
        case .shimmer:
          EmptyView()
        case let .render(userProfile):
          self.router.route(
            .app(
              .search(
                .userProfile(
                  .editingName(userProfile.firstName, userProfile.lastName)
                )
              )
            )
          )
        }
      }
    }
  }
}

#if DEBUG

  public let previewUserProfile = UserProfileComponentView(
    uuid: "123e4567-e89b-12d3-a456-426614174000",
    url: URL(string: "https://picsum.photos/200"),
    fullName: "Jane Appleseed",
    point: 420,
    email: "jane@example.com",
    onEditName: { print("Edit name tapped") }
  )

  #Preview("User Profile – Render") {
    UserProfileView(
      display: .render(
        .init(
          id: "123e4567-e89b-12d3-a456-426614174000",
          email: "jane@example.com",
          firstName: "Jane",
          lastName: "Appleseed",
          pictureURL: URL(string: "https://picsum.photos/200"),
          point: 50
        )
      )
    )
  }

  #Preview("User Profile – loading") {
    UserProfileView(
      display: .shimmer
    )
  }

#endif
