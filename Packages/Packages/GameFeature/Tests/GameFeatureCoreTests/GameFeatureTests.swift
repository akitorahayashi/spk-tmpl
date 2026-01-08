import ComposableArchitecture
import XCTest

@testable import GameFeatureCore

@MainActor
final class GameFeatureTests: XCTestCase {
  // MARK: - Initial State

  func testInitialState() {
    let state = GameFeature.State()
    XCTAssertEqual(state.killCount, 0)
    XCTAssertNil(state.result)
    XCTAssertTrue(state.isPlaying)
  }

  // MARK: - Player Killed Enemy

  func testPlayerKilledEnemy() async {
    let store = TestStore(initialState: GameFeature.State()) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy) {
      $0.killCount = 1
    }
  }

  func testPlayerKilledEnemyMultipleTimes() async {
    let store = TestStore(initialState: GameFeature.State(killCount: 5)) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy) {
      $0.killCount = 6
    }
    await store.send(.playerKilledEnemy) {
      $0.killCount = 7
    }
  }

  func testPlayerKilledEnemyIgnoredWhenEnded() async {
    let store = TestStore(initialState: GameFeature.State(result: .lost)) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy)
    // No state change expected
  }

  // MARK: - Win Condition

  func testWinConditionAtExactKills() async {
    let store = TestStore(
      initialState: GameFeature.State(killCount: GameFeature.killsToWin - 1)
    ) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy) {
      $0.killCount = GameFeature.killsToWin
      $0.result = .won
    }
    await store.receive(.delegate(.gameEnded(.won)))
  }

  func testWinConditionBeyondKills() async {
    // Edge case: if somehow kill count is already at threshold
    let store = TestStore(
      initialState: GameFeature.State(killCount: GameFeature.killsToWin)
    ) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy) {
      $0.killCount = GameFeature.killsToWin + 1
      $0.result = .won
    }
    await store.receive(.delegate(.gameEnded(.won)))
  }

  // MARK: - Player Was Hit

  func testPlayerWasHit() async {
    let store = TestStore(initialState: GameFeature.State(killCount: 5)) {
      GameFeature()
    }

    await store.send(.playerWasHit) {
      $0.result = .lost
    }
    await store.receive(.delegate(.gameEnded(.lost)))
  }

  func testPlayerWasHitIgnoredWhenEnded() async {
    let store = TestStore(initialState: GameFeature.State(result: .won)) {
      GameFeature()
    }

    await store.send(.playerWasHit)
    // No state change expected
  }

  // MARK: - Continue Tapped

  func testContinueTappedFromWon() async {
    let store = TestStore(initialState: GameFeature.State(killCount: 10, result: .won)) {
      GameFeature()
    }

    await store.send(.continueTapped)
    await store.receive(.delegate(.returnToHome))
  }

  func testContinueTappedFromLost() async {
    let store = TestStore(initialState: GameFeature.State(killCount: 3, result: .lost)) {
      GameFeature()
    }

    await store.send(.continueTapped)
    await store.receive(.delegate(.returnToHome))
  }

  func testContinueTappedIgnoredWhenPlaying() async {
    let store = TestStore(initialState: GameFeature.State(killCount: 5)) {
      GameFeature()
    }

    await store.send(.continueTapped)
    // No state change expected
  }

  // MARK: - Full Game Flow

  func testFullWinFlow() async {
    let store = TestStore(initialState: GameFeature.State()) {
      GameFeature()
    }

    // Kill enemies until win
    for i in 1 ..< GameFeature.killsToWin {
      await store.send(.playerKilledEnemy) {
        $0.killCount = i
      }
    }

    // Final kill triggers win
    await store.send(.playerKilledEnemy) {
      $0.killCount = GameFeature.killsToWin
      $0.result = .won
    }
    await store.receive(.delegate(.gameEnded(.won)))

    // Continue tapped
    await store.send(.continueTapped)
    await store.receive(.delegate(.returnToHome))
  }

  func testFullLossFlow() async {
    let store = TestStore(initialState: GameFeature.State()) {
      GameFeature()
    }

    // Kill some enemies
    await store.send(.playerKilledEnemy) {
      $0.killCount = 1
    }
    await store.send(.playerKilledEnemy) {
      $0.killCount = 2
    }

    // Get hit
    await store.send(.playerWasHit) {
      $0.result = .lost
    }
    await store.receive(.delegate(.gameEnded(.lost)))

    // Continue tapped
    await store.send(.continueTapped)
    await store.receive(.delegate(.returnToHome))
  }
}
