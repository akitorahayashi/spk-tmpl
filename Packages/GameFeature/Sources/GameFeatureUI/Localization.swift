#if SWIFT_PACKAGE
  import SwiftUI

  extension LocalizedStringResource {
    static let victoryTitle = LocalizedStringResource("victoryTitle", bundle: .module)
    static let gameOverTitle = LocalizedStringResource("gameOverTitle", bundle: .module)
    static let tapToContinue = LocalizedStringResource("tapToContinue", bundle: .module)
  }
#endif
