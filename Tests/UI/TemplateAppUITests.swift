import XCTest

@MainActor
final class TemplateAppUITests: XCTestCase {
  private var app: XCUIApplication!

  override func setUpWithError() throws {
    try super.setUpWithError()
    continueAfterFailure = false
    app = XCUIApplication()
    app.launch()
    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
  }

  override func tearDownWithError() throws {
    app = nil
    try super.tearDownWithError()
  }

  func testAppLaunchesToTitleScreen() throws {
    // Verify title screen elements are present
    let titleLabel = app.staticTexts["SPACE BATTLE"]
    XCTAssertTrue(titleLabel.waitForExistence(timeout: 3))

    let startLabel = app.staticTexts["Tap to Start"]
    XCTAssertTrue(startLabel.exists)
  }

  func testTapToStartTransitionsToHome() throws {
    // Wait for title screen
    let startLabel = app.staticTexts["Tap to Start"]
    XCTAssertTrue(startLabel.waitForExistence(timeout: 3))

    // Tap the "Tap to Start" label to transition to home
    startLabel.tap()

    // Verify home screen appears
    let homeTitleLabel = app.staticTexts["HOME"]
    XCTAssertTrue(homeTitleLabel.waitForExistence(timeout: 3))

    let homeStartLabel = app.staticTexts["Start Mission"]
    XCTAssertTrue(homeStartLabel.exists)
  }
}
