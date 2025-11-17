import AccessTokenClient
import APIClient
import AuthProvidersClient
import BannerCenterModule
import DatabaseClient
import Models
import Router
import SwiftUI
import UserProfileModel

public struct UserProfileView: View {
	public enum Navigation: Hashable {
		case editingName(String,String),
				 changeLanguageApp
		@ViewBuilder
		func destination(
			router: Router
		) -> some View {
			switch self {
			case let .editingName(firstName, lastName) :
				router.route(
					.app(
						.search(
							.userProfile(
								.editingName(firstName, lastName)
							)
						)
					)
				)
			case .changeLanguageApp:
				router.route(
					.app(
						.search(
							.userProfile(
								.selectAppLanguage
							)
						)
					)
				)
			}
		}
		
	}
	
	enum SubmitAction {
		case delete, logout
	}
	
	public enum Display {
		case shimmer, render(UserProfile,_ currentNativeLanguage : String)
	}
	
	@State var display: Display
	@State var showingConfirmationDialog: Bool = false
	@State var isSubmitting: Bool = false
	
	@AppStorage("appLanguage") var appLanguage = "en"
	@Environment(\.router) var router
	@Environment(\.apiClient) var apiClient
	@Environment(\.databaseClient) var databaseClient
	@Environment(\.accessTokenClient) var accessTokenClient
	@Environment(\.authProvidersClient) var authProvidersClient
	@Environment(\.dismiss) var dismiss
	
	@State var observeTask: Task<(), Error>?
	@State var fetchTask: Task<(), Error>?
	@State var navigation : Navigation? = nil
	@EnvironmentObject var banners: BannerCenter
	
	public init(display: Display = .shimmer) {
		self.display = display
	}
	
	public var body: some View {
		NavigationStack {
			VStack(spacing: 8) {
				switch self.display {
				case let .render(user,localization):
					UserProfileComponentView(
						uuid: user.id,
						url: user.pictureURL,
						fullName: user.fullName,
						point: user.point,
						email: user.email,
						currentNativeLanguage: localization,
						onEditName: {
							self.navigation = .editingName(
								user.firstName,
								user.lastName
							)
						},
						onTapChangeAppLang: {
							self.navigation = .changeLanguageApp
						}
					)
				case .shimmer:
					UserProfileComponentView(
						uuid: "XXXX-XXXX-XXXX-XXXX",
						url: nil,
						fullName: "SHIMMER SHIMMER",
						point: 100,
						email: "SHIMMER@SHIMMER.com",
						currentNativeLanguage: "English",
						onEditName: {},
						onTapChangeAppLang: {
							
						}
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
					self.processSubmit(.delete)
				}
				Button("Cancel", role: .cancel) {
					self.showingConfirmationDialog = false
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
				item: self.$navigation
			) { nav in
				nav.destination(router: self.router)
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
	currentNativeLanguage: "English",
	onEditName: { print("Edit name tapped") },
	onTapChangeAppLang: {}
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
			),
			"English"
		)
	)
}

#Preview("User Profile – loading") {
	UserProfileView(
		display: .shimmer
	)
}

#endif
