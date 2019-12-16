// Douglas Hill, November 2019

import UIKit

/// An application that supports creating new windows and showing settings using commands from a hardware keyboard.
/// Subclasses of UIApplication can be passed into UIApplicationMain.
open class KeyboardApplication: UIApplication {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    /// Set this to true to add a key command that opens the settings app.
    /// Don’t do this if the app does not have any settings or permissions it asks for.
    /// Don’t use this on Mac Catalyst. Use the main menu there and say Preferences.
    public var canOpenSettings = false

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if supportsMultipleScenes {
            commands.append(UIKeyCommand(title: localisedString(.app_newWindow), action: #selector(createNewWindowScene), input: "N", modifierFlags: .command))
        }

        if canOpenSettings {
            commands.append(UIKeyCommand(title: localisedString(.app_settings), action: #selector(openSettings), input: ",", modifierFlags: .command))
        }

        return commands
    }

    @objc private func createNewWindowScene(sender: UIKeyCommand) {
        requestSceneSessionActivation(nil, userActivity: nil, options: nil, errorHandler: nil)
    }

    @objc private func openSettings(sender: UIKeyCommand) {
        open(URL(string: UIApplication.openSettingsURLString)!)
    }
}
