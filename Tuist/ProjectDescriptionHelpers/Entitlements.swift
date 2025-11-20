import ProjectDescription

public extension Entitlements {
  static var entitlements: Self {
    .dictionary(
      [
        "com.apple.developer.applesignin": ["Default"],
        "keychain-access-groups": .array([
          "$(AppIdentifierPrefix)com.to.fixsy.dev",
          "$(AppIdentifierPrefix)com.to.fixsy"
        ])
      ]
    )
  }
}
