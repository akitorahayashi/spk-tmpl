#if canImport(UIKit)
  import SpriteKit
  import UIKit

  /// A code-first SpriteKit scene implementing the shooter gameplay.
  ///
  /// This scene handles:
  /// - Player movement via touch drag
  /// - Automatic firing for player and enemy
  /// - Collision detection between bullets and targets
  /// - Win condition (10 kills) and loss condition (player hit)
  @MainActor
  public final class GameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {
    // MARK: - Callbacks

    /// Called when the player kills an enemy.
    public var onPlayerKilledEnemy: (() -> Void)?

    /// Called when the player is hit by an enemy bullet.
    public var onPlayerWasHit: (() -> Void)?

    // MARK: - Nodes

    private let player = SKSpriteNode(imageNamed: "fighter_jet")
    private var enemy = SKSpriteNode(imageNamed: "enemy")

    // MARK: - State

    private var isEnded = false

    // MARK: - Factory

    /// Creates a new game scene with the specified size.
    public static func create(size: CGSize) -> GameScene {
      let scene = GameScene(size: size)
      scene.scaleMode = .aspectFill
      return scene
    }

    // MARK: - Scene Lifecycle

    override public func didMove(to _: SKView) {
      physicsWorld.gravity = .zero
      physicsWorld.contactDelegate = self

      self.isEnded = false
      anchorPoint = CGPoint(x: 0, y: 0)

      self.setupBackground()
      self.setupPlayer()
      self.setupEnemy()
      self.startFiring()
    }

    // MARK: - Setup

    private func setupBackground() {
      let bg = SKSpriteNode(imageNamed: "universe_background")
      bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
      bg.zPosition = -10
      bg.size = size
      addChild(bg)
    }

    private func setupPlayer() {
      self.player.setScale(0.25)

      let radius = max(player.size.width, self.player.size.height) * 0.25
      self.player.physicsBody = SKPhysicsBody(circleOfRadius: radius)
      self.player.physicsBody?.affectedByGravity = false
      self.player.physicsBody?.isDynamic = true
      self.player.physicsBody?.categoryBitMask = PhysicsCategory.player
      self.player.physicsBody?.collisionBitMask = 0
      self.player.physicsBody?.contactTestBitMask = PhysicsCategory.enemyBullet

      self.player.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
      self.player.zPosition = 10
      addChild(self.player)
    }

    private func setupEnemy() {
      self.enemy = SKSpriteNode(imageNamed: "enemy")
      self.enemy.setScale(0.25)
      self.enemy.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
      self.enemy.zPosition = 10

      let radius = max(enemy.size.width, self.enemy.size.height) * 0.25
      self.enemy.physicsBody = SKPhysicsBody(circleOfRadius: radius)
      self.enemy.physicsBody?.affectedByGravity = false
      self.enemy.physicsBody?.isDynamic = true
      self.enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
      self.enemy.physicsBody?.collisionBitMask = 0
      self.enemy.physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet

      addChild(self.enemy)
    }

    private func startFiring() {
      let playerFire = SKAction.sequence([
        .wait(forDuration: 0.2),
        .run { [weak self] in self?.shootPlayerBullet() },
      ])
      run(.repeatForever(playerFire), withKey: "playerFire")

      let enemyFire = SKAction.sequence([
        .wait(forDuration: 0.6),
        .run { [weak self] in self?.shootEnemyBullet() },
      ])
      run(.repeatForever(enemyFire), withKey: "enemyFire")
    }

    // MARK: - Shooting

    private func shootPlayerBullet() {
      guard !self.isEnded else { return }

      let bullet = SKSpriteNode(imageNamed: "bullet_yellow")
      bullet.setScale(0.125)
      bullet.zPosition = 20
      bullet.position = CGPoint(
        x: self.player.position.x,
        y: self.player.position.y + self.player.size.height * 0.5
      )

      let radius = max(bullet.size.width, bullet.size.height) * 0.3
      bullet.physicsBody = SKPhysicsBody(circleOfRadius: radius)
      bullet.physicsBody?.affectedByGravity = false
      bullet.physicsBody?.isDynamic = false
      bullet.physicsBody?.categoryBitMask = PhysicsCategory.playerBullet
      bullet.physicsBody?.collisionBitMask = 0
      bullet.physicsBody?.usesPreciseCollisionDetection = true
      bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy

      addChild(bullet)

      let move = SKAction.moveBy(x: 0, y: size.height + 200, duration: 0.6)
      bullet.run(.sequence([move, .removeFromParent()]))
    }

    private func shootEnemyBullet() {
      guard !self.isEnded else { return }

      let bullet = SKSpriteNode(imageNamed: "bullet_red")
      bullet.setScale(0.125)
      bullet.zPosition = 20
      bullet.position = CGPoint(
        x: self.enemy.position.x,
        y: self.enemy.position.y - self.enemy.size.height * 0.5
      )

      let radius = max(bullet.size.width, bullet.size.height) * 0.3
      bullet.physicsBody = SKPhysicsBody(circleOfRadius: radius)
      bullet.physicsBody?.affectedByGravity = false
      bullet.physicsBody?.isDynamic = false
      bullet.physicsBody?.categoryBitMask = PhysicsCategory.enemyBullet
      bullet.physicsBody?.collisionBitMask = 0
      bullet.physicsBody?.usesPreciseCollisionDetection = true
      bullet.physicsBody?.contactTestBitMask = PhysicsCategory.player

      addChild(bullet)

      let move = SKAction.moveBy(x: 0, y: -(size.height + 200), duration: 0.9)
      bullet.run(.sequence([move, .removeFromParent()]))
    }

    // MARK: - Collision Detection

    public func didBegin(_ contact: SKPhysicsContact) {
      guard !self.isEnded else { return }

      let a = contact.bodyA
      let b = contact.bodyB

      // Player bullet vs enemy
      if
        (a.categoryBitMask == PhysicsCategory.playerBullet && b.categoryBitMask == PhysicsCategory.enemy) ||
        (b.categoryBitMask == PhysicsCategory.playerBullet && a.categoryBitMask == PhysicsCategory.enemy)
      {
        let bulletNode = (a.categoryBitMask == PhysicsCategory.playerBullet ? a.node : b.node)
        let enemyNode = (a.categoryBitMask == PhysicsCategory.enemy ? a.node : b.node)

        bulletNode?.removeFromParent()
        enemyNode?.removeFromParent()

        self.onPlayerKilledEnemy?()
        self.respawnEnemy()
        return
      }

      // Enemy bullet vs player
      if
        (a.categoryBitMask == PhysicsCategory.enemyBullet && b.categoryBitMask == PhysicsCategory.player) ||
        (b.categoryBitMask == PhysicsCategory.enemyBullet && a.categoryBitMask == PhysicsCategory.player)
      {
        let bulletNode = (a.categoryBitMask == PhysicsCategory.enemyBullet ? a.node : b.node)
        bulletNode?.removeFromParent()

        self.endGame()
        self.onPlayerWasHit?()
        return
      }
    }

    // MARK: - Game State

    private func respawnEnemy() {
      self.enemy = SKSpriteNode(imageNamed: "enemy")
      self.enemy.setScale(0.25)
      self.enemy.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
      self.enemy.zPosition = 10

      let radius = max(enemy.size.width, self.enemy.size.height) * 0.25
      self.enemy.physicsBody = SKPhysicsBody(circleOfRadius: radius)
      self.enemy.physicsBody?.affectedByGravity = false
      self.enemy.physicsBody?.isDynamic = true
      self.enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
      self.enemy.physicsBody?.collisionBitMask = 0
      self.enemy.physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet

      addChild(self.enemy)
    }

    private func endGame() {
      self.isEnded = true
      removeAction(forKey: "playerFire")
      removeAction(forKey: "enemyFire")

      // Remove all bullets
      enumerateChildNodes(withName: "//") { node, _ in
        if let body = node.physicsBody {
          if
            body.categoryBitMask == PhysicsCategory.playerBullet ||
            body.categoryBitMask == PhysicsCategory.enemyBullet
          {
            node.removeFromParent()
          }
        }
      }
    }

    // MARK: - Touch Handling

    override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
      guard !self.isEnded else { return }

      for touch in touches {
        let location = touch.location(in: self)
        self.player.position.x = location.x
      }
    }
  }
#endif
