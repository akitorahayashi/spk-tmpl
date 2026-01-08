#if canImport(SpriteKit) && canImport(UIKit)
  import SpriteKit
  import UIKit

  public extension SKSpriteNode {
    /// Creates a sprite node with texture from a type-safe image asset.
    ///
    /// Uses `imageNamed` internally to leverage SpriteKit's texture caching.
    convenience init(asset: ImageAsset) {
      self.init(imageNamed: asset.name)
    }
  }

  public extension SKTexture {
    /// Creates a texture from a type-safe image asset.
    ///
    /// Uses `imageNamed` internally to leverage SpriteKit's texture caching.
    convenience init(asset: ImageAsset) {
      self.init(imageNamed: asset.name)
    }
  }
#endif
