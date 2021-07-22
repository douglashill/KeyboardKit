// Douglas Hill, July 2021

import UIKit

extension UIFocusEnvironment {

    /// Whether KeyboardKit should integrate with the UIKit focus system.
    /// If false, KeyboardKit will use it’s own navigation system using
    /// table and collection view cell selected states.
    ///
    /// This should only be used after the focus environment has been
    /// added to the focus hierarchy.
    ///
    /// While the UIKit focus system is available on macOS Big Sur,
    /// this property will always be false on Big Sur since using the
    /// focus system there would result in an extra testing case for
    /// an OS version that won’t have that many users.
    ///
    /// As of iOS 15.0, the focus system is not available on iPhone so this
    /// check takes care of keeping KeyboardKit’s navigation system there.
    var shouldKeyboardKitUseFocusSystem: Bool {
        if #available(iOS 15.0, *) {
            return UIFocusSystem.focusSystem(for: self) != nil
        } else {
            return false
        }
    }
}
