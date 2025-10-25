import ProjectDescription

public extension Entitlements {
	static var entitlements: Self {
		.dictionary(
			[
				"com.apple.developer.applesignin": ["Default"],
				"keychain-access-groups": [
					"com.to.fixsy.dev",
					"com.to.fixsy"
				]
			]
		)
	}
}
