// Douglas Hill, November 2019

import UIKit

/// A window scene that supports closing windows and cycling keyboard focus between visible windows using commands from a hardware keyboard.
/// Subclasses of UIWindowScene can be specified statically in the Application Scene Manifest in the Info.plist.
public class KeyboardWindowScene: UIWindowScene {
    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if UIApplication.shared.supportsMultipleScenes {
            commands.append(UIKeyCommand(title: localisedString(.window_cycle), action: #selector(cycleFocusBetweenVisibleWindowScenes), input: "`", modifierFlags: .command))
            commands.append(UIKeyCommand(title: localisedString(.window_close), action: #selector(closeWindowScene(sender:)), input: "W", modifierFlags: .command))
        }

        return commands
    }

    /// Cycles the key window through the visible window scenes. Expects there to be one window per window scene.
    /// Does nothing if the windows can’t be looked up.
    @objc private func cycleFocusBetweenVisibleWindowScenes(sender: UIKeyCommand) {
        // It would be good if this method worked across all sessions, not just visible window scenes.
        // However requestSceneSessionActivation is not appropriate because is breaks the app spaces the user has set up.

        // This method is not as efficient as it could be, but it probably doesn’t matter much.

        let foregroundWindowScenes = UIApplication.shared.connectedScenes.filter {
            switch $0.activationState {
            case .foregroundActive, .foregroundInactive: return true
            case .background, .unattached: fallthrough @unknown default: return false
            }
        }.compactMap {
            $0 as? UIWindowScene
        }.sorted { scene1, scene2 in
            // Use a consistent order, which we can get from the object memory addresses.
            // TODO: This ‘consistent’ order seems to sometimes change.
            // Can’t debug now because the Xcode console has stopped working.
            // TODO: Working out where each window is to always go LtR or RtL would be better.
            withUnsafePointer(to: scene1) { pointer1 in
                withUnsafePointer(to: scene2) { pointer2 in
                    pointer1 < pointer2
                }
            }
        }

        let allWindows = foregroundWindowScenes.flatMap { $0.windows }
        let keyWindow = allWindows.first { $0.isKeyWindow }
        guard let sceneWithKeyWindow = keyWindow?.windowScene else { return }
        guard let oldKeyWindowIndex = foregroundWindowScenes.firstIndex(of: sceneWithKeyWindow) else { return }
        let nextKeyWindowIndex = oldKeyWindowIndex + 1 == foregroundWindowScenes.count ? 0 : oldKeyWindowIndex + 1

        // Despite the code above looking at multiple windows per window scene, below it’s just considering the first.
        foregroundWindowScenes[nextKeyWindowIndex].windows.first?.makeKey()
    }

    @objc private func closeWindowScene(sender: UIKeyCommand) {
        UIApplication.shared.requestSceneSessionDestruction(session, options: nil, errorHandler: nil)
    }
}
