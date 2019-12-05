// Douglas Hill, May 2019

import UIKit

/// A tab bar controller that allows navigating between tabs using cmd+number on a hardware keyboard.
/// So cmd+1 for the first tab, cmd+2 for the second tab etc.
public class KeyboardTabBarController: UITabBarController {

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if let items = tabBar.items {
            commands += items.prefix(9).enumerated().map { index, tabBarItem in
                UIKeyCommand(maybeTitle: tabBarItem.title, action: #selector(scrollToNumberedTab), input: String(index + 1), modifierFlags: .command)
            }
        }

        return commands
    }

    // For using command-1 to command-9.
    @objc private func scrollToNumberedTab(_ sender: UIKeyCommand) {
        guard let keyInput = sender.input, let targetTabNumber = Int(keyInput), targetTabNumber > 0 else {
            return
        }

        selectedIndex = targetTabNumber - 1
    }
}
