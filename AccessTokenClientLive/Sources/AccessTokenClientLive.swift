import AccessTokenClient
import Foundation
import KeychainAccess
import os
import Synchronization

let logger = Logger(
	subsystem: Bundle.main.bundleIdentifier!,
	category: String(describing: AccessTokenClient.self)
)

extension AccessTokenClient {
	@MainActor
	public static let liveValue: Self = {
		let accessTokenStore = AccessTokenStore()
		return AccessTokenClient(
			initialize: { @MainActor in
				try await accessTokenStore.initialize()
			},
			accessToken: { @MainActor in
				try await accessTokenStore.getAuthCredential()
			},
			updateAccessToken: { @MainActor token in
				try await accessTokenStore.updateToken(token: token)
			}
		)
	}()
}

public actor AccessTokenStore {
	static let service = "com.to.fixsy"
	static var accessTokenKey: String { "\(service).accessToken" }
	static var refreshTokenKey : String { "\(service).refreshToken" }
	
	let keychain: Keychain
	
	public init() {
		self.keychain = Keychain(
			service: Self.service,
			accessGroup: "92XK5S268V.com.iyc.notifyme" // gitleaks:allow
		)
		.accessibility(.afterFirstUnlock)
	}
	
	public func initialize() throws -> AuthCredential? {
		try self.getAuthCredential()
	}
	
	public func getAuthCredential() throws -> AuthCredential? {
		guard
			let accessToken = try? self.keychain.get(Self.accessTokenKey),
			let refreshToken = try? self.keychain.get(Self.refreshTokenKey)
		else {
			return nil
		}
		return AuthCredential(
			accessToken: accessToken,
			refreshToken: refreshToken
		)
	}
	
	@discardableResult
	func updateToken(token: AuthCredential?) throws -> AuthCredential? {
		if let token {
			try self.keychain.set(token.accessToken, key: Self.accessTokenKey)
		} else {
			try self.keychain.remove(Self.accessTokenKey)
		}
		return token
	}
	
}
