// Douglas Hill, February 2018

import Foundation

#if SWIFT_PACKAGE
private let keyboardKitBundle = Bundle.module
#else
private class BundleFinder {}
private let keyboardKitBundle = Bundle(for: BundleFinder.self)
#endif

/// Looks up a string in KeyboardKit.strings files. The cases of the parameter type are generated from the English strings file.
func localisedString(_ key: LocalisedStringKey) -> String {
    return keyboardKitBundle.localizedString(forKey: key.rawValue, value: nil, table: "KeyboardKit")
}
