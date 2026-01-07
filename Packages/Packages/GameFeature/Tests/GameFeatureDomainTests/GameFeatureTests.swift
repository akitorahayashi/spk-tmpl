import ComposableArchitecture
import XCTest

@testable import GameFeatureDomain

@MainActor
final class GameFeatureTests: XCTestCase {
  // MARK: - Initial State

  func testInitialState() {
    let state = GameFeature.State()
    XCTAssertEqual(state.phase, .home)
    XCTAssertEqual(state.killCount, 0)
  }

  // MARK: - Start Game

  func testStartGame() async {
    let store = TestStore(initialState: GameFeature.State()) {
      GameFeature()
    }

    await store.send(.startGame) {
      $0.phase = .playing
      $0.killCount = 0
    }
  }

  func testStartGameIgnoredWhenPlaying() async {
    let store = TestStore(initialState: GameFeature.State(phase: .playing, killCount: 5)) {
      GameFeature()
    }

    await store.send(.startGame)
    // No state change expected
  }

  func testStartGameIgnoredWhenEnded() async {
    let store = TestStore(initialState: GameFeature.State(phase: .ended(.won))) {
      GameFeature()
    }

    await store.send(.startGame)
    // No state change expected
  }

  // MARK: - Player Killed Enemy

  func testPlayerKilledEnemy() async {
    let store = TestStore(initialState: GameFeature.State(phase: .playing, killCount: 0)) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy) {
      $0.killCount = 1
    }
  }

  func testPlayerKilledEnemyMultipleTimes() async {
    let store = TestStore(initialState: GameFeature.State(phase: .playing, killCount: 5)) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy) {
      $0.killCount = 6
    }
    await store.send(.playerKilledEnemy) {
      $0.killCount = 7
    }
  }

  func testPlayerKilledEnemyIgnoredWhenHome() async {
    let store = TestStore(initialState: GameFeature.State(phase: .home)) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy)
    // No state change expected
  }

  func testPlayerKilledEnemyIgnoredWhenEnded() async {
    let store = TestStore(initialState: GameFeature.State(phase: .ended(.lost))) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy)
    // No state change expected
  }

  // MARK: - Win Condition

  func testWinConditionAtExactKills() async {
    let store = TestStore(
      initialState: GameFeature.State(phase: .playing, killCount: GameFeature.killsToWin - 1)
    ) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy) {
      $0.killCount = GameFeature.killsToWin
      $0.phase = .ended(.won)
    }
  }

  func testWinConditionBeyondKills() async {
    // Edge case: if somehow kill count is already at threshold
    let store = TestStore(
      initialState: GameFeature.State(phase: .playing, killCount: GameFeature.killsToWin)
    ) {
      GameFeature()
    }

    await store.send(.playerKilledEnemy) {
      $0.killCount = GameFeature.killsToWin + 1
      $0.phase = .ended(.won)
    }
  }

  // MARK: - Player Was Hit

  func testPlayerWasHit() async {
    let store = TestStore(initialState: GameFeature.State(phase: .playing, killCount: 5)) {
      GameFeature()
    }

    await store.send(.playerWasHit) {
      $0.phase = .ended(.lost)
    }
  }

  func testPlayerWasHitIgnoredWhenHome() async {
    let store = TestStore(initialState: GameFeature.State(phase: .home)) {
      GameFeature()
    }

    await store.send(.playerWasHit)
    // No state change expected
  }

  func testPlayerWasHitIgnoredWhenEnded() async {
    let store = TestStore(initialState: GameFeature.State(phase: .ended(.won))) {
      GameFeature()
    }

    await store.send(.playerWasHit)
    // No state change expected
  }

  // MARK: - Return to Home

  func testReturnToHomeFromWon() async {
    let store = TestStore(initialState: GameFeature.State(phase: .ended(.won), killCount: 10)) {
      GameFeature()
    }

    await store.send(.returnToHome) {
      $0.phase = .home
      $0.killCount = 0
    }
  }

  func testReturnToHomeFromLost() async {
    let store = TestStore(initialState: GameFeature.State(phase: .ended(.lost), killCount: 3)) {
      GameFeature()
    }

    await store.send(.returnToHome) {
      $0.phase = .home
      $0.killCount = 0
    }
  }

  func testReturnToHomeIgnoredWhenHome() async {
    let store = TestStore(initialState: GameFeature.State(phase: .home)) {
      GameFeature()
    }

    await store.send(.returnToHome)
    // No state change expected
  }

  func testReturnToHomeIgnoredWhenPlaying() async {
    let store = TestStore(initialState: GameFeature.State(phase: .playing, killCount: 5)) {
      GameFeature()
    }

    await store.send(.returnToHome)
    // No state change expected
  }

  // MARK: - Full Game Flow

  func testFullWinFlow() async {
    let store = TestStore(initialState: GameFeature.State()) {
      GameFeature()
    }

    // Start game
    await store.send(.startGame) {
      $0.phase = .playing
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
      $0.phase = .ended(.won)
    }

    // Return to home
    await store.send(.returnToHome) {
      $0.phase = .home
      $0.killCount = 0
    }
  }

  func testFullLossFlow() async {
    let store = TestStore(initialState: GameFeature.State()) {
      GameFeature()
    }

    // Start game
    await store.send(.startGame) {
      $0.phase = .playing
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
      $0.phase = .ended(.lost)
    }

    // Return to home
    await store.send(.returnToHome) {
      $0.phase = .home
      $0.killCount = 0
    }
  }
}
