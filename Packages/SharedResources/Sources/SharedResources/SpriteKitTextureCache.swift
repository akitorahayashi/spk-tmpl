#if canImport(SpriteKit) && canImport(UIKit)
  import SpriteKit
  import UIKit

  /// Simple NSCache-backed texture pool so SpriteKit nodes reuse GPU resources.
  @MainActor
  public enum SpriteKitTextureCache {
    private static let cache = NSCache<NSString, SKTexture>()

    public static func texture(for asset: ImageAsset) -> SKTexture {
      let key = asset.name as NSString
      if let cached = self.cache.object(forKey: key) {
        return cached
      }

      let texture = SKTexture(image: asset.image)
      self.cache.setObject(texture, forKey: key)
      return texture
    }
  }
#endif
