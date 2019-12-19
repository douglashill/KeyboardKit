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

    // Leave cmd + N for compose, or making new documents. Using cmd + opt + N matches Mail on the Mac’s command for New Viewer Window.
    @available(iOS 13.0, *)
    private lazy var newWindowKeyCommand = UIKeyCommand(([.command, .alternate], "N"), action: #selector(kbd_createNewWindowScene), title: localisedString(.app_newWindow))
    private lazy var openSettingsKeyCommand = UIKeyCommand((.command, ","), action: #selector(kbd_openSettings), title: localisedString(.app_settings))

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if #available(iOS 13, *), supportsMultipleScenes {
            commands.append(newWindowKeyCommand)
        }

        if canOpenSettings {
            commands.append(openSettingsKeyCommand)
        }

        return commands
    }
}

private extension UIApplication {

    @available(iOS 13.0, *)
    @objc func kbd_createNewWindowScene(_ sender: UIKeyCommand) {
        requestSceneSessionActivation(nil, userActivity: nil, options: nil, errorHandler: nil)
    }

    @objc func kbd_openSettings(_ sender: UIKeyCommand) {
        open(URL(string: UIApplication.openSettingsURLString)!)
    }
}
