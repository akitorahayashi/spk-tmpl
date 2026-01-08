import ComposableArchitecture
import XCTest

@testable import GameFeatureCore

@MainActor
final class GameFeatureTests: XCTestCase {
  // MARK: - Initial State

  func testInitialState() {
    let state = GameFeature.State()
    XCTAssertEqual(state.score, 0)
    XCTAssertEqual(state.timeElapsed, 0)
    XCTAssertNil(state.result)
    XCTAssertTrue(state.isPlaying)
  }

  // MARK: - Score Incremented

  func testScoreIncremented() async {
    let store = TestStore(initialState: GameFeature.State()) {
      GameFeature()
    }

    await store.send(.scoreIncremented(amount: 1)) {
      $0.score = 1
    }
  }

  func testScoreIncrementedMultipleTimes() async {
    let store = TestStore(initialState: GameFeature.State(score: 5)) {
      GameFeature()
    }

    await store.send(.scoreIncremented(amount: 2)) {
      $0.score = 7
    }
    await store.send(.scoreIncremented(amount: 3)) {
      $0.score = 10
      $0.result = .won
    }
    await store.receive(.delegate(.gameEnded(.won)))
  }

  func testScoreIncrementedIgnoredWhenEnded() async {
    let store = TestStore(initialState: GameFeature.State(result: .lost)) {
      GameFeature()
    }

    await store.send(.scoreIncremented(amount: 5))
    // No state change expected
  }

  // MARK: - Win Condition - Score Target

  func testScoreTargetWinAtExactScore() async {
    let rule = GameRule(winCondition: .scoreTarget(10))
    let store = TestStore(initialState: GameFeature.State(rule: rule, score: 9)) {
      GameFeature()
    }

    await store.send(.scoreIncremented(amount: 1)) {
      $0.score = 10
      $0.result = .won
    }
    await store.receive(.delegate(.gameEnded(.won)))
  }

  func testScoreTargetWinBeyondTarget() async {
    let rule = GameRule(winCondition: .scoreTarget(10))
    let store = TestStore(initialState: GameFeature.State(rule: rule, score: 9)) {
      GameFeature()
    }

    await store.send(.scoreIncremented(amount: 5)) {
      $0.score = 14
      $0.result = .won
    }
    await store.receive(.delegate(.gameEnded(.won)))
  }

  // MARK: - Win Condition - Survival Mode

  func testSurvivalWin() async {
    let clock = TestClock()
    let rule = GameRule(winCondition: .survival(duration: 10))
    let store = TestStore(initialState: GameFeature.State(rule: rule)) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    // Start the timer task
    let task = await store.send(.task)

    // Advance to 9 seconds - not enough yet
    await clock.advance(by: .seconds(9))
    for _ in 1 ... 9 {
      await store.receive(\.timerTick) {
        $0.timeElapsed += 1
      }
    }

    // 10th second - win!
    await clock.advance(by: .seconds(1))
    await store.receive(\.timerTick) {
      $0.timeElapsed = 10
      $0.result = .won
    }
    await store.receive(.delegate(.gameEnded(.won)))

    await task.cancel()
  }

  func testSurvivalDoesNotWinByScore() async {
    let clock = TestClock()
    let rule = GameRule(winCondition: .survival(duration: 10))
    let store = TestStore(initialState: GameFeature.State(rule: rule)) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    // Score increases - should not trigger win
    await store.send(.scoreIncremented(amount: 100)) {
      $0.score = 100
    }

    // Still playing
    XCTAssertNil(store.state.result)
  }

  // MARK: - Win Condition - None (Endless Mode)

  func testNoneWinCondition() async {
    let clock = TestClock()
    let rule = GameRule(winCondition: .none)
    let store = TestStore(initialState: GameFeature.State(rule: rule)) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    // Score increases don't trigger win
    await store.send(.scoreIncremented(amount: 1000)) {
      $0.score = 1000
    }

    // Time passes doesn't trigger win
    let task = await store.send(.task)
    await clock.advance(by: .seconds(100))
    for _ in 1 ... 100 {
      await store.receive(\.timerTick) {
        $0.timeElapsed += 1
      }
    }

    // Still playing
    XCTAssertNil(store.state.result)

    await task.cancel()
  }

  // MARK: - Time Limit

  func testTimeLimitLoss() async {
    let clock = TestClock()
    let rule = GameRule(winCondition: .scoreTarget(100), timeLimit: 30)
    let store = TestStore(initialState: GameFeature.State(rule: rule)) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    // Start the timer task
    let task = await store.send(.task)

    // Score a bit
    await store.send(.scoreIncremented(amount: 10)) {
      $0.score = 10
    }

    // Advance to time limit without reaching score target
    await clock.advance(by: .seconds(30))
    for _ in 1 ... 30 {
      await store.receive(\.timerTick) {
        $0.timeElapsed += 1
        if $0.timeElapsed == 30 {
          $0.result = .lost
        }
      }
    }
    await store.receive(.delegate(.gameEnded(.lost)))

    await task.cancel()
  }

  func testTimeLimitExactlyAtLimit() async {
    let clock = TestClock()
    let rule = GameRule(winCondition: .scoreTarget(10), timeLimit: 5)
    let store = TestStore(initialState: GameFeature.State(rule: rule)) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    let task = await store.send(.task)

    // Advance exactly to the limit
    await clock.advance(by: .seconds(5))
    for i in 1 ... 5 {
      await store.receive(\.timerTick) {
        $0.timeElapsed = TimeInterval(i)
        if i == 5 {
          $0.result = .lost
        }
      }
    }
    await store.receive(.delegate(.gameEnded(.lost)))

    await task.cancel()
  }

  // MARK: - Player Died

  func testPlayerDied() async {
    let store = TestStore(initialState: GameFeature.State(score: 5)) {
      GameFeature()
    }

    await store.send(.playerDied) {
      $0.result = .lost
    }
    await store.receive(.delegate(.gameEnded(.lost)))
  }

  func testPlayerDiedIgnoredWhenEnded() async {
    let store = TestStore(initialState: GameFeature.State(result: .won)) {
      GameFeature()
    }

    await store.send(.playerDied)
    // No state change expected
  }

  // MARK: - Continue Tapped

  func testContinueTappedFromWon() async {
    let store = TestStore(initialState: GameFeature.State(score: 10, result: .won)) {
      GameFeature()
    }

    await store.send(.continueTapped)
    await store.receive(.delegate(.returnToHome))
  }

  func testContinueTappedFromLost() async {
    let store = TestStore(initialState: GameFeature.State(score: 3, result: .lost)) {
      GameFeature()
    }

    await store.send(.continueTapped)
    await store.receive(.delegate(.returnToHome))
  }

  func testContinueTappedIgnoredWhenPlaying() async {
    let store = TestStore(initialState: GameFeature.State(score: 5)) {
      GameFeature()
    }

    await store.send(.continueTapped)
    // No state change expected
  }

  // MARK: - Full Game Flow

  func testFullScoreWinFlow() async {
    let rule = GameRule(winCondition: .scoreTarget(10))
    let store = TestStore(initialState: GameFeature.State(rule: rule)) {
      GameFeature()
    }

    // Score points until win
    for i in 1 ..< 10 {
      await store.send(.scoreIncremented(amount: 1)) {
        $0.score = i
      }
    }

    // Final point triggers win
    await store.send(.scoreIncremented(amount: 1)) {
      $0.score = 10
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

    // Score some points
    await store.send(.scoreIncremented(amount: 1)) {
      $0.score = 1
    }
    await store.send(.scoreIncremented(amount: 2)) {
      $0.score = 3
    }

    // Die
    await store.send(.playerDied) {
      $0.result = .lost
    }
    await store.receive(.delegate(.gameEnded(.lost)))

    // Continue tapped
    await store.send(.continueTapped)
    await store.receive(.delegate(.returnToHome))
  }

  // MARK: - Timer Tick

  func testTimerTickIgnoredWhenEnded() async {
    let clock = TestClock()
    let store = TestStore(initialState: GameFeature.State(result: .won)) {
      GameFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    let task = await store.send(.task)
    await clock.advance(by: .seconds(1))
    // Timer tick still fires, but it should be ignored by the reducer
    await store.receive(\.timerTick)
    // No state changes expected since game has ended
    await task.cancel()
  }
}
