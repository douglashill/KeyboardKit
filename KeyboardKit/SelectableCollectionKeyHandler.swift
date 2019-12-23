// Douglas Hill, December 2019

import UIKit

/// Whether an item is fully visible, or if not if it’s above or below, or right or left of, the viewport.
enum CellVisibility { case fullyVisible; case notFullyVisible(UICollectionView.ScrollPosition); }

enum NavigationDirection: Int {
    case up
    case down
    case left
    case right
}

enum NavigationStep: Int {
    /// Step to the next closest item in the specified direction.
    case closest
    /// Step to the far end in the specified direction, such as the very top or bottom.
    case end
}

protocol SelectableCollection: NSObjectProtocol {

    var numberOfSections: Int { get }
    func numberOfItems(inSection: Int) -> Int

    var shouldAllowSelection: Bool { get }
    var shouldAllowMultipleSelection: Bool { get }
    func shouldSelectItemAtIndexPath(_ indexPath: IndexPath) -> Bool
    
    var indexPathsForSelectedItems: [IndexPath]? { get }
    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition)

    func activateSelection(at indexPath: IndexPath)

    func flashScrollIndicators()
    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool)

    /// Whether the given item is fully visible, or if not if it’s above or below, or right or left of, the viewport.
    func cellVisibility(atIndexPath indexPath: IndexPath) -> CellVisibility

    func indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection direction: NavigationDirection, step: NavigationStep, forKeyHandler keyHandler: SelectableCollectionKeyHandler) -> IndexPath?
}

class SelectableCollectionKeyHandler: InjectableResponder {

    private unowned var collection: SelectableCollection

    init(selectableCollection: SelectableCollection, owner: ResponderChainInjection) {
        collection = selectableCollection
        super.init(owner: owner)
    }

    // MARK: -

    private lazy var selectionKeyCommands: [UIKeyCommand] = [.upArrow, .downArrow, .leftArrow, .rightArrow].flatMap { input -> [UIKeyCommand] in
        [UIKeyModifierFlags(), .alternate, .shift, [.alternate, .shift]].map { modifierFlags in
            UIKeyCommand((modifierFlags, input), action: #selector(updateSelectionFromKeyCommand))
        }
    } + [
        UIKeyCommand(UIKeyCommand.inputEscape, action: #selector(clearSelection)),
        UIKeyCommand(.space, action: #selector(activateSelection)),
        UIKeyCommand(.return, action: #selector(activateSelection)),
    ]

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if collection.shouldAllowSelection && UIResponder.isTextInputActive == false {
            commands += selectionKeyCommands
        }

        return commands
    }

    // MARK: - Arrow key selection

    @objc private func updateSelectionFromKeyCommand(_ sender: UIKeyCommand) {
        let direction = sender.navigationDirection
        let step = sender.navigationStep

        // TODO: something for multiple selection like extension/contraction of the selected range

        guard let indexPath = indexPathInDirection(direction, step: step) else {
            return
        }

        selectAndShowItemAtIndexPath(indexPath, extendSelection: false)
    }

    private func indexPathInDirection(_ direction: NavigationDirection, step: NavigationStep) -> IndexPath? {
        let existingSelection = collection.indexPathsForSelectedItems?.first

        return collection.indexPathFromIndexPath(existingSelection, inDirection: direction, step: step, forKeyHandler: self)
    }

    private func checkIndexPathIsInValidRange(_ indexPath: IndexPath) {
        precondition(indexPath.section >= 0, "Index path is out-of-bounds.")
        precondition(indexPath.section < collection.numberOfSections, "Index path is out-of-bounds.")
        precondition(indexPath.item >= 0, "Index path is out-of-bounds.")
        precondition(indexPath.item < collection.numberOfItems(inSection: indexPath.section), "Index path is out-of-bounds.")
    }

    /// Selects the item at the given index path and scrolls if needed so that the item is visible.
    ///
    /// - Parameters:
    ///   - indexPath: The index path to select. This must be in-bounds or an assertion will fail.
    ///   - isExtendingSelection: If true, add the index path to the selected cells. If false, clear any existing selection to select only the passed index path.
    private func selectAndShowItemAtIndexPath(_ indexPath: IndexPath, extendSelection isExtendingSelection: Bool) {
        checkIndexPathIsInValidRange(indexPath)

        // Looks better and feel more responsive if the selection updates without animation.
        // The scrolling will have animation if the target is not fully visible.

        collection.selectItem(at: nil, animated: false, scrollPosition: [])

        collection.selectItem(at: indexPath, animated: false, scrollPosition: [])

        switch collection.cellVisibility(atIndexPath: indexPath) {
        case .fullyVisible:
            break
        case .notFullyVisible(let scrollPosition):
            collection.scrollToItem(at: indexPath, at: scrollPosition, animated: true)
            collection.flashScrollIndicators()
        }
    }

    // MARK: - Sequential index path changes

    /// Returns the index path to select before a given index path or nil if there is no such index path.
    func selectableIndexPathBeforeIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        checkIndexPathIsInValidRange(indexPath)

        var section = indexPath.section
        while section >= 0 {
            let numberOfItems = collection.numberOfItems(inSection: section)
            // For the first section we look in, we want to just check the item before in the same section.
            // When the section changes, we need to start from the last item.
            var item = section == indexPath.section ? indexPath.item - 1 : numberOfItems - 1

            while item >= 0 {
                let targetIndexPath = IndexPath(item: item, section: section)
                if collection.shouldSelectItemAtIndexPath(targetIndexPath) {
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
        while section < collection.numberOfSections {
            let numberOfItems = collection.numberOfItems(inSection: section)
            // For the first section we look in, we want to just check the item after in the same section.
            // When the section changes, we need to start from the first item.
            var item = section == indexPath.section ? indexPath.item + 1 : 0

            while item < numberOfItems {
                let targetIndexPath = IndexPath(item: item, section: section)
                if collection.shouldSelectItemAtIndexPath(targetIndexPath) {
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
        while section < collection.numberOfSections {
            let numberOfItems = collection.numberOfItems(inSection: section)

            var item = 0
            while item < numberOfItems {
                let targetIndexPath = IndexPath(item: item, section: section)
                if collection.shouldSelectItemAtIndexPath(targetIndexPath) {
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
        var section = collection.numberOfSections - 1
        while section >= 0 {
            let numberOfItems = collection.numberOfItems(inSection: section)

            var item = numberOfItems - 1
            while item >= 0 {
                let targetIndexPath = IndexPath(item: item, section:section)
                if collection.shouldSelectItemAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                item -= 1
            }

            section -= 1
        }

        return nil
    }

    // MARK: - Select all

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        var canPerform = super.canPerformAction(action, withSender: sender)

        if action == #selector(selectAll(_:)) {
            canPerform = canPerform || collection.shouldAllowMultipleSelection
        }

        return canPerform
    }

    public override func selectAll(_ sender: Any?) {
        guard collection.shouldAllowMultipleSelection else {
            return
        }

        for section in 0 ..< collection.numberOfSections {
            for item in  0 ..< collection.numberOfItems(inSection: section) {
                collection.selectItem(at: IndexPath(item: item, section: section), animated: false, scrollPosition: [])
            }
        }
    }

    // MARK: - Using the selection

    @objc private func clearSelection(_ sender: UIKeyCommand) {
        collection.selectItem(at: nil, animated: false, scrollPosition: [])
    }

    @objc private func activateSelection(_ sender: UIKeyCommand) {
        guard let indexPathForSingleSelectedItem = collection.indexPathsForSelectedItems?.single else {
            return
        }
        collection.activateSelection(at: indexPathForSingleSelectedItem)
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
        default: fatalError()
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
