#if canImport(UIKit)
  import SpriteKit
  import SwiftUI
  import UIKit

  /// A SwiftUI view that hosts an SKView for rendering SpriteKit scenes.
  ///
  /// This wrapper provides lifecycle control over the SKView and manages scene presentation
  /// based on SwiftUI view updates.
  @MainActor
  public struct GameSceneView: UIViewRepresentable {
    public typealias UIViewType = SKView

    let scene: GameScene

    public init(scene: GameScene) {
      self.scene = scene
    }

    public func makeUIView(context _: Context) -> SKView {
      let skView = SKView()
      skView.ignoresSiblingOrder = true

      #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
      #endif

      return skView
    }

    public func updateUIView(_ skView: SKView, context _: Context) {
      if skView.scene !== self.scene {
        skView.presentScene(self.scene)
      }
    }
  }
#endif
