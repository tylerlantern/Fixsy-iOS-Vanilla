import ProjectDescription
import ProjectDescriptionHelpers

let prefixBundleId = "io.tuist."

let homeDemoScheme = Scheme.scheme(
  name: "HomeFeatureApp",
  buildAction: .buildAction(targets: [.target("HomeFeatureApp")]),
  runAction: .runAction(configuration: .debug)
)

let project = Project(
  name: "iOSApp",
  targets: [
    .target(
      name: "AppCore",
      destinations: .iOS,
      product: .app,
      bundleId: "\(prefixBundleId).appcore",
      infoPlist: .appInfoPlist,
      sources: ["AppCore/Sources/**"],
      resources: ["AppCore/Resources/**"],
      dependencies: [
        // Start Config
        .target(name: "Configs"),
        .target(name: "ConfigsLive"),
        // End Configs

        .target(name: "Router"),
        .target(name: "RouterLive"),

        // Start Clients
        .target(name: "AccessTokenClient"),
        .target(name: "AccessTokenClientLive"),
        .target(name: "APIClient"),
        .target(name: "APIClientLive"),
        .target(name: "DatabaseClient"),
        .target(name: "DatabaseClientLive"),
        .target(name: "LocationManagerClient"),
        .target(name: "LocationManagerClientLive")
        // End Clients

      ],
      settings: .settings(
        base: [
          "PRODUCT_NAME": "DuckHorde"
        ]
      )
    ),
    // TEST Example
    //		.target(
    //			name: "iOSTests",
    //			destinations: .iOS,
    //			product: .unitTests,
    //			bundleId: "io.tuist.iOSTests",
    //			infoPlist: .default,
    //			sources: ["iOS/Tests/**"],
    //			resources: [],
    //			dependencies: [.target(name: "iOS")]
    //		)
    .target(
      name: "Router",
      destinations: .iOS,
      product: .framework,
      bundleId: "\(prefixBundleId)Router",
      infoPlist: .default,
      sources: ["Router/Sources/**"],
      dependencies: []
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
        .target(name: "ExpandedCommentFeature")
      ]
    ),

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
    // End Client

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
        .target(name: "Router"),
        .target(name: "Models"),
        .target(name: "APIClient"),
        .target(name: "DatabaseClient"),
        .target(name: "LocationManagerClient")
      ]
    ),
    .featureDemoApp(
      "HomeFeature",
      deps: []
    ),
    .framework(
      name: "DetailFeature",
      dependencies: [
        .target(name: "Router")
      ]
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
    )
  ],
  schemes: [
    homeDemoScheme
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
      dependencies: dependencies
    )
  }

  static func featureDemoApp(_ feature: String, deps: [TargetDependency] = []) -> Target {
    .target(
      name: "\(feature)App",
      destinations: .iOS,
      product: .app,
      bundleId: "io.tuist.\(feature.lowercased()).demo",
      infoPlist: .extendingDefault(with: ["UILaunchScreen": [:]]),
      sources: ["\(feature)/DemoApp/**"],
      resources: [],
      dependencies: [.target(name: feature)] + deps
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
