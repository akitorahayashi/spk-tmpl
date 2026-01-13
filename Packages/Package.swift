// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "Packages",
  defaultLocalization: "en",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    // App Feature
    .library(name: "AppFeatureCore", targets: ["AppFeatureCore"]),
    .library(name: "AppFeatureUI", targets: ["AppFeatureUI"]),

    // Title Feature
    .library(name: "TitleFeatureCore", targets: ["TitleFeatureCore"]),
    .library(name: "TitleFeatureUI", targets: ["TitleFeatureUI"]),

    // Home Feature
    .library(name: "HomeFeatureCore", targets: ["HomeFeatureCore"]),
    .library(name: "HomeFeatureUI", targets: ["HomeFeatureUI"]),

    // Game Feature
    .library(name: "GameFeatureCore", targets: ["GameFeatureCore"]),
    .library(name: "GameFeatureUI", targets: ["GameFeatureUI"]),

    // Shared Resources
    .library(name: "SharedResources", targets: ["SharedResources"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.10.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.7.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.1"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-perception", from: "2.0.9"),
    .package(url: "https://github.com/pointfreeco/swift-clocks", from: "1.0.0"),
  ],
  targets: [
    // MARK: - App Feature

    .target(
      name: "AppFeatureCore",
      dependencies: [
        "TitleFeatureCore",
        "HomeFeatureCore",
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
      path: "AppFeature/Sources/AppFeatureCore"
    ),
    .target(
      name: "AppFeatureUI",
      dependencies: [
        "AppFeatureCore",
        "TitleFeatureUI",
        "HomeFeatureUI",
        "GameFeatureUI",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "AppFeature/Sources/AppFeatureUI"
    ),
    .testTarget(
      name: "AppFeatureCoreTests",
      dependencies: [
        "AppFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      path: "AppFeature/Tests/AppFeatureCoreTests"
    ),

    // MARK: - Title Feature

    .target(
      name: "TitleFeatureCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "TitleFeature/Sources/TitleFeatureCore"
    ),
    .target(
      name: "TitleFeatureUI",
      dependencies: [
        "TitleFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "TitleFeature/Sources/TitleFeatureUI"
    ),
    .testTarget(
      name: "TitleFeatureCoreTests",
      dependencies: [
        "TitleFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "TitleFeature/Tests/TitleFeatureCoreTests"
    ),

    // MARK: - Home Feature

    .target(
      name: "HomeFeatureCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      path: "HomeFeature/Sources/HomeFeatureCore"
    ),
    .target(
      name: "HomeFeatureUI",
      dependencies: [
        "HomeFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "HomeFeature/Sources/HomeFeatureUI"
    ),
    .testTarget(
      name: "HomeFeatureCoreTests",
      dependencies: [
        "HomeFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "HomeFeature/Tests/HomeFeatureCoreTests"
    ),

    // MARK: - Game Feature

    .target(
      name: "GameFeatureCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Clocks", package: "swift-clocks"),
      ],
      path: "GameFeature/Sources/GameFeatureCore"
    ),
    .target(
      name: "GameFeatureUI",
      dependencies: [
        "GameFeatureCore",
        "SharedResources",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      path: "GameFeature/Sources/GameFeatureUI"
    ),
    .testTarget(
      name: "GameFeatureCoreTests",
      dependencies: [
        "GameFeatureCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      path: "GameFeature/Tests/GameFeatureCoreTests"
    ),

    // MARK: - Shared Resources

    .target(
      name: "SharedResources",
      dependencies: [],
      path: "SharedResources/Sources/SharedResources",
      resources: [
        .process("Resources"),
      ]
    ),
  ]
)
