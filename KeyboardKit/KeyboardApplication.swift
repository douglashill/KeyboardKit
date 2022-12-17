// Douglas Hill, November 2019

import UIKit

/// An application that supports creating new windows and showing settings using commands from a hardware keyboard.
///
/// To use this subclass of `UIApplication`, pass it as the third argument of `UIApplicationMain`. This can either
/// be placed at the top level of a file named `main.swift` like this:
///
/// ```swift
/// UIApplicationMain(
///     CommandLine.argc,
///     CommandLine.unsafeArgv,
///     NSStringFromClass(KeyboardApplication.self),
///     NSStringFromClass(YourAppDelegate.self)
/// )
/// ```
///
/// Or in any Swift file by using `@main`. For example, like this:
///
/// ```swift
/// @main extension KeyboardApplication {
///     static func main() {
///         UIApplicationMain(
///             CommandLine.argc,
///             CommandLine.unsafeArgv,
///             NSStringFromClass(self),
///             NSStringFromClass(YourAppDelegate.self)
///         )
///     }
/// }
/// ```
open class KeyboardApplication: UIApplication {

    open override var canBecomeFirstResponder: Bool {
        true
    }

    /// Whether a key command should be provided on iOS that opens the app’s settings in the Settings app.
    ///
    /// Defaults to true if the app has a `Settings.bundle` resource and false otherwise.
    ///
    /// Don’t do this if the app does not have any settings or permissions it asks for.
    ///
    /// This property has no effect on Mac Catalyst because the system handles adding a Preferences menu item if a `Settings.bundle` exists.
    open var canOpenSettings = Bundle.main.url(forResource: "Settings", withExtension: "bundle") != nil

    // The New and Preferences key commands are added by the system on Catalyst.
#if !targetEnvironment(macCatalyst)

    /// A key command that enables users to create a new app window.
    ///
    /// Title: New Window
    ///
    /// Input: ⌥⌘N
    ///
    /// Recommended location in main menu: File
    ///
    /// Using ⌥⌘N matches Mail on the Mac’s command for New Viewer Window and leaves ⌘N available for compose or making new documents.
    ///
    /// This command is not available on Mac because the system provides a ⌘N command to open a new window.
    public static let newWindowKeyCommand = DiscoverableKeyCommand(([.command, .alternate], "N"), action: #selector(kbd_createNewWindowScene), title: localisedString(.app_newWindow))

    /// A key command that enables users to open the app’s settings in the Settings app.
    ///
    /// Title: Settings
    ///
    /// Input: ⌘,
    ///
    /// Recommended location in main menu: Application
    ///
    /// This command is not available on Mac because the system provides a ⌘, command to open the app’s Preferences window.
    public static let settingsKeyCommand = DiscoverableKeyCommand((.command, ","), action: #selector(kbd_openSettings), title: localisedString(.app_settings))

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if Self.newWindowKeyCommand.shouldBeIncludedInResponderChainKeyCommands && supportsMultipleScenes {
            commands.append(Self.newWindowKeyCommand)
        }

        if Self.settingsKeyCommand.shouldBeIncludedInResponderChainKeyCommands && canOpenSettings {
            commands.append(Self.settingsKeyCommand)
        }

        return commands
    }

    @objc func kbd_createNewWindowScene(_ sender: UIKeyCommand) {
        requestSceneSessionActivation(nil, userActivity: nil, options: nil, errorHandler: nil)
    }

    @objc func kbd_openSettings(_ sender: UIKeyCommand) {
        open(URL(string: UIApplication.openSettingsURLString)!)
    }

#endif
}
