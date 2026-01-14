import HomeFeatureUI
import TitleFeatureUI
import XCTest

@MainActor
final class TemplateAppUITests: XCTestCase {
  private var app: XCUIApplication!

  override func setUpWithError() throws {
    try super.setUpWithError()
    continueAfterFailure = false
    self.app = XCUIApplication()
    self.app.launch()
    XCTAssertTrue(self.app.wait(for: .runningForeground, timeout: 5))
  }

  override func tearDownWithError() throws {
    self.app = nil
    try super.tearDownWithError()
  }

  func testAppLaunchesToTitleScreen() throws {
    // Verify title screen elements are present
    let titleLabel = self.app.staticTexts[TitleAccessibilityID.gameTitle]
    XCTAssertTrue(titleLabel.waitForExistence(timeout: 3))

    let startLabel = self.app.staticTexts[TitleAccessibilityID.tapToStart]
    XCTAssertTrue(startLabel.exists)
  }

  func testTapToStartTransitionsToHome() throws {
    // Wait for title screen
    let startLabel = self.app.staticTexts[TitleAccessibilityID.tapToStart]
    XCTAssertTrue(startLabel.waitForExistence(timeout: 3))

    // Tap the "Tap to Start" label to transition to home
    startLabel.tap()

    // Verify home screen appears
    let homeTitleLabel = self.app.staticTexts[HomeAccessibilityID.title]
    XCTAssertTrue(homeTitleLabel.waitForExistence(timeout: 3))

    let homeStartLabel = self.app.staticTexts[HomeAccessibilityID.startMission]
    XCTAssertTrue(homeStartLabel.exists)
  }
}
