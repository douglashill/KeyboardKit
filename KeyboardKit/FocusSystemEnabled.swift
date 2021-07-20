// Douglas Hill, July 2021

import UIKit

extension UIView {

    /// Whether KeyboardKit should integrate with the UIKit focus system.
    /// If false, KeyboardKit will use it’s own navigation system using
    /// table and collection view cell selected states.
    ///
    /// As of iOS 15.0, the focus system is not available on iPhone so this
    /// check takes care of keeping KeyboardKit’s navigation system there.
    ///
    /// This could potentially also be used as a feature flag to stop using
    /// the UIKit focus system if necessary, but this may need tweaks.
    var shouldKeyboardKitUseFocusSystem: Bool {
        if #available(iOS 15.0, *) {
            // Force unwrap because this will give wrong results if called during setup.
            return window!.windowScene!.focusSystem != nil
        } else {
            return false
        }
    }
}
