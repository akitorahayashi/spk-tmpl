import XCTest

@MainActor
final class TemplateAppUITests: XCTestCase {
  func testAppLaunchesToHomeScreen() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

    // Verify home screen elements are present
    let titleLabel = app.staticTexts["SHOT GAME"]
    XCTAssertTrue(titleLabel.waitForExistence(timeout: 3))

    let startLabel = app.staticTexts["Tap to Start"]
    XCTAssertTrue(startLabel.exists)
  }

  func testTapToStartTransitionsToGame() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))

    // Wait for home screen
    let startLabel = app.staticTexts["Tap to Start"]
    XCTAssertTrue(startLabel.waitForExistence(timeout: 3))

    // Tap to start game
    app.tap()

    // Verify home screen text disappears (game is now active)
    XCTAssertTrue(startLabel.waitForNonExistence(timeout: 3))
  }
}
