// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "Packages",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    // App Feature
    .library(name: "AppFeatureCore", targets: ["AppFeatureCore"]),
    .library(name: "AppFeatureUI", targets: ["AppFeatureUI"]),

    // Game Feature
    .library(name: "GameFeatureCore", targets: ["GameFeatureCore"]),
    .library(name: "GameFeatureUI", targets: ["GameFeatureUI"]),
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
      name: "AppFeatureCore",
      dependencies: [
        "GameFeatureCore",
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
      path: "Packages/AppFeature/Sources/AppFeatureCore"
    ),
    .target(
      name: "AppFeatureUI",
      dependencies: [
        "AppFeatureCore",
        "GameFeatureUI",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "Packages/AppFeature/Sources/AppFeatureUI"
    ),
    .testTarget(
      name: "AppFeatureCoreTests",
      dependencies: [
        "AppFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      path: "Packages/AppFeature/Tests/AppFeatureCoreTests"
    ),

    // MARK: - Game Feature

    .target(
      name: "GameFeatureCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
      path: "Packages/GameFeature/Sources/GameFeatureCore"
    ),
    .target(
      name: "GameFeatureUI",
      dependencies: [
        "GameFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "Packages/GameFeature/Sources/GameFeatureUI"
    ),
    .testTarget(
      name: "GameFeatureCoreTests",
      dependencies: [
        "GameFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      path: "Packages/GameFeature/Tests/GameFeatureCoreTests"
    ),
  ]
)
