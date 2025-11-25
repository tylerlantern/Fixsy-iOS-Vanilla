import ProjectDescription
import ProjectDescriptionHelpers

let prefixBundleId = "com.to.fixsy."

let bottomSheetModuleScheme = Scheme.scheme(
  name: "BottomSheetModuleApp",
  buildAction: .buildAction(targets: [.target("BottomSheetModule")]),
  runAction: .runAction(configuration: .debug)
)

let fixsyRelease = Scheme.scheme(
  name: "FixsyReleaseApp",
  buildAction: .buildAction(targets: [.target("AppCore")]),
  runAction: .runAction(configuration: .release)
)

let fixsy = Scheme.scheme(
  name: "Fixsy",
  shared: true,
  buildAction: .buildAction(targets: [.target("AppCore")]),
  testAction: .targets([
    .testableTarget(target: "APIClientTests"),
    .testableTarget(target: "SearchFeatureTests")
  ]),
  archiveAction: .archiveAction(configuration: "Release")
)

let project = Project(
  name: "Fixsy",
  settings: .settings(
    base: .project_base,
    configurations: [
      .debug(name: "Debug", settings: .project_debug),
      .release(name: "Release", settings: .project_release)
    ]
  ),
  targets: [
    .target(
      name: "AppCore",
      destinations: .iOS,
      product: .app,
      bundleId: "com.to.fixsy",
      infoPlist: .appInfoPlist,
      sources: ["AppCore/Sources/**"],
      resources: ["AppCore/Resources/**"],
      entitlements: .entitlements,
      dependencies: [
        // Start Config
        .target(name: "Configs"),
        .target(name: "ConfigsLive"),
        // End Configs

        .target(name: "Router"),
        .target(name: "RouterLive"),

        // Start Store
        .target(name: "PlaceStore"),
        // End Store

        // Start Clients
        .target(name: "AccessTokenClient"),
        .target(name: "AccessTokenClientLive"),
        .target(name: "APIClient"),
        .target(name: "APIClientLive"),
        .target(name: "DatabaseClient"),
        .target(name: "DatabaseClientLive"),
        .target(name: "LocationManagerClient"),
        .target(name: "LocationManagerClientLive"),
        .target(name: "AuthProvidersClient"),
        .target(name: "AuthProvidersClientLive"),
        // End Clients

        // Start Component
        .target(name: "BannerToastComponent")
        // End Component

      ],
      settings: .settings(
        base: .app_base
          .merging(.secret_base)
          .merging([
            "MARKETING_VERSION": "2.0.0",
            "CURRENT_PROJECT_VERSION": "1"
          ]),
        configurations: [
          .debug(name: "Debug", settings: .app_debug.merging(.secret_debug).merging([
            "PROVISIONING_PROFILE_SPECIFIER": "match Development com.to.fixsy.dev",
            "PRODUCT_BUNDLE_IDENTIFIER": "com.to.fixsy.dev"
          ])),
          .release(name: "Release", settings: .app_release.merging(.secret_release).merging([
            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.to.fixsy",
            "PRODUCT_BUNDLE_IDENTIFIER": "com.to.fixsy"
          ]))
        ]
      ),
    ),
    .target(
      name: "Router",
      destinations: .iOS,
      product: .framework,
      bundleId: "\(prefixBundleId)Router",
      infoPlist: .default,
      sources: ["Router/Sources/**"],
      dependencies: [
        .target(name: "Models")
      ]
    ),
    .target(
      name: "RouterLive",
      destinations: .iOS,
      product: .framework,
      bundleId: "\(prefixBundleId)RouterLive",
      infoPlist: .default,
      sources: ["RouterLive/Sources/**"],
      dependencies: [
        .target(name: "Router"),
        // Features
        .target(name: "TabContainerFeature"),
        .target(name: "HomeFeature"),
        .target(name: "DetailFeature"),
        .target(name: "ExploreFeature"),
        .target(name: "ChatListFeature"),
        .target(name: "ProfileFeature"),
        .target(name: "CommentFeature"),
        .target(name: "ExpandedCommentFeature"),
        .target(name: "SearchFeature"),
        .target(name: "LocationManagerClient"),
        .target(name: "DatabaseClient"),
        .target(name: "ImagesInspectorFeature"),
        .target(name: "SocialSignInFeature"),
        .target(name: "UserProfileFeature"),
        .target(name: "EditingNameFeature"),
        .target(name: "ReviewListFeature"),
        .target(name: "ReviewFormFeature"),
        .target(name: "CarBrandsFeature"),
        .target(name: "ChangeAppLanguageFeature")
      ]
    ),

    // Start Components
    .component(
      name: "CapsulesStackComponent"
    ),
    .component(
      name: "CarBrandComponent"
    ),
    .component(
      name: "BannerToastComponent",
      dependencies: [
        .target(name: "BannerCenterModule")
      ]
    ),
    .component(
      name: "ContentHeightSheetComponent"
    ),
    .component(
      name: "StarRatingComponent"
    ),
    .component(
      name: "ShimmerComponent"
    ),
    // End Components

    // Start Config
    .framework(
      name: "Configs"
    ),
    .framework(
      name: "ConfigsLive",
      dependencies: [
        .target(name: "Configs")
      ]
    ),
    // End Config

    // Start Model
    .framework(
      name: "Models"
    ),
    .framework(
      name: "UserProfileModel"
    ),
    .framework(
      name: "TokenModel"
    ),
    // End Model
    // Start Store
    .framework(
      name: "PlaceStore",
      dependencies: [
        .target(name: "Models"),
        .target(name: "DatabaseClient"),
        .target(name: "APIClient")
      ]
    ),
    // End Stores

    // Start Modules
    .module(
      name: "BottomSheetModule",
      dependencies: []
    ),
    .demoModule(
      "BottomSheetModule",
      deps: []
    ),
    .module(
      name: "BannerCenterModule",
      dependencies: []
    ),
    // End Modules

    // Start Client
    .framework(
      name: "AccessTokenClient",
      dependencies: [
        .target(name: "TokenModel")
      ]
    ),
    .framework(
      name: "AccessTokenClientLive",
      dependencies: [
        .target(name: "AccessTokenClient"),
        .external(name: "KeychainAccess")
      ]
    ),
    .framework(
      name: "APIClient",
      hasResource: true,
      dependencies: []
    ),
    .target(
      name: "APIClientTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "\(prefixBundleId)APIClientTests",
      infoPlist: .default,
      // 👇 This is the folder shape you asked for
      sources: ["Tests/APIClientTests/**"],
      resources: [],
      dependencies: [
        .target(name: "APIClient")
      ]
    ),
    .framework(
      name: "APIClientLive",
      dependencies: [
        .target(name: "APIClient"),
        .target(name: "TokenModel"),
        .target(name: "AccessTokenClientLive")
      ]
    ),
    .framework(
      name: "DatabaseClient",
      dependencies: [
        .target(name: "UserProfileModel"),
        .target(name: "Models"),
        .external(name: "GRDB")
      ]
    ),
    .framework(
      name: "DatabaseClientLive",
      dependencies: [
        .target(name: "DatabaseClient")
      ]
    ),
    .framework(
      name: "LocationManagerClient",
      dependencies: []
    ),
    .framework(
      name: "LocationManagerClientLive",
      dependencies: [
        .target(name: "LocationManagerClient")
      ]
    ),
    .framework(
      name: "AuthProvidersClient",
      dependencies: []
    ),
    .framework(
      name: "AuthProvidersClientLive",
      dependencies: [
        .external(name: "GoogleSignIn"),
        .target(name: "AuthProvidersClient")
      ]
    ),
    // End Client

    // Start Features
    .framework(
      name: "TabContainerFeature",
      dependencies: [
        .target(name: "Router")
      ]
    ),
    .framework(
      name: "HomeFeature",
      hasResource: true,
      dependencies: [
        .external(name: "AsyncAlgorithms"),
        .target(name: "AuthProvidersClient"),
        .target(name: "Router"),
        .target(name: "Models"),
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "LocationManagerClient"),
        .target(name: "BottomSheetModule"),
        .target(name: "PlaceStore"),
        .target(name: "BannerCenterModule")
      ]
    ),
    .demoApp(
      "HomeFeature",
      deps: []
    ),
    .framework(
      name: "DetailFeature",
      hasResource: true,
      dependencies: [
        .target(name: "Router"),
        .target(name: "Models"),
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "CapsulesStackComponent"),
        .target(name: "CarBrandComponent"),
        .target(name: "AccessTokenClient"),
        .target(name: "ContentHeightSheetComponent")
      ]
    ),
    .demoApp(
      "DetailFeature",
      deps: []
    ),
    .framework(
      name: "CommentFeature",
      dependencies: [
        .target(name: "Router")
      ]
    ),
    .framework(
      name: "ExpandedCommentFeature",
      dependencies: [
        .target(name: "Router")
      ]
    ),
    .framework(
      name: "ExploreFeature",
      dependencies: [
        .target(name: "Router")
      ]
    ),
    .framework(
      name: "ChatListFeature",
      dependencies: [
        .target(name: "Router")
      ]
    ),
    .framework(
      name: "ProfileFeature",
      dependencies: [
        .target(name: "Router")
      ]
    ),
    .framework(
      name: "SearchFeature",
      hasResource: true,
      dependencies: [
        .external(name: "AsyncAlgorithms"),
        .target(name: "Router"),
        .target(name: "Models"),
        .target(name: "DatabaseClient"),
        .target(name: "LocationManagerClient"),
        .target(name: "BottomSheetModule"),
        .target(name: "PlaceStore"),
        .target(name: "APIClient"),
        .target(name: "AccessTokenClient"),
        .target(name: "ContentHeightSheetComponent"),
        .target(name: "BannerCenterModule")
      ]
    ),
    .demoApp(
      "SearchFeature",
      deps: []
    ),
    .framework(
      name: "ImagesInspectorFeature",
      dependencies: []
    ),
    .target(
      name: "SearchFeatureTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "\(prefixBundleId)SearchFeatureTests",
      infoPlist: .default,
      // 👇 This is the folder shape you asked for
      sources: ["Tests/SearchFeatureTests/**"],
      resources: [],
      dependencies: [
        .target(name: "SearchFeature")
      ]
    ),
    .framework(
      name: "SocialSignInFeature",
      hasResource: true,
      dependencies: [
        .target(name: "AccessTokenClient"),
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "AuthProvidersClient"),
        .target(name: "BannerCenterModule")
      ]
    ),
    .demoApp(
      "SocialSignInFeature",
      deps: []
    ),
    .framework(
      name: "UserProfileFeature",
      hasResource: true,
      dependencies: [
        .target(name: "AccessTokenClient"),
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "UserProfileModel"),
        .target(name: "Router"),
        .target(name: "BannerCenterModule"),
        .target(name: "AuthProvidersClient")
      ]
    ),
    .demoApp(
      "UserProfileFeature",
      deps: []
    ),
    .framework(
      name: "EditingNameFeature",
      hasResource: true,
      dependencies: [
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "UserProfileModel"),
        .target(name: "Router"),
        .target(name: "BannerCenterModule")
      ]
    ),
    .framework(
      name: "ReviewListFeature",
      hasResource: true,
      dependencies: [
        .target(name: "AccessTokenClient"),
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "BannerCenterModule"),
        .target(name: "CapsulesStackComponent"),
        .target(name: "Models"),
        .target(name: "CarBrandComponent"),
        .target(name: "StarRatingComponent"),
        .target(name: "ShimmerComponent")
      ]
    ),
    .demoApp(
      "ReviewListFeature",
      deps: [
        .target(name: "APIClientLive"),
        .target(name: "DatabaseClientLive"),
        .target(name: "AccessTokenClientLive"),
        .target(name: "Configs"),
        .target(name: "ConfigsLive"),
        .target(name: "StarRatingComponent")
      ]
    ),
    .framework(
      name: "ReviewFormFeature",
      hasResource: true,
      dependencies: [
        .external(name: "AsyncAlgorithms"),
        .target(name: "Router"),
        .target(name: "Models"),
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "CapsulesStackComponent"),
        .target(name: "CarBrandComponent"),
        .target(name: "StarRatingComponent"),
        .target(name: "CarBrandsFeature"),
        .target(name: "BannerCenterModule")
      ]
    ),
    .demoApp(
      "ReviewFormFeature",
      deps: []
    ),
    .framework(
      name: "CarBrandsFeature",
      hasResource: true,
      dependencies: [
        .external(name: "AsyncAlgorithms"),
        .target(name: "Router"),
        .target(name: "Models"),
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "CapsulesStackComponent"),
        .target(name: "CarBrandComponent"),
        .target(name: "ShimmerComponent"),
        .target(name: "ShimmerComponent")
      ]
    ),
    .demoApp(
      "CarBrandsFeature",
      deps: [
        .target(name: "APIClientLive"),
        .target(name: "DatabaseClientLive"),
        .target(name: "AccessTokenClientLive"),
        .target(name: "Configs"),
        .target(name: "ConfigsLive"),
        .target(name: "StarRatingComponent")
      ],
    ),
    .framework(
      name: "ChangeAppLanguageFeature",
      hasResource: true,
      dependencies: []
    ),
    .demoApp(
      "ChangeAppLanguageFeature",
      deps: []
    )
    // End Features
  ],
  schemes: [
    bottomSheetModuleScheme,
    fixsy,
    .scheme(
      name: "Fixsy-Tests",
      shared: true,
      buildAction: .buildAction(targets: [.target("AppCore")]),
      testAction: .targets([
        .testableTarget(target: "APIClientTests"),
        .testableTarget(target: "SearchFeatureTests")
      ]),
    )
  ]
)

public extension Target {
  static func framework(
    name: String,
    hasResource: Bool = false,
    dependencies: [TargetDependency] = []
  ) -> Target {
    .target(
      name: name,
      destinations: .iOS,
      product: .framework,
      bundleId: "\(prefixBundleId)\(name)",
      infoPlist: .default,
      sources: ["\(name)/Sources/**"],
      resources: hasResource ? ["\(name)/Resources/**"] : nil,
      dependencies: dependencies,
    )
  }

  static func component(
    name: String,
    hasResource: Bool = false,
    dependencies: [TargetDependency] = []
  ) -> Target {
    .target(
      name: name,
      destinations: .iOS,
      product: .framework,
      bundleId: "\(prefixBundleId)\(name)",
      infoPlist: .default,
      sources: ["Components/\(name)/Sources/**"],
      resources: hasResource ? ["Components/\(name)/Resources/**"] : nil,
      dependencies: dependencies
    )
  }

  static func module(
    name: String,
    hasResource: Bool = false,
    dependencies: [TargetDependency] = []
  ) -> Target {
    .target(
      name: name,
      destinations: .iOS,
      product: .framework,
      bundleId: "\(prefixBundleId)\(name)",
      infoPlist: .default,
      sources: ["Modules/\(name)/Sources/**"],
      resources: hasResource ? ["Modules/\(name)/Resources/**"] : nil,
      dependencies: dependencies
    )
  }

  static func demoModule(_ prefix: String, deps: [TargetDependency] = []) -> Target {
    .target(
      name: "\(prefix)App",
      destinations: .iOS,
      product: .app,
      bundleId: "io.tuist.\(prefix.lowercased()).demo",
      infoPlist: .extendingDefault(with: ["UILaunchScreen": [:]]),
      sources: ["Modules/\(prefix)/DemoApp/**"],
      resources: [],
      dependencies: [.target(name: prefix)] + deps
    )
  }

  static func demoApp(_ prefix: String, deps: [TargetDependency] = []) -> Target {
    .target(
      name: "\(prefix)App",
      destinations: .iOS,
      product: .app,
      bundleId: "io.tuist.\(prefix.lowercased()).demo",
      infoPlist: .extendingDefault(with: ["UILaunchScreen": [:]]),
      sources: ["\(prefix)/DemoApp/**"],
      resources: [],
      dependencies: [.target(name: prefix)] + deps
    )
  }
}

public func productType() -> Product {
  if case let .string(productType) = Environment.productType {
    return productType == "static-library" ? .staticLibrary : .framework
  } else {
    return .framework
  }
}

public enum TargetInclude {
  case sources
  case resources
}
