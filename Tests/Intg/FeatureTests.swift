import AppFeatureDomain
import ComposableArchitecture
import GameFeatureDomain
import XCTest

@testable import TemplateApp

@MainActor
final class FeatureTests: XCTestCase {
  func testAppFeatureGameStartGame() async {
    // Goal: Verify that the app feature correctly composes the game feature.
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.game(.startGame)) {
      $0.game.phase = .playing
    }
  }

  func testAppFeatureGamePlayerKilledEnemy() async {
    let store = TestStore(initialState: AppFeature.State(game: GameFeature.State(phase: .playing))) {
      AppFeature()
    }

    await store.send(.game(.playerKilledEnemy)) {
      $0.game.killCount = 1
    }
  }

  func testAppFeatureGamePlayerWasHit() async {
    let store = TestStore(initialState: AppFeature.State(game: GameFeature.State(phase: .playing, killCount: 5))) {
      AppFeature()
    }

    await store.send(.game(.playerWasHit)) {
      $0.game.phase = .ended(.lost)
    }
  }

  func testAppDependenciesConfiguration() async {
    // Goal: Verify that dependencies can be configured on the store.
    let dependencies = AppDependencies.live()
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      dependencies.configure(&$0)
    }

    await store.send(.onAppear)
  }

  func testFullWinFlowIntegration() async {
    // Goal: Verify the complete win flow through the app feature.
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    // Start game
    await store.send(.game(.startGame)) {
      $0.game.phase = .playing
    }

    // Kill 10 enemies to win
    for i in 1 ..< GameFeature.killsToWin {
      await store.send(.game(.playerKilledEnemy)) {
        $0.game.killCount = i
      }
    }

    // Final kill triggers win
    await store.send(.game(.playerKilledEnemy)) {
      $0.game.killCount = GameFeature.killsToWin
      $0.game.phase = .ended(.won)
    }

    // Return to home
    await store.send(.game(.returnToHome)) {
      $0.game.phase = .home
      $0.game.killCount = 0
    }
  }

  func testFullLossFlowIntegration() async {
    // Goal: Verify the complete loss flow through the app feature.
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    // Start game
    await store.send(.game(.startGame)) {
      $0.game.phase = .playing
    }

    // Kill some enemies
    await store.send(.game(.playerKilledEnemy)) {
      $0.game.killCount = 1
    }

    // Get hit
    await store.send(.game(.playerWasHit)) {
      $0.game.phase = .ended(.lost)
    }

    // Return to home
    await store.send(.game(.returnToHome)) {
      $0.game.phase = .home
      $0.game.killCount = 0
    }
  }
}
