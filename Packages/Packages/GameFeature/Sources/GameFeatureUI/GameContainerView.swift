#if canImport(UIKit)
  import GameFeatureDomain
  import SwiftUI

  /// The container view that hosts the SpriteKit game scene.
  ///
  /// This view creates and configures the GameScene, wiring up callbacks
  /// to send TCA actions for game events.
  public struct GameContainerView: View {
    let onPlayerKilledEnemy: () -> Void
    let onPlayerWasHit: () -> Void

    @State private var scene: GameScene?

    public init(
      onPlayerKilledEnemy: @escaping () -> Void,
      onPlayerWasHit: @escaping () -> Void
    ) {
      self.onPlayerKilledEnemy = onPlayerKilledEnemy
      self.onPlayerWasHit = onPlayerWasHit
    }

    public var body: some View {
      GeometryReader { geometry in
        if let scene {
          GameSceneView(scene: scene)
            .ignoresSafeArea()
        } else {
          Color.black
            .ignoresSafeArea()
            .onAppear {
              self.createScene(size: geometry.size)
            }
        }
      }
    }

    private func createScene(size: CGSize) {
      let newScene = GameScene.create(size: size)
      newScene.onPlayerKilledEnemy = self.onPlayerKilledEnemy
      newScene.onPlayerWasHit = self.onPlayerWasHit
      self.scene = newScene
    }
  }
#endif
