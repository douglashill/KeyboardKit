// Douglas Hill, October 2021

import UIKit
import KeyboardKit

@available(iOS 13.0, *)
enum MenuBuilderError: Error {
    /// The parent or sibling menu was not found when trying to insert menu elements.
    case menuNotFoundWhenInserting(menuElements: [UIMenuElement], reference: UIMenu.Identifier)
    /// The menu couldn’t be added. Most likely due to key command inputs conflicting with existing commands. Check the console for details.
    case menuNotAdded([UIMenuElement])
    /// The parent or sibling menu was not found when trying to remove a menu.
    case menuNotFoundWhenRemoving(UIMenu.Identifier)
    /// The menu couldn’t be removed. It stayed in the menu after an attempt was made to remove it.
    case menuNotRemoved(UIMenu.Identifier)
}

/// An extension that sets `shouldBeIncludedInResponderChainKeyCommands` for key commands from KeyboardKit and adds error reporting to the UIKit API.
@available(iOS 13.0, *)
extension UIMenuBuilder {

    // If you try to insert a `displaysInline` sibling after a top-level menu, the inserted menu item don’t show up at all.
    // If you try to insert a `displaysInline` child in a non-top-level menu, it ends up not displaying inline so you get a menu with an empty title.
    // Therefore the naming of these helpers is set up to guide correct usage.
    // (This is on Mac, which ended up not being supported but it still seems best to do something that would work on Mac if desired at some point.)

    /// Wrapper around the UIKit API that sets `shouldBeIncludedInResponderChainKeyCommands` for key commands from KeyboardKit.
    /// This also adds error reporting and takes care of wrapping menu elements in `UIMenu` if needed.
    func insertSiblings(_ menuElements: [UIMenuElement], afterNonTopLevelMenu siblingIdentifier: UIMenu.Identifier) throws {
        try insert(menuElements, relativeTo: siblingIdentifier) {
            insertSibling($0, afterMenu: siblingIdentifier)
        }
    }

    /// Wrapper around the UIKit API that sets `shouldBeIncludedInResponderChainKeyCommands` for key commands from KeyboardKit.
    /// This also adds error reporting and takes care of wrapping menu elements in `UIMenu` if needed.
    func insertChildren(_ menuElements: [UIMenuElement], atEndOfTopLevelMenu parentIdentifier: UIMenu.Identifier) throws {
        try insert(menuElements, relativeTo: parentIdentifier) {
            insertChild($0, atEndOfMenu: parentIdentifier)
        }
    }

    private func insert(_ menuElements: [UIMenuElement], relativeTo referenceIdentifier: UIMenu.Identifier, using insertionClosure: (UIMenu) -> Void) throws {
        if menu(for: referenceIdentifier) == nil {
            throw MenuBuilderError.menuNotFoundWhenInserting(menuElements: menuElements, reference: referenceIdentifier)
        }

        let newMenu: UIMenu
        if menuElements.count == 1, let menu = menuElements.first as? UIMenu {
            newMenu = menu
        } else {
            newMenu = UIMenu(title: "", options: [.displayInline], children: menuElements)
        }

        insertionClosure(newMenu)

        if menu(for: newMenu.identifier) == nil {
            throw MenuBuilderError.menuNotAdded(menuElements)
        }

        /*
         Since we added these commands to the main menu, we need to tell KeyboardKit not to include these commands in its
         responders’ overrides of `keyCommands`. Otherwise on iPad UIKit would fine come across these commands from
         overrides of `keyCommands` on the responder chain, so would show the commands under the application section of the
         key command discoverability HUD instead of in the more specific menus we just set up. Note that on Mac, including
         key commands both in the main menu and in overrides of `keyCommands` on the responder chain is not a problem.
         */
        for command in menuElements.compactMap({ $0 as? DiscoverableKeyCommand }) {
            command.shouldBeIncludedInResponderChainKeyCommands = false
        }
    }

    func removeMenu(_ menuIdentifier: UIMenu.Identifier) throws {
        if menu(for: menuIdentifier) == nil {
            throw MenuBuilderError.menuNotFoundWhenRemoving(menuIdentifier)
        }

        remove(menu: menuIdentifier)

        if menu(for: menuIdentifier) != nil {
            throw MenuBuilderError.menuNotRemoved(menuIdentifier)
        }
    }
}

// MARK: - Recursive description debug helper

#if DEBUG

@available(iOS 13.0, *)
extension UIMenuElement {
    @objc func printRecursiveDescription(indent: String = "") {
        print("\(indent)\(self)")
    }
}

@available(iOS 13.0, *)
extension UIMenu {
    override func printRecursiveDescription(indent: String = "") {
        print("\(indent)\(self.title.isEmpty ? "\(self.identifier.rawValue)" : self.title)")
        for child in children {
            child.printRecursiveDescription(indent: indent + "    ")
        }
    }
}

#endif
