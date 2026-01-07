// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "Packages",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    // App Feature
    .library(name: "AppFeatureDomain", targets: ["AppFeatureDomain"]),
    .library(name: "AppFeatureUI", targets: ["AppFeatureUI"]),

    // Counter Feature
    .library(name: "CounterFeatureDomain", targets: ["CounterFeatureDomain"]),
    .library(name: "CounterFeatureUI", targets: ["CounterFeatureUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.10.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.7.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.1"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-perception", from: "2.0.9"),
  ],
  targets: [
    // MARK: - App Feature

    .target(
      name: "AppFeatureDomain",
      dependencies: [
        "CounterFeatureDomain",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        // TCA transitive dependencies - made explicit for Xcode linking stability
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "CasePathsCore", package: "swift-case-paths"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "Perception", package: "swift-perception"),
        .product(name: "PerceptionCore", package: "swift-perception"),
      ],
      path: "Packages/AppFeature/Sources/AppFeatureDomain"
    ),
    .target(
      name: "AppFeatureUI",
      dependencies: [
        "AppFeatureDomain",
        "CounterFeatureUI",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "Packages/AppFeature/Sources/AppFeatureUI"
    ),
    .testTarget(
      name: "AppFeatureDomainTests",
      dependencies: [
        "AppFeatureDomain",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      path: "Packages/AppFeature/Tests/AppFeatureDomainTests"
    ),

    // MARK: - Counter Feature

    .target(
      name: "CounterFeatureDomain",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
      path: "Packages/CounterFeature/Sources/CounterFeatureDomain"
    ),
    .target(
      name: "CounterFeatureUI",
      dependencies: [
        "CounterFeatureDomain",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "Packages/CounterFeature/Sources/CounterFeatureUI"
    ),
    .testTarget(
      name: "CounterFeatureDomainTests",
      dependencies: [
        "CounterFeatureDomain",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      path: "Packages/CounterFeature/Tests/CounterFeatureDomainTests"
    ),
  ]
)
