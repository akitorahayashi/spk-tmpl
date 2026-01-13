import XCTest

@MainActor
final class TemplateAppUITests: XCTestCase {
  func testAppLaunchesToTitleScreen() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

    // Verify title screen elements are present
    let titleLabel = app.staticTexts["SPACE BATTLE"]
    XCTAssertTrue(titleLabel.waitForExistence(timeout: 3))

    let startLabel = app.staticTexts["Tap to Start"]
    XCTAssertTrue(startLabel.exists)
  }

  func testTapToStartTransitionsToHome() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

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
