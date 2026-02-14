// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
  import struct ProjectDescription.PackageSettings

  let packageSettings = PackageSettings(
    // Customize the product types for specific package product
    // Default is .staticFramework
    // productTypes: ["Alamofire": .framework,]
    productTypes: [:]
  )
#endif

let package = Package(
  name: "iOS",
  dependencies: [
    // You can read more about dependencies here:
    // shttps://docs.tuist.io/documentation/tuist/dependencies
    .package(
      url: "https://github.com/kishikawakatsumi/KeychainAccess.git",
      from: "4.2.2"
    ),
    .package(
      url: "https://github.com/groue/GRDB.swift.git",
      from: "7.8.0"
    ),
    .package(
      url: "https://github.com/apple/swift-async-algorithms",
      from: "1.0.4"
    ),
    .package(
      url: "https://github.com/google/GoogleSignIn-iOS.git",
      from: "9.1.0"
    )
  ]
)
