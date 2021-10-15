// Douglas Hill, September 2021

import UIKit

/// A key command provided by KeyboardKit that may either be exposed to the system using a `keyCommands`
/// override or using the menu builder.
///
/// A key command should be exposed to the system either using an override of the `UIResponder` property
/// `keyCommands` or with `UIMenuBuilder` using an override of `buildMenu(with:)`. However building the main
/// menu is an operation that the app or app delegate performs globally so KeyboardKit doesn’t know about this.
/// This subclass of `UIKeyCommand` provides a mechanism for your app to inform KeyboardKit if you include a
/// command from KeyboardKit in your main menu. KeyboardKit then knows to not include this command in any of
/// its overrides of the `keyCommands` responder property.
open class DiscoverableKeyCommand: UIKeyCommand {

    /// Whether KeyboardKit should include this command in overrides of the `keyCommands` property on responders.
    ///
    /// Set this to false if adding this key command to the main menu using `UIMenuBuilder`.
    ///
    /// Defaults to true.
    open var shouldBeIncludedInResponderChainKeyCommands: Bool {
        get {
            !shouldNotBeIncludedInResponderChainKeyCommands
        }
        set {
            shouldNotBeIncludedInResponderChainKeyCommands = !newValue
        }
    }

    /// There is some sort of problem where defaulting a property to true here does not work.
    /// I guess `UIKeyCommand` violates the designated initialiser pattern and this causes Swift’s default values to not be applied.
    /// Therefore invert the backing storage.
    private var shouldNotBeIncludedInResponderChainKeyCommands = false
}
