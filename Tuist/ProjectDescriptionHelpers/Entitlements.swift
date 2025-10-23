import ProjectDescription

public extension Entitlements {
	static var entitlements: Self {
		.dictionary(
			[
				"com.apple.developer.applesignin": ["Default"],
				"keychain-access-groups": [
					"$(AppIdentifierPrefix)com.to.fixsy.dev",
					"$(AppIdentifierPrefix)com.to.fixsy.qa",
					"$(AppIdentifierPrefix)com.to.fixsy.uat",
					"$(AppIdentifierPrefix)com.to.fixsy"
				]
			]
		)
	}
}
