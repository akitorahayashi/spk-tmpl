import AppFeatureCore
import ComposableArchitecture
import GameFeatureCore
import HomeFeatureCore
import TitleFeatureCore
import XCTest

@testable import TemplateApp

@MainActor
final class FeatureTests: XCTestCase {
  func testAppFeatureInitialState() {
    // Goal: Verify that the app feature starts with title state.
    let state = AppFeature.State()
    XCTAssertEqual(state, .title(TitleFeature.State()))
  }

  func testAppFeatureTitleToHomeTransition() async {
    // Goal: Verify title -> home transition via delegate action.
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.title(.startTapped))
    await store.receive(.title(.delegate(.startGame))) {
      $0 = .home(HomeFeature.State())
    }
  }

  func testAppFeatureGameScoreIncrement() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State())) {
      AppFeature()
    }

    await store.send(.game(.scoreIncremented(amount: 1))) {
      $0 = .game(GameFeature.State(score: 1))
    }
  }

  func testAppFeatureGamePlayerDied() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State(score: 5))) {
      AppFeature()
    }

    await store.send(.game(.playerDied)) {
      $0 = .game(GameFeature.State(score: 5, result: .lost))
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

    // Title -> Home
    await store.send(.title(.startTapped))
    await store.receive(.title(.delegate(.startGame))) {
      $0 = .home(HomeFeature.State())
    }

    // Home -> Game
    await store.send(.home(.startTapped))
    await store.receive(.home(.delegate(.startGame))) {
      $0 = .game(GameFeature.State(rule: .defaultRule))
    }

    // Score 10 points to win
    for i in 1 ..< 10 {
      await store.send(.game(.scoreIncremented(amount: 1))) {
        $0 = .game(GameFeature.State(rule: .defaultRule, score: i))
      }
    }

    // Final point triggers win
    await store.send(.game(.scoreIncremented(amount: 1))) {
      $0 = .game(GameFeature.State(rule: .defaultRule, score: 10, result: .won))
    }
    await store.receive(.game(.delegate(.gameEnded(.won))))

    // Continue to return to title
    await store.send(.game(.continueTapped))
    await store.receive(.game(.delegate(.returnToHome))) {
      $0 = .title(TitleFeature.State())
    }
  }

  func testFullLossFlowIntegration() async {
    // Goal: Verify the complete loss flow through the app feature.
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    // Title -> Home
    await store.send(.title(.startTapped))
    await store.receive(.title(.delegate(.startGame))) {
      $0 = .home(HomeFeature.State())
    }

    // Home -> Game
    await store.send(.home(.startTapped))
    await store.receive(.home(.delegate(.startGame))) {
      $0 = .game(GameFeature.State(rule: .defaultRule))
    }

    // Score some points
    await store.send(.game(.scoreIncremented(amount: 1))) {
      $0 = .game(GameFeature.State(rule: .defaultRule, score: 1))
    }

    // Die
    await store.send(.game(.playerDied)) {
      $0 = .game(GameFeature.State(rule: .defaultRule, score: 1, result: .lost))
    }
    await store.receive(.game(.delegate(.gameEnded(.lost))))

    // Continue to return to title
    await store.send(.game(.continueTapped))
    await store.receive(.game(.delegate(.returnToHome))) {
      $0 = .title(TitleFeature.State())
    }
  }
}
