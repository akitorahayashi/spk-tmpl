#if canImport(UIKit)
  import SharedResources
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
    // MARK: - Constants

    private enum NodeName {
      static let background = "background"
      static let playerBullet = "playerBullet"
      static let enemyBullet = "enemyBullet"
    }

    // MARK: - Callbacks

    /// Called when the player kills an enemy.
    public var onPlayerKilledEnemy: (() -> Void)?

    /// Called when the player is hit by an enemy bullet.
    public var onPlayerWasHit: (() -> Void)?

    // MARK: - Nodes

    private let player = SKSpriteNode(asset: Asset.Scenes.Game.Player.fighterJet)
    private var enemy = SKSpriteNode(asset: Asset.Scenes.Game.Enemies.enemy)

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

    override public func didChangeSize(_ oldSize: CGSize) {
      super.didChangeSize(oldSize)
      guard size != oldSize, size.width > 0, size.height > 0 else { return }

      // Re-layout background
      if let bg = childNode(withName: NodeName.background) as? SKSpriteNode {
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size = size
      }

      // Re-position player (keep relative x position)
      if oldSize.width > 0 {
        let relativeX = self.player.position.x / oldSize.width
        self.player.position = CGPoint(x: size.width * relativeX, y: size.height * 0.15)
      } else {
        self.player.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
      }

      // Re-position enemy
      self.enemy.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
    }

    // MARK: - Setup

    private func setupBackground() {
      let bg = SKSpriteNode(asset: Asset.Backgrounds.universeBackground)
      bg.name = NodeName.background
      bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
      bg.zPosition = -10
      bg.size = size
      addChild(bg)
    }

    private func setupPlayer() {
      self.player.setScale(0.25)

      let radius = max(player.size.width, self.player.size.height) * self.player.xScale / 2
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
      self.enemy = self.createEnemyNode()
      addChild(self.enemy)
    }

    private func createEnemyNode() -> SKSpriteNode {
      let node = SKSpriteNode(asset: Asset.Scenes.Game.Enemies.enemy)
      node.setScale(0.25)
      node.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
      node.zPosition = 10

      let radius = max(node.size.width, node.size.height) * node.xScale / 2
      node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
      node.physicsBody?.affectedByGravity = false
      node.physicsBody?.isDynamic = true
      node.physicsBody?.categoryBitMask = PhysicsCategory.enemy
      node.physicsBody?.collisionBitMask = 0
      node.physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet

      return node
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

      let bullet = SKSpriteNode(asset: Asset.Items.Bullets.bulletYellow)
      bullet.name = NodeName.playerBullet
      bullet.setScale(0.125)
      bullet.zPosition = 20
      bullet.position = CGPoint(
        x: self.player.position.x,
        y: self.player.position.y + self.player.size.height * 0.5
      )

      let radius = max(bullet.size.width, bullet.size.height) * bullet.xScale / 2
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

      let bullet = SKSpriteNode(asset: Asset.Items.Bullets.bulletRed)
      bullet.name = NodeName.enemyBullet
      bullet.setScale(0.125)
      bullet.zPosition = 20
      bullet.position = CGPoint(
        x: self.enemy.position.x,
        y: self.enemy.position.y - self.enemy.size.height * 0.5
      )

      let radius = max(bullet.size.width, bullet.size.height) * bullet.xScale / 2
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

      let bodyA = contact.bodyA
      let bodyB = contact.bodyB

      // Player bullet vs enemy
      if
        (bodyA.categoryBitMask == PhysicsCategory.playerBullet && bodyB.categoryBitMask == PhysicsCategory.enemy) ||
        (bodyB.categoryBitMask == PhysicsCategory.playerBullet && bodyA.categoryBitMask == PhysicsCategory.enemy)
      {
        let bulletNode = (bodyA.categoryBitMask == PhysicsCategory.playerBullet ? bodyA.node : bodyB.node)
        let enemyNode = (bodyA.categoryBitMask == PhysicsCategory.enemy ? bodyA.node : bodyB.node)

        bulletNode?.removeFromParent()
        enemyNode?.removeFromParent()

        self.onPlayerKilledEnemy?()
        self.respawnEnemy()
        return
      }

      // Enemy bullet vs player
      if
        (bodyA.categoryBitMask == PhysicsCategory.enemyBullet && bodyB.categoryBitMask == PhysicsCategory.player) ||
        (bodyB.categoryBitMask == PhysicsCategory.enemyBullet && bodyA.categoryBitMask == PhysicsCategory.player)
      {
        let bulletNode = (bodyA.categoryBitMask == PhysicsCategory.enemyBullet ? bodyA.node : bodyB.node)
        bulletNode?.removeFromParent()

        self.endGame()
        self.onPlayerWasHit?()
        return
      }
    }

    // MARK: - Game State

    private func respawnEnemy() {
      self.enemy = self.createEnemyNode()
      addChild(self.enemy)
    }

    private func endGame() {
      self.isEnded = true
      removeAction(forKey: "playerFire")
      removeAction(forKey: "enemyFire")

      // Remove all bullets by name for efficiency
      enumerateChildNodes(withName: NodeName.playerBullet) { node, _ in
        node.removeFromParent()
      }
      enumerateChildNodes(withName: NodeName.enemyBullet) { node, _ in
        node.removeFromParent()
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
