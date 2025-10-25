import SwiftUI
import APIClient
import DatabaseClient
import Router
import AuthProvidersClient
import AccessTokenClient
import BannerToastComponent

public struct SocialSignInView: View {
	
	public init(){}
	
	enum SocialButtonTap {
		case apple,google
	}
	
	@Environment(\.accessTokenClient) var accessTokenClient
	@Environment(\.router) var router
	@Environment(\.apiClient) var apiClient
	@Environment(\.databaseClient) var databaseClient
	@Environment(\.authProvidersClient) var authProvidersClient
	
	@Environment(\.dismiss) var dismiss
	
	@StateObject var banners = BannerCenter()
	
	public var body: some View {
			VStack(spacing: 24) {
				SocialSignInFeatureAsset.Images.fixsyIcon.swiftUIImage
					.resizable()
					.frame(width: 200, height: 200)
					.aspectRatio(contentMode: .fit)
					.background(
						SocialSignInFeatureAsset.Colors.primary.swiftUIColor
					)
					.cornerRadius(100)
				VStack(spacing: 16) {
					Button(
						action: {
							self.handleOnTap(tap: .google)
						}
					) {
						ZStack {
							HStack {
								SocialSignInFeatureAsset.Images.icGoogle.swiftUIImage
									.clipped()
									.padding(.leading, 22)
								Spacer()
							}
							Text("GOOGLE")
								.fontWeight(.bold)
								.multilineTextAlignment(.center)
								.padding(.horizontal, 50)
						}
					}
					.buttonStyle(
						SocialButtonStyle(
							borderColor: Color.gray.opacity(0.5),
							backgroundColor: Color.white,
							pressedBackgroundColor: Color(.systemGray6),
							foregroundColor: Color.black
						)
					)
					
					Button(
						action: {
							self.handleOnTap(tap: .apple)
						}
					) {
						ZStack {
							HStack {
								SocialSignInFeatureAsset.Images.icApple.swiftUIImage
									.clipped()
									.padding(.leading, 24)
								Spacer()
							}
							Text("APPLE")
								.fontWeight(.bold)
								.fixedSize(horizontal: false, vertical: true)
								.multilineTextAlignment(.center)
								.padding(.horizontal, 50)
						}
					}
					.buttonStyle(
						SocialButtonStyle(
							borderColor: Color.gray.opacity(0.5),
							backgroundColor: Color.black,
							pressedBackgroundColor: Color(.systemGray6),
							foregroundColor: Color.white
						)
					)
					Spacer()
				}
			}
			.padding()
			.background(
				SocialSignInFeatureAsset.Colors.primary.swiftUIColor
			)
		.bannerHost(banners)
		.accentColor(.white)
	}
}


#Preview {
	SocialSignInView()
}
