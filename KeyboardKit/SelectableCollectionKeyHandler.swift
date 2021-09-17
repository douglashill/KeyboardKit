// Douglas Hill, December 2019

import UIKit

/// Whether an item is fully visible, or if not if it’s above or below, or right or left of, the viewport.
enum CellVisibility { case fullyVisible; case notFullyVisible(UICollectionView.ScrollPosition); }

/// A spatial direction in which a selection change from an arrow key may occur.
enum NavigationDirection: Int {
    case up
    case down
    case left
    case right
}

/// A distance over which a selection change from an arrow key may move.
enum NavigationStep: Int {
    /// Step to the next closest selectable item in the specified direction. If reaching the end, start searching again on the far side.
    case closest
    /// Step to the next closest index path to use as a move destination in the specified direction. Return nil if at the end.
    case closestForMoving
    /// Step to the selectable item furthest at the end in the specified direction, such as the very top or bottom.
    case end
}

/// An object that uses cells to display a collection of items separated into sections, where each item/cell can be selected.
///
/// This is an abstraction over `UICollectionView` and `UITableView`.
protocol SelectableCollection: UIFocusEnvironment {

    var numberOfSections: Int { get }
    func numberOfItems(inSection: Int) -> Int

    var allowsSelection: Bool { get }
    var allowsMultipleSelection: Bool { get }
    var allowsSelectionDuringEditing_: Bool { get }
    var allowsMultipleSelectionDuringEditing_: Bool { get }
    var isEditing_: Bool { get }

#if iOS_15_SDK
    @available(iOS 15.0, *) var allowsFocus: Bool { get }
    @available(iOS 15.0, *) var allowsFocusDuringEditing: Bool { get }
#endif

    /// Optional because the delegate might not implement the method so the default value is not repeated.
    var shouldAllowEmptySelection: Bool? { get }
    func shouldSelectItemAtIndexPath(_ indexPath: IndexPath) -> Bool

    /// Index paths of the currently focused items if integrating with the UIKit focus system is enabled or the selected items otherwise.
    var indexPathsForFocusedOrSelectedItems: [IndexPath] { get }
    /// Make sure `notifyDelegateOfSelectionChange` is called after this (potentially after batch selection changes).
    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition)
    /// Should be called after `selectItem(at indexPath: animated: scrollPosition)`.
    func notifyDelegateOfSelectionChange()
    func activateSelection(at indexPath: IndexPath)

    func flashScrollIndicators()
    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool)

    /// Whether the given item is fully visible, or if not if it’s above or below, or right or left of, the viewport.
    func cellVisibility(atIndexPath indexPath: IndexPath) -> CellVisibility

    /// Returns the index path of the item found by moving the given step in the given direction from the item at the given index path.
    /// If `step` is `closestForMoving` then `indexPath` must not be nil.
    func indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection direction: NavigationDirection, step: NavigationStep) -> IndexPath?

    var shouldAllowMoving: Bool { get }
    func canMoveItem(at indexPath: IndexPath) -> Bool?
    func targetIndexPathForMoveFromItem(at originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath?
    func kdb_moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)
}

// MARK: -

/// A responder that provides key commands for navigating and reordering in an owning `UICollectionView` or `UITableView`.
class SelectableCollectionKeyHandler: InjectableResponder {

    private unowned var collection: SelectableCollection

    init(selectableCollection: SelectableCollection, owner: ResponderChainInjection) {
        collection = selectableCollection
        super.init(owner: owner)
    }

    private lazy var changeSelectionKeyCommands: [UIKeyCommand] = [.upArrow, .downArrow, .leftArrow, .rightArrow].flatMap { input -> [UIKeyCommand] in
        // TODO: Add .shift and [.alternate, .shift] here to support extending multiple selection.
        [UIKeyModifierFlags(), .alternate].map { modifierFlags in
            UIKeyCommand((modifierFlags, input), action: #selector(updateSelectionFromKeyCommand), allowsAutomaticMirroring: false)
        }
    }

    private lazy var activateSelectionKeyCommands: [UIKeyCommand] = [
        UIKeyCommand(.space, action: #selector(activateSelection)),
        UIKeyCommand(.returnOrEnter, action: #selector(activateSelection)),
    ]

    private lazy var deselectionKeyCommands: [UIKeyCommand] = [
        UIKeyCommand(.escape, action: #selector(clearSelection)),
    ]

    private lazy var moveKeyCommands: [UIKeyCommand] = [
        UIKeyCommand(([.alternate, .command], .upArrow),    action: #selector(kbd_move), title: localisedString(.collection_moveUp),    allowsAutomaticMirroring: false),
        UIKeyCommand(([.alternate, .command], .downArrow),  action: #selector(kbd_move), title: localisedString(.collection_moveDown),  allowsAutomaticMirroring: false),
        UIKeyCommand(([.alternate, .command], .leftArrow),  action: #selector(kbd_move), title: localisedString(.collection_moveLeft),  allowsAutomaticMirroring: false),
        UIKeyCommand(([.alternate, .command], .rightArrow), action: #selector(kbd_move), title: localisedString(.collection_moveRight), allowsAutomaticMirroring: false),
    ]

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        /*
         The documentation at https://developer.apple.com/documentation/uikit/uikeycommand states:

         > the system looks for an object in the responder chain with a key command object that matches the pressed keys

         However when the first responder is in the secondary column of a `UISplitViewController`, UIKit will query
         and perform the actions of key commands coming from the primary column of the split view. UIKit does not
         achieve this by modifying the path of the responder chain to go through the primary. No responder in the
         primary is in the responder chain. UIKit is not behaving as documented. This was tested with iOS 14.2.

         This behaviour would be useful in some cases such as activating navigation bar buttons via keyboard, but
         for arrows keys it breaks the concept of keyboard focus. Therefore we work around this by blocking all
         key commands when not on the responder chain using the `isInResponderChain` helper.
         */
        if collection.shouldAllowSelection && isInResponderChain {
            if UIFocusSystem(for: collection) == nil && UIResponder.isTextInputActive == false {
                // On iOS 15.0 (as of beta 4) a key command with an action that nothing can perform still blocks
                // other key commands from handling the same input. This was not an issue on iOS 14 and earlier.
                // This has been reported as FB9469253.
                commands += changeSelectionKeyCommands.filter { targetSelectedIndexPathForKeyCommand($0) != nil }

                if collection.indexPathsForFocusedOrSelectedItems.count == 1 {
                    commands += activateSelectionKeyCommands
                }

                if collection.shouldAllowEmptySelection ?? true && collection.indexPathsForFocusedOrSelectedItems.isEmpty == false {
                    commands += deselectionKeyCommands
                }
            }

            if collection.shouldAllowMoving {
                commands += moveKeyCommands
            }
        }

        return commands
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // For why isInResponderChain is used, see the comment in keyCommands above.
        switch action {
        case #selector(updateSelectionFromKeyCommand):
            if isInResponderChain, let keyCommand = sender as? UIKeyCommand {
                return targetSelectedIndexPathForKeyCommand(keyCommand) != nil
            } else {
                return false
            }

        case #selector(selectAll):
            return collection.shouldAllowMultipleSelection

        case #selector(clearSelection):
            return collection.indexPathsForFocusedOrSelectedItems.isEmpty == false && isInResponderChain

        case #selector(activateSelection):
            return collection.indexPathsForFocusedOrSelectedItems.count == 1 && isInResponderChain

        case #selector(kbd_move):
            guard isInResponderChain, let keyCommand = sender as? UIKeyCommand, collection.shouldAllowMoving else {
                return false
            }
            let selected = collection.indexPathsForFocusedOrSelectedItems
            // TODO: Handle multiple selection.
            guard selected.count == 1, selected.allSatisfy({ collection.canMoveItem(at: $0) ?? true }) else {
                return false
            }
            return destinationIndexPathForMovingItem(at: selected[0], keyCommand: keyCommand) != nil

        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }

    private func targetSelectedIndexPathForKeyCommand(_ sender: UIKeyCommand) -> IndexPath? {
        let direction = sender.navigationDirection
        let step = sender.navigationStep

        // TODO: something for multiple selection like extension/contraction of the selected range

        return collection.indexPathInDirection(direction, step: step)
    }

    /// Index path to move the selection to or nil if move is not possible.
    private func destinationIndexPathForMovingItem(at sourceIndexPath: IndexPath, keyCommand: UIKeyCommand) -> IndexPath? {
        let direction = keyCommand.navigationDirection

        // TODO: something for multiple selection (return an array).

        guard let proposed = collection.indexPathFromIndexPath(sourceIndexPath, inDirection: direction, step: .closestForMoving) else {
            return nil
        }

        return collection.targetIndexPathForMoveFromItem(at: sourceIndexPath, toProposedIndexPath: proposed) ?? proposed
    }

    @objc private func updateSelectionFromKeyCommand(_ sender: UIKeyCommand) {
        guard let indexPath = targetSelectedIndexPathForKeyCommand(sender) else {
            return
        }

        collection.selectAndShowItemAtIndexPath(indexPath, extendSelection: false)
    }

    override func selectAll(_ sender: Any?) {
        guard collection.shouldAllowMultipleSelection else {
            return
        }

        for section in 0 ..< collection.numberOfSections {
            for item in  0 ..< collection.numberOfItems(inSection: section) {
                collection.selectItem(at: IndexPath(item: item, section: section), animated: false, scrollPosition: [])
            }
        }
        collection.notifyDelegateOfSelectionChange()
    }

    @objc private func clearSelection(_ sender: UIKeyCommand) {
        collection.selectItem(at: nil, animated: false, scrollPosition: [])
        collection.notifyDelegateOfSelectionChange()
    }

    @objc private func activateSelection(_ sender: UIKeyCommand) {
        guard let indexPathForSingleSelectedItem = collection.indexPathsForFocusedOrSelectedItems.single else {
            return
        }
        collection.activateSelection(at: indexPathForSingleSelectedItem)
    }

    @objc private func kbd_move(_ sender: UIKeyCommand) {
        let source = collection.indexPathsForFocusedOrSelectedItems[0]

        guard let destination = destinationIndexPathForMovingItem(at: source, keyCommand: sender) else {
            return
        }

        collection.kdb_moveItem(at: source, to: destination)

        switch collection.cellVisibility(atIndexPath: destination) {
        case .fullyVisible:
            break
        case .notFullyVisible(let scrollPosition):
            collection.scrollToItem(at: destination, at: scrollPosition, animated: true)
            collection.flashScrollIndicators()
        }
    }
}

// MARK: - Allowing selection

extension SelectableCollection {
    var isKeyboardScrollingEnabled: Bool {
        if UIFocusSystem(for: self) != nil {
#if iOS_15_SDK
            if #available(iOS 15.0, *) {
                return (isEditing_ ? allowsFocusDuringEditing : allowsFocus) == false
            }
#endif
            // There’s no simple property to disable focus on Big Sur so just assume focus will be enabled.
            return false
        } else {
            return shouldAllowSelection == false
        }
    }

    var shouldAllowSelection: Bool {
        isEditing_ ? allowsSelectionDuringEditing_ : allowsSelection
    }

    var shouldAllowMultipleSelection: Bool {
        isEditing_ ? allowsMultipleSelectionDuringEditing_ : allowsMultipleSelection
    }
}

// MARK: - Arrow key selection

private extension SelectableCollection {

    /// Returns the index path of the item found by moving the given step in the given direction from the currently selected item.
    func indexPathInDirection(_ direction: NavigationDirection, step: NavigationStep) -> IndexPath? {
        let existingSelection = indexPathsForFocusedOrSelectedItems.first
        return indexPathFromIndexPath(existingSelection, inDirection: direction, step: step)
    }

    private func checkIndexPathIsInValidRange(_ indexPath: IndexPath) {
        precondition(indexPath.section >= 0, "Index path is out-of-bounds.")
        precondition(indexPath.section < numberOfSections, "Index path is out-of-bounds.")
        precondition(indexPath.item >= 0, "Index path is out-of-bounds.")
        precondition(indexPath.item < numberOfItems(inSection: indexPath.section), "Index path is out-of-bounds.")
    }

    /// Selects the item at the given index path and scrolls if needed so that the item is visible.
    ///
    /// - Parameters:
    ///   - indexPath: The index path to select. This must be in-bounds or an assertion will fail.
    ///   - isExtendingSelection: If true, add the index path to the selected cells. If false, clear any existing selection to select only the passed index path.
    func selectAndShowItemAtIndexPath(_ indexPath: IndexPath, extendSelection isExtendingSelection: Bool) {
        checkIndexPathIsInValidRange(indexPath)

        // Looks better and feels more responsive if the selection updates without animation.
        // The scrolling will have animation if the target is not fully visible.

        selectItem(at: nil, animated: false, scrollPosition: [])
        selectItem(at: indexPath, animated: false, scrollPosition: [])
        notifyDelegateOfSelectionChange()

        switch cellVisibility(atIndexPath: indexPath) {
        case .fullyVisible:
            break
        case .notFullyVisible(let scrollPosition):
            scrollToItem(at: indexPath, at: scrollPosition, animated: UIAccessibility.isReduceMotionEnabled == false)
            flashScrollIndicators()
        }
    }
}

// MARK: - Sequential index path changes

extension SelectableCollection {

    /// Returns the index path to select before a given index path or nil if there is no such index path.
    func selectableIndexPathBeforeIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        checkIndexPathIsInValidRange(indexPath)

        var section = indexPath.section
        while section >= 0 {
            let numberOfItems = self.numberOfItems(inSection: section)
            // For the first section we look in, we want to just check the item before in the same section.
            // When the section changes, we need to start from the last item.
            var item = section == indexPath.section ? indexPath.item - 1 : numberOfItems - 1

            while item >= 0 {
                let targetIndexPath = IndexPath(item: item, section: section)
                if shouldSelectItemAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                item -= 1
            }

            section -= 1
        }

        return nil
    }

    /// Returns the index path to select after a given index path or nil if there is no such index path.
    func selectableIndexPathAfterIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        checkIndexPathIsInValidRange(indexPath)

        var section = indexPath.section
        while section < numberOfSections {
            let numberOfItems = self.numberOfItems(inSection: section)
            // For the first section we look in, we want to just check the item after in the same section.
            // When the section changes, we need to start from the first item.
            var item = section == indexPath.section ? indexPath.item + 1 : 0

            while item < numberOfItems {
                let targetIndexPath = IndexPath(item: item, section: section)
                if shouldSelectItemAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                item += 1
            }

            section += 1
        }

        return nil
    }

    var firstSelectableIndexPath: IndexPath? {
        // Select the first highlightable item.
        var section = 0
        while section < numberOfSections {
            let numberOfItems = self.numberOfItems(inSection: section)

            var item = 0
            while item < numberOfItems {
                let targetIndexPath = IndexPath(item: item, section: section)
                if shouldSelectItemAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                item += 1
            }

            section += 1
        }

        return nil
    }

    var lastSelectableIndexPath: IndexPath? {
        // Select the last highlightable item.
        var section = numberOfSections - 1
        while section >= 0 {
            let numberOfItems = self.numberOfItems(inSection: section)

            var item = numberOfItems - 1
            while item >= 0 {
                let targetIndexPath = IndexPath(item: item, section:section)
                if shouldSelectItemAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                item -= 1
            }

            section -= 1
        }

        return nil
    }

    /// Returns the index path to move to before a given index path or nil if there is no such index path.
    func indexPathToMoveToBeforeIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        checkIndexPathIsInValidRange(indexPath)

        if indexPath.item > 0 {
            return IndexPath(item: indexPath.item - 1, section: indexPath.section)
        } else if indexPath.section > 0 {
            // Deliberately don’t subtract one from the number of items because we are increasing the number of items in
            // the destination section. It’s fine that this is out of range, even if the destination section is empty.
            // Otherwise the item being moved would end up as the second-to-last item in the section instead of the last.
            return IndexPath(item: numberOfItems(inSection: indexPath.section - 1), section: indexPath.section - 1)
        } else {
            return nil
        }
    }

    /// Returns the index path to move to after a given index path or nil if there is no such index path.
    func indexPathToMoveToAfterIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        checkIndexPathIsInValidRange(indexPath)

        if indexPath.item < numberOfItems(inSection: indexPath.section) - 1 {
            return IndexPath(item: indexPath.item + 1, section: indexPath.section)
        } else if indexPath.section < numberOfSections - 1 {
            // It’s fine if the destination section is empty. The move will create item 0 in that section.
            return IndexPath(item: 0, section: indexPath.section + 1)
        } else {
            return nil
        }
    }
}

// MARK: -

private extension Collection {
    /// The only element in the collection, or nil if there are multiple or zero elements.
    var single: Element? { count == 1 ? first! : nil }
}

private extension UIKeyCommand {
    var navigationDirection: NavigationDirection {
        switch input! {
        case .upArrow: return .up
        case .downArrow: return .down
        case .leftArrow: return .left
        case .rightArrow: return .right
        default: preconditionFailure()
        }
    }

    var navigationStep: NavigationStep {
        if modifierFlags.contains(.alternate) {
            return .end
        } else {
            return .closest
        }
    }
}
