// Douglas Hill, October 2021

import UIKit
import KeyboardKit

/// Builds the main menu for the discoverability HUD on iPad and the menu bar on Mac.
class AppDelegate: UIResponder, UIApplicationDelegate {

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        // The menu would be useful on macOS Big Sur (iOS 14) but for demo purposes
        // it’s easier to simplify this and only populate the menu on iOS 15+.
        guard #available(iOS 15.0, *), builder.system == .main else {
            return
        }

        do {
            /*
             The `insertSiblings` and `insertChildren` methods used here set `shouldBeIncludedInResponderChainKeyCommands`
             to false on key commands from KeyboardKit. Without this, KeyboardKit would provide these commands in its
             overrides of `keyCommands` on responders, which would result in these commands being shown in the application
             menu on iPad instead of in the menus that we’re specifying here.
             */

            // MARK: - Commands from KeyboardKit

            try builder.insertSiblings([KeyboardTableView.deleteKeyCommand], afterNonTopLevelMenu: .standardEdit)

            try builder.insertChildren([KeyboardCollectionView.moveUpKeyCommand, KeyboardCollectionView.moveDownKeyCommand, KeyboardCollectionView.moveLeftKeyCommand, KeyboardCollectionView.moveRightKeyCommand], atEndOfTopLevelMenu: .edit)

            // Remove the Bigger/Smaller commands since we want those inputs for Zoom In and Zoom Out and the menu builder
            // inconveniently disallows commands with the same inputs, even if they’re used in different contexts.
            // A downside of removing this is that for some reason this stops cmd - zooming out with MKMapView.
            // You can still zoom out with - (no modifier) or opt down arrow so this will have to be enough.
            try builder.removeMenu(.textSize)

            try builder.insertChildren([KeyboardDatePicker.goToTodayKeyCommand], atEndOfTopLevelMenu: .view)

            try builder.insertChildren([KeyboardScrollView.zoomInKeyCommand, KeyboardScrollView.zoomOutKeyCommand, KeyboardScrollView.actualSizeKeyCommand], atEndOfTopLevelMenu: .view)

            // Most find commands are available through `UIFindInteraction` on iOS 16 and later so this KeyboardKit functionality is not needed. (And attempting to add these commands will fail as they will be duplicates.)
            var findCommands: [UIKeyCommand] = [KeyboardTextView.jumpToSelectionKeyCommand]
            if #unavailable(iOS 16.0) {
                findCommands.insert(contentsOf: [KeyboardTextView.findNextKeyCommand, KeyboardTextView.findPreviousKeyCommand, KeyboardTextView.useSelectionForFindKeyCommand], at: 0)
            }
            try builder.insertSiblings(findCommands, afterNonTopLevelMenu: .find)

            try builder.insertChildren([
                KeyboardScrollView.refreshKeyCommand,
                KeyboardNavigationController.backKeyCommand,
            ], atEndOfTopLevelMenu: .view)

#if !targetEnvironment(macCatalyst)
            // Look Up is provided by the system on Catalyst.
            try builder.insertChildren([KeyboardTextView.defineKeyCommand], atEndOfTopLevelMenu: .edit)

            // Tab commands are not available on Catalyst because they’re dynamic.
            try builder.insertChildren(KeyboardTabBarController.changeSelectedTabKeyCommands, atEndOfTopLevelMenu: .view)

            // The New, Close and Preferences key commands are added by the system on Catalyst.
            try builder.insertSiblings([KeyboardWindowScene.closeWindowKeyCommand], afterNonTopLevelMenu: .close)
            try builder.insertSiblings([KeyboardApplication.newWindowKeyCommand], afterNonTopLevelMenu: .newScene)

            // On the Mac, Preferences would be part of the application menu, but if we put this Settings command there it
            // would be the only item in that column so would be an inefficient use of space, so use the File menu instead.
            try builder.insertChildren([KeyboardApplication.settingsKeyCommand], atEndOfTopLevelMenu: .file)
#endif

            // MARK: - Commands from the demo app

            // UIKit only allows one key command in the menu for each input.
            // By default, cmd+B is taken by Bold (`toggleBoldface:`), but we want to use this for Show Bookmarks (`showBookmarks:`).
            // We don’t need the Bold command in the KeyboardKit Demo app. For simplicity, we just remove the entire text style menu.
            try builder.removeMenu(.textStyle)

            // Do the same for the toolbar menu so Show Alert (`testAction:`) is shown properly. (Although for some reason it still works even without this.)
            try builder.removeMenu(.toolbar)

            let barButtonItemKeyCommands: [UIKeyCommand] = [
                UIKeyCommand(title: "Show Alert", action: #selector(TableViewController.testAction), input: "t", modifierFlags: [.command, .alternate]),
                UIKeyCommand(title: "Show Bookmarks", action: #selector(TableViewController.showBookmarks), input: "b", modifierFlags: .command),
                UIKeyCommand(title: "Save Bookmarks", action: #selector(BookmarksViewController.saveBookmarks), input: "s", modifierFlags: .command),
                UIKeyCommand(title: "Done", action: #selector(DismissModalActionPerformer.dismissModalViewController), input: "\r", modifierFlags: .command),
            ]

            try builder.insertChildren(DoubleColumnSplitViewController.modalExampleKeyCommands + barButtonItemKeyCommands, atEndOfTopLevelMenu: .view)

        } catch MenuBuilderError.menuNotFoundWhenInserting(let menuElements, let reference) {
            print("❌ Couldn’t find menu \(reference) when trying to insert \(menuElements).")
        } catch MenuBuilderError.menuNotAdded(let menuElements) {
            print("❌ Couldn’t add menu elements \(menuElements).")
        } catch MenuBuilderError.menuNotFoundWhenRemoving(let menuIdentifier) {
            print("❌ Couldn’t find menu \(menuIdentifier) to remove it.")
        } catch MenuBuilderError.menuNotRemoved(let menuIdentifier) {
            print("❌ Couldn’t remove menu \(menuIdentifier).")
        } catch {
            print("❌ Couldn’t build menu with an unexpected error: \(error)")
        }
    }
}
