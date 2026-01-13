import ComposableArchitecture
import GameFeatureCore
import HomeFeatureCore
import TitleFeatureCore
import XCTest

@testable import AppFeatureCore

@MainActor
final class AppFeatureTests: XCTestCase {
  func testInitialState() {
    let state = AppFeature.State()
    XCTAssertEqual(state, .title(TitleFeature.State()))
  }

  func testTitleToHomeTransition() async {
    let store = TestStore(initialState: AppFeature.State.title(TitleFeature.State())) {
      AppFeature()
    }

    await store.send(.title(.startTapped))
    await store.receive(.title(.delegate(.startGame))) {
      $0 = .home(HomeFeature.State())
    }
  }

  func testHomeToGameTransition() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.title(.startTapped))
    await store.receive(.title(.delegate(.startGame))) {
      $0 = .home(HomeFeature.State())
    }

    await store.send(.home(.startTapped))
    await store.receive(.home(.delegate(.startGame))) {
      $0 = .game(GameFeature.State(rule: .defaultRule))
    }
  }

  func testGameToHomeTransition() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State(result: .won))) {
      AppFeature()
    }

    await store.send(.game(.continueTapped))
    await store.receive(.game(.delegate(.returnToHome))) {
      $0 = .home(HomeFeature.State())
    }
  }

  func testOnAppear() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.onAppear)
  }

  func testGameScoreIncremented() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State())) {
      AppFeature()
    }

    await store.send(.game(.scoreIncremented(amount: 1))) {
      $0 = .game(GameFeature.State(score: 1))
    }
  }

  func testGamePlayerDied() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State(score: 5))) {
      AppFeature()
    }

    await store.send(.game(.playerDied)) {
      $0 = .game(GameFeature.State(score: 5, result: .lost))
    }
    await store.receive(.game(.delegate(.gameEnded(.lost))))
  }

  func testGameWinCondition() async {
    let store = TestStore(
      initialState: AppFeature.State.game(GameFeature.State(rule: .defaultRule, score: 9))
    ) {
      AppFeature()
    }

    await store.send(.game(.scoreIncremented(amount: 1))) {
      $0 = .game(GameFeature.State(rule: .defaultRule, score: 10, result: .won))
    }
    await store.receive(.game(.delegate(.gameEnded(.won))))
  }
}
