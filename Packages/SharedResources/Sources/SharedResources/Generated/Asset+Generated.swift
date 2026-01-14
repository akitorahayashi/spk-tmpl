// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum Backgrounds {
    public static let universeBackground = ImageAsset(name: "Backgrounds/universe_background")
  }

  public enum Items {
    public enum Bullets {
      public static let bulletRed = ImageAsset(name: "Items/Bullets/bullet_red")
      public static let bulletYellow = ImageAsset(name: "Items/Bullets/bullet_yellow")
    }
  }

  public enum Scenes {
    public enum Game {
      public enum Enemies {
        public static let enemy = ImageAsset(name: "Scenes/Game/Enemies/enemy")
      }

      public enum Player {
        public static let fighterJet = ImageAsset(name: "Scenes/Game/Player/fighter_jet")
      }
    }
  }
}

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ImageAsset: Sendable {
  public let name: String

  #if os(macOS)
    public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
    public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS)
      let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
      let name = NSImage.Name(self.name)
      let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
      let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
    @available(iOS 8.0, tvOS 9.0, *)
    public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
      let bundle = Bundle.module
      guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
        fatalError("Unable to load image asset named \(self.name).")
      }
      return result
    }
  #endif

  #if canImport(SwiftUI)
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    public var swiftUIImage: SwiftUI.Image {
      SwiftUI.Image(asset: self)
    }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(
    macOS,
    deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property"
  )
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
      let bundle = Bundle.module
      self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
      self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
      self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public extension SwiftUI.Image {
    init(asset: ImageAsset) {
      let bundle = Bundle.module
      self.init(asset.name, bundle: bundle)
    }

    init(asset: ImageAsset, label: Text) {
      let bundle = Bundle.module
      self.init(asset.name, bundle: bundle, label: label)
    }

    init(decorative asset: ImageAsset) {
      let bundle = Bundle.module
      self.init(decorative: asset.name, bundle: bundle)
    }
  }
#endif
