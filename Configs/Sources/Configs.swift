import Foundation

public struct Configs {
	public let mobileAPI: MobileAPIConfigs
	public let appGroup: AppGroupConfigs
	public let googleOAuthClientId: String

	public init(mobileAPI: MobileAPIConfigs, appGroup: AppGroupConfigs, googleOAuthClientId: String) {
		self.mobileAPI = mobileAPI
		self.appGroup = appGroup
		self.googleOAuthClientId = googleOAuthClientId
	}
}

public struct MobileAPIConfigs {
	public let hostName: URL

	public init(hostName: URL) {
		self.hostName = hostName
	}
}

public struct Site {
	public let termOfUseURL: URL
	public let policyURL: URL
	public let helpURL: URL
	public let aboutURL: URL
	public let sharableLink: URL
	public let contactURL: URL
}

public struct AppGroupConfigs {
	public let identifier: String
	public let teamId: String

	public init(identifier: String, teamId: String) {
		self.identifier = identifier
		self.teamId = teamId
	}
}
