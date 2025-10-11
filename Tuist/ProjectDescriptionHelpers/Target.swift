import ProjectDescription

public enum TargetInclude: Equatable {
  case sources
  case resources
}

extension [TargetInclude] {
  func sources(name: String, product: ProductKind) -> SourceFilesList {
    self.reduce(
      into: [],
      { sources, include in
        switch (product, include) {
        case (.framework, .sources):
          sources.globs.append("MessageSpring/\(name)/Sources/**.swift")
        case let (.unitTests(of: target), .sources):
          sources.globs.append("MessageSpring/\(target)/Tests/**.swift")
        default:
          break
        }
      }
    )
  }

  func resources(name: String, product: ProductKind) -> ResourceFileElements {
    self.reduce(
      into: [],
      { resources, include in
        switch (product, include) {
        case (.framework, .resources):
          resources.resources.append("MessageSpring/\(name)/Resources/**")
        case let (.unitTests(of: target), .resources):
          resources.resources.append("MessageSpring/\(target)/Tests/Resources/**")
        default:
          break
        }
      }
    )
  }
}

public extension Target {
  static func framework(
    name: String,
    product: ProductKind = .framework,
    includes: [TargetInclude] = [.sources],
    dependencies: [TargetDependency] = []
  ) -> Target {
    .target(
      name: name,
      destinations: .iOS,
      product: product.product,
      bundleId: "com.iyc.notifyme.\(name)",
      sources: includes.sources(name: name, product: product),
      resources: includes.resources(name: name, product: product),
      dependencies: dependencies
    )
  }
}
