#if canImport(SpriteKit) && canImport(UIKit)
  import SpriteKit
  import UIKit

  public extension SKSpriteNode {
    convenience init(asset: ImageAsset) {
      let texture = SpriteKitTextureCache.texture(for: asset)
      self.init(texture: texture, color: .clear, size: texture.size())
    }
  }

  public extension SKTexture {
    convenience init(asset: ImageAsset) {
      self.init(image: asset.image)
    }
  }
#endif
