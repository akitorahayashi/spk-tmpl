import AppFeatureCore
import ComposableArchitecture
import GameFeatureCore
import HomeFeatureCore
import XCTest

@testable import TemplateApp

@MainActor
final class FeatureTests: XCTestCase {
  func testAppFeatureInitialState() {
    // Goal: Verify that the app feature starts with home state.
    let state = AppFeature.State()
    XCTAssertEqual(state, .home(HomeFeature.State()))
  }

  func testAppFeatureHomeToGameTransition() async {
    // Goal: Verify home -> game transition via delegate action.
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.home(.startTapped))
    await store.receive(.home(.delegate(.startGame))) {
      $0 = .game(GameFeature.State())
    }
  }

  func testAppFeatureGamePlayerKilledEnemy() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State())) {
      AppFeature()
    }

    await store.send(.game(.playerKilledEnemy)) {
      $0 = .game(GameFeature.State(killCount: 1))
    }
  }

  func testAppFeatureGamePlayerWasHit() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State(killCount: 5))) {
      AppFeature()
    }

    await store.send(.game(.playerWasHit)) {
      $0 = .game(GameFeature.State(killCount: 5, result: .lost))
    }
    await store.receive(.game(.delegate(.gameEnded(.lost))))
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

    // Start game from home
    await store.send(.home(.startTapped))
    await store.receive(.home(.delegate(.startGame))) {
      $0 = .game(GameFeature.State())
    }

    // Kill 10 enemies to win
    for i in 1 ..< GameFeature.killsToWin {
      await store.send(.game(.playerKilledEnemy)) {
        $0 = .game(GameFeature.State(killCount: i))
      }
    }

    // Final kill triggers win
    await store.send(.game(.playerKilledEnemy)) {
      $0 = .game(GameFeature.State(killCount: GameFeature.killsToWin, result: .won))
    }
    await store.receive(.game(.delegate(.gameEnded(.won))))

    // Continue to return to home
    await store.send(.game(.continueTapped))
    await store.receive(.game(.delegate(.returnToHome))) {
      $0 = .home(HomeFeature.State())
    }
  }

  func testFullLossFlowIntegration() async {
    // Goal: Verify the complete loss flow through the app feature.
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    // Start game from home
    await store.send(.home(.startTapped))
    await store.receive(.home(.delegate(.startGame))) {
      $0 = .game(GameFeature.State())
    }

    // Kill some enemies
    await store.send(.game(.playerKilledEnemy)) {
      $0 = .game(GameFeature.State(killCount: 1))
    }

    // Get hit
    await store.send(.game(.playerWasHit)) {
      $0 = .game(GameFeature.State(killCount: 1, result: .lost))
    }
    await store.receive(.game(.delegate(.gameEnded(.lost))))

    // Continue to return to home
    await store.send(.game(.continueTapped))
    await store.receive(.game(.delegate(.returnToHome))) {
      $0 = .home(HomeFeature.State())
    }
  }
}
