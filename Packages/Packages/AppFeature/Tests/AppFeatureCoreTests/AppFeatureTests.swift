import ComposableArchitecture
import GameFeatureCore
import HomeFeatureCore
import XCTest

@testable import AppFeatureCore

@MainActor
final class AppFeatureTests: XCTestCase {
  func testInitialState() {
    let state = AppFeature.State()
    XCTAssertEqual(state, .home(HomeFeature.State()))
  }

  func testHomeToGameTransition() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.home(.startTapped))
    await store.receive(.home(.delegate(.startGame))) {
      $0 = .game(GameFeature.State())
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

  func testGamePlayerKilledEnemy() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State())) {
      AppFeature()
    }

    await store.send(.game(.playerKilledEnemy)) {
      $0 = .game(GameFeature.State(killCount: 1))
    }
  }

  func testGamePlayerWasHit() async {
    let store = TestStore(initialState: AppFeature.State.game(GameFeature.State(killCount: 5))) {
      AppFeature()
    }

    await store.send(.game(.playerWasHit)) {
      $0 = .game(GameFeature.State(killCount: 5, result: .lost))
    }
    await store.receive(.game(.delegate(.gameEnded(.lost))))
  }

  func testGameWinCondition() async {
    let store = TestStore(
      initialState: AppFeature.State.game(GameFeature.State(killCount: GameFeature.killsToWin - 1))
    ) {
      AppFeature()
    }

    await store.send(.game(.playerKilledEnemy)) {
      $0 = .game(GameFeature.State(killCount: GameFeature.killsToWin, result: .won))
    }
    await store.receive(.game(.delegate(.gameEnded(.won))))
  }
}
