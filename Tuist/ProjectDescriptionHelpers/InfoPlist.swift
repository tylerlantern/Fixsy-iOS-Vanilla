import ProjectDescription

public extension InfoPlist {
  static var appInfoPlist: Self {
    .extendingDefault(
      with: [
        // MARK: - App Basics

        "CFBundleDisplayName": "Fixsy",
        "LSRequiresIPhoneOS": .boolean(true),
        "UILaunchStoryboardName": .string("LaunchScreen"),
        "CFBundleShortVersionString": "$(MARKETING_VERSION)",
        "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",

        // MARK: - Launch Services / URL Schemes the app may query

        "LSApplicationQueriesSchemes": .array([
          // Browsers & Maps
          .string("googlechromes"),
          .string("comgooglemaps"),
          .string("maps"),
          // Facebook variants
          .string("fbapi"),
          .string("fbapi20130214"),
          .string("fbapi20130410"),
          .string("fbapi20130702"),
          .string("fbapi20131010"),
          .string("fbapi20131219"),
          .string("fbapi20140410"),
          .string("fbapi20140116"),
          .string("fbapi20150313"),
          .string("fbapi20150629"),
          .string("fbapi20160328"),
          .string("fbauth"),
          .string("fbauth2"),
          .string("fb-messenger-share-api"),
          .string("fbshareextension")
        ]),

        // MARK: - Orientations

        "UISupportedInterfaceOrientations": .array([
          "UIInterfaceOrientationPortrait"
        ]),
        "UISupportedInterfaceOrientations~ipad": .array([
          "UIInterfaceOrientationPortrait",
          "UIInterfaceOrientationPortraitUpsideDown",
          "UIInterfaceOrientationLandscapeLeft",
          "UIInterfaceOrientationLandscapeRight"
        ]),
        "UIRequiresFullScreen~ipad": .boolean(true),

        // MARK: - Background Modes

        "UIBackgroundModes": .array([
          "location",
          "remote-notification"
        ]),

        // MARK: - Privacy Usage Strings

        "NSCalendarsUsageDescription": .string(
          "This app needs access to your calendar to add and edit events."
        ),
        "NSLocationAlwaysAndWhenInUseUsageDescription": .string(
          "We use your location to show you nearby services such as Motorcycle stations, Car service stations, Tire Inflation stations, Patching Tire stations, and Wash stations. This helps you find the services you need quickly and conveniently, based on your current location."
        ),
        "NSLocationAlwaysUsageDescription": .string(
          "We use your location to show you nearby services such as Motorcycle stations, Car service stations, Tire Inflation stations, Patching Tire stations, and Wash stations. This helps you find the services you need quickly and conveniently, based on your current location."
        ),
        "NSLocationWhenInUseUsageDescription": .string(
          "We use your location to show you nearby services such as Motorcycle stations, Car service stations, Tire Inflation stations, Patching Tire stations, and Wash stations. This helps you find the services you need quickly and conveniently, based on your current location."
        ),
        "NSCameraUsageDescription": .string(
          "Enable Fixsy to access your camera to take a photo and upload place's image."
        ),
        "NSPhotoLibraryAddUsageDescription": .string(
          "Enable Fixsy to access your Photos to upload place's images or to download palce's images."
        ),
        "NSPhotoLibraryUsageDescription": .string(
          "Enable Fixsy to access your Photos to upload place's images or to download palce's images."
        ),

        // MARK: - Apple Intents

        "NSUserActivityTypes": .array(["INSendMessageIntent"]),

        // MARK: - App Transport Security

        // MARK: - Encryption export

        "ITSAppUsesNonExemptEncryption": .boolean(false),

        // MARK: - Launch Screen (keep empty dict if you’re using storyboard name above)

        "UILaunchScreen": [:],

        // MARK: - Facebook Sign In / Analytics

        "FacebookAppID": .string("$(FACEBOOK_APP_ID)"),
        "FacebookClientToken": .string("$(FACEBOOK_CLIENT_TOKEN)"),
        "FacebookDisplayName": .string("$(PRODUCT_NAME)"),
        "FacebookAutoLogAppEventsEnabled": .boolean(true),
        "FacebookAdvertiserIDCollectionEnabled": .boolean(true),

        // MARK: - Google Sign In

        "GIDClientID": .string("$(GOOGLE_OAUTH_CLIENT_ID).apps.googleusercontent.com"),
        "GIDServerClientID": .string("$(GOOGLE_WEB_CLIENT_ID)"),
        "GOOGLE_OAUTH_CLIENT_ID": .string("$(GOOGLE_OAUTH_CLIENT_ID)"),

        // MARK: - URL Types

        "CFBundleURLTypes": [
          [
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["com.fixsy"]
          ],
          [
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["applinks"]
          ],
          [
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["com.googleusercontent.apps.$(GOOGLE_OAUTH_CLIENT_ID)"]
          ],
          [
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["fb$(FACEBOOK_APP_ID)"]
          ]
        ],

        // MARK: - Localizations

        "CFBundleLocalizations": [
          "en", "th"
        ]
      ]
    )
  }
}
