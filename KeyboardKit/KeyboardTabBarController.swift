// Douglas Hill, May 2019

import UIKit

/// A tab bar controller that supports navigating between tabs using ⌘ + number on a hardware keyboard.
/// So ⌘ + 1 for the first tab, ⌘ + 2 for the second tab etc.
///
/// Setting more view controllers than the number displayable by a tab bar such that the More item is added is not supported.
/// This is partly because the view controller hierarchy modifications done by the More tab are hard to support well, and partly
/// because the More list and navigation controller don’t support keyboard input so would result in an inconsistent user experience.
open class KeyboardTabBarController: UITabBarController {

    open override var canBecomeFirstResponder: Bool {
        true
    }

    #if !targetEnvironment(macCatalyst)
    /// Key commands that enable users to change the selected tab.
    ///
    /// Title: The title of the `UITabBarItem`
    ///
    /// Input: ⌘1 to ⌘9
    ///
    /// Recommended location in main menu: View
    ///
    /// The titles are provided in an override of `validateCommand:`. As such, these key commands aren’t available for
    /// inclusion in the main menu on Mac Catalyst because they may show disabled with blank or stale titles if no
    /// object remains to provide the validation. This isn’t a problem on iPad because disabled key commands aren’t shown.
    ///
    /// These specific objects are only for use with `UIMenuBuilder`. On Mac Catalyst and if `shouldBeIncludedInResponderChainKeyCommands`
    /// is true (the default) then KeyboardKit’s override of `keyCommands` will provide different objects that don’t need validating.
    public static let changeSelectedTabKeyCommands: [DiscoverableKeyCommand] = (1...9).map { number in
        DiscoverableKeyCommand((.command, String(number)), action: NSSelectorFromString("kbd_selectTabByNumberFromKeyCommand\(String(number)):"))
    }
    #endif

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

#if targetEnvironment(macCatalyst)
        let shouldIncludeChangeSelectedTabKeyCommands = true
#else
        let shouldIncludeChangeSelectedTabKeyCommands = Self.changeSelectedTabKeyCommands[0].shouldBeIncludedInResponderChainKeyCommands
#endif

        if shouldIncludeChangeSelectedTabKeyCommands, presentedViewController == nil, let items = tabBar.items {
            precondition(items.count == viewControllers?.count, "More tab is not supported.")

            commands += items.prefix(9).enumerated().map { index, tabBarItem in
                UIKeyCommand((.command, String(index + 1)), action: #selector(selectTabByNumberFromKeyCommand), title: tabBarItem.title)
            }
        }

        return commands
    }

    open override func validate(_ command: UICommand) {
        guard NSStringFromSelector(command.action).hasPrefix("kbd_selectTabByNumberFromKeyCommand") else {
            return
        }

        // The command we are passed here is an instance of _UIValidatableCommand, which is a subclass of UICommand,
        // not UIKeyCommand. This means we need to identify the target tab from the selector rather than the input.

        let number = (NSStringFromSelector(command.action) as NSString).substring(with: NSRange(location: ("kbd_selectTabByNumberFromKeyCommand" as NSString).length, length: 1))
        let targetIndex = Int(number)! - 1

        guard let items = tabBar.items, targetIndex >= 0, targetIndex < items.count else {
            command.attributes.insert(.disabled)
            return
        }

        command.attributes.remove(.disabled)
        command.title = items[targetIndex].title ?? ""
    }

    // Selectors must be unique in UIMenuBuilder, hence this awkward indirection.
    @objc private func kbd_selectTabByNumberFromKeyCommand1(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }
    @objc private func kbd_selectTabByNumberFromKeyCommand2(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }
    @objc private func kbd_selectTabByNumberFromKeyCommand3(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }
    @objc private func kbd_selectTabByNumberFromKeyCommand4(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }
    @objc private func kbd_selectTabByNumberFromKeyCommand5(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }
    @objc private func kbd_selectTabByNumberFromKeyCommand6(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }
    @objc private func kbd_selectTabByNumberFromKeyCommand7(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }
    @objc private func kbd_selectTabByNumberFromKeyCommand8(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }
    @objc private func kbd_selectTabByNumberFromKeyCommand9(_ sender: UIKeyCommand) { self.selectTabByNumberFromKeyCommand(sender) }

    // For using command-1 to command-9.
    @objc private func selectTabByNumberFromKeyCommand(_ sender: UIKeyCommand) {
        guard let keyInput = sender.input, let targetTabNumber = Int(keyInput), targetTabNumber > 0 else {
            return
        }

        let incomingIndex = targetTabNumber - 1
        let incomingViewController = viewControllers![incomingIndex]

        // To match the callbacks tapping the tabs, call the delegate even if selecting the already selected tab.

        guard delegate?.tabBarController?(self, shouldSelect: incomingViewController) ?? true else {
            return
        }

        selectedIndex = incomingIndex

        precondition(selectedViewController == incomingViewController)
        self.delegate?.tabBarController?(self, didSelect: incomingViewController)
    }

    // On Big Sur, the tabs in the bar are focusable, but you can’t activate the selection to select a tab.
    // Overriding shouldUpdateFocusInContext to return false can break the focus system though
    // so just allow this bogus focus. It’s not an issue on iOS 15 on iPad.
}
