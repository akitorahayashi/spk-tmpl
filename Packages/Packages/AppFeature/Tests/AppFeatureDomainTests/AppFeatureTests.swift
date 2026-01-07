import ComposableArchitecture
import GameFeatureDomain
import XCTest

@testable import AppFeatureDomain

@MainActor
final class AppFeatureTests: XCTestCase {
  func testInitialState() {
    let state = AppFeature.State()
    XCTAssertEqual(state.game.phase, .home)
    XCTAssertEqual(state.game.killCount, 0)
  }

  func testGameStartGame() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.game(.startGame)) {
      $0.game.phase = .playing
    }
  }

  func testGamePlayerKilledEnemy() async {
    let store = TestStore(initialState: AppFeature.State(game: GameFeature.State(phase: .playing))) {
      AppFeature()
    }

    await store.send(.game(.playerKilledEnemy)) {
      $0.game.killCount = 1
    }
  }

  func testOnAppear() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }

    await store.send(.onAppear)
  }

  func testGamePlayerWasHit() async {
    let store = TestStore(initialState: AppFeature.State(game: GameFeature.State(phase: .playing, killCount: 5))) {
      AppFeature()
    }

    await store.send(.game(.playerWasHit)) {
      $0.game.phase = .ended(.lost)
    }
  }

  func testGameReturnToHome() async {
    let store = TestStore(initialState: AppFeature.State(game: GameFeature.State(phase: .ended(.won), killCount: 10))) {
      AppFeature()
    }

    await store.send(.game(.returnToHome)) {
      $0.game.phase = .home
      $0.game.killCount = 0
    }
  }
}
