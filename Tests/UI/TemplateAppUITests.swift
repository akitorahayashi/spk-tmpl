import XCTest

@MainActor
final class TemplateAppUITests: XCTestCase {
  func testExample() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
  }
}
