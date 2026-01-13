import Foundation
import SpriteKit

/// Physics category bitmasks for collision detection.
public enum PhysicsCategory {
  public static let player: UInt32 = 1 << 0
  public static let enemy: UInt32 = 1 << 1
  public static let playerBullet: UInt32 = 1 << 2
  public static let enemyBullet: UInt32 = 1 << 3
}
