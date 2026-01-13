import ComposableArchitecture
import XCTest

@testable import TitleFeatureCore

@MainActor
final class TitleFeatureTests: XCTestCase {
  func testOnAppearStartsPulse() async {
    let store = TestStore(initialState: TitleFeature.State()) {
      TitleFeature()
    }

    await store.send(.onAppear) {
      $0.pulseOpacity = 0.3
    }
  }

  func testStartTapDelegates() async {
    let store = TestStore(initialState: TitleFeature.State()) {
      TitleFeature()
    }

    await store.send(.startTapped)
    await store.receive(.delegate(.startGame))
  }
}
