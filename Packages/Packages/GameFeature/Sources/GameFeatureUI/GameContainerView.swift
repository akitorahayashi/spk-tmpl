#if canImport(UIKit)
  import ComposableArchitecture
  import GameFeatureCore
  import SwiftUI

  /// The container view that hosts the SpriteKit game scene.
  ///
  /// This view creates and configures the GameScene, wiring up callbacks
  /// to send TCA actions for game events.
  public struct GameContainerView: View {
    let store: StoreOf<GameFeature>

    @State private var scene: GameScene?

    public init(store: StoreOf<GameFeature>) {
      self.store = store
    }

    public var body: some View {
      GeometryReader { geometry in
        GameSceneView(scene: self.scene ?? GameScene.create(size: geometry.size))
          .ignoresSafeArea()
          .onAppear {
            if self.scene == nil {
              self.createScene(size: geometry.size)
            }
          }
          .onChange(of: geometry.size) { _, newSize in
            self.scene?.size = newSize
          }
      }
    }

    private func createScene(size: CGSize) {
      let newScene = GameScene.create(size: size)
      newScene.onPlayerKilledEnemy = {
        self.store.send(.playerKilledEnemy)
      }
      newScene.onPlayerWasHit = {
        self.store.send(.playerWasHit)
      }
      self.scene = newScene
    }
  }

  #if DEBUG
    #Preview {
      GameContainerView(
        store: Store(initialState: GameFeature.State()) {
          GameFeature()
        }
      )
    }
  #endif
#endif
