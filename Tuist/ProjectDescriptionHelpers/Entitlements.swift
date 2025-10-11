import ProjectDescription

public extension Entitlements {
  static var entitlements: Self {
    .dictionary(
      [
        "com.apple.developer.usernotifications.communication": true,
        "aps-environment": "development",
        "com.apple.developer.applesignin": ["Default"],
        "com.apple.developer.associated-domains": [
          "webcredentials:notifications-dev.messagespring.com",
          "webcredentials:notifications-qa.messagespring.com",
          "webcredentials:notifications.messagespring.com",
          "webcredentials:messagespring.com",
          "messagespring:messagespring.onelink.me",
          "applinks:messagespring.onelink.me",
          "applinks:www.appsflyer.com",
          "applinks:notifyme.onelink.me",
          "applinks:notifyme2.onelink.me"
        ],
        "com.apple.security.application-groups": [
          "group.com.iyc.notifyme"
        ],
        "keychain-access-groups": [
          "$(AppIdentifierPrefix)com.iyc.notifyme"
        ]
      ]
    )
  }
}
