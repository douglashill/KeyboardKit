// Douglas Hill, December 2018
// Made for https://douglashill.co/reading-app/

import UIKit

/// A table view that supports navigation and selection using a hardware keyboard.
open class KeyboardTableView: UITableView, ResponderChainInjection {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var keyHandler = TableViewKeyHandler(tableView: self, owner: self)

    public override var next: UIResponder? {
        keyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        return super.next
    }
}

/// A table view controller that supports navigation and selection using a hardware keyboard.
open class KeyboardTableViewController: UITableViewController, ResponderChainInjection {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var keyHandler = TableViewKeyHandler(tableView: tableView, owner: self)

    public override var next: UIResponder? {
        keyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        return super.next
    }
}

/// Provides key commands for a table view and implements the actions of those key commands.
/// In order to receive those actions the object must be added to the responder chain
/// by the owner overriding `nextResponder`. Then implement `nextResponderForResponder`
/// to put the responder chain back on its regular path.
///
/// This class is tightly coupled with `UITableView`. It’s a separate class so it can be used
/// with both `KeyboardTableView` and `KeyboardTableViewController`.
private class TableViewKeyHandler: InjectableResponder, ResponderChainInjection {

    private unowned var tableView: UITableView

    init(tableView: UITableView, owner: ResponderChainInjection) {
        self.tableView = tableView
        super.init(owner: owner)
    }

    private lazy var selectableCollectionKeyHandler = SelectableCollectionKeyHandler(selectableCollection: tableView, owner: self)
    private lazy var scrollViewKeyHandler = ScrollViewKeyHandler(scrollView: tableView, owner: self)

    // TODO: See if the `delete:` action from UIResponderStandardEditActions can be leveraged.
    private lazy var deleteCommand = UIKeyCommand(.delete, action: #selector(UITableView.kbd_deleteSelectedRows), title: localisedString(.delete))

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if tableView.canDeleteSelectedRows {
            commands.append(deleteCommand)
        }

        return commands
    }

    override var next: UIResponder? {
        selectableCollectionKeyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        if responder === selectableCollectionKeyHandler {
            return scrollViewKeyHandler
        } else if responder == scrollViewKeyHandler {
            return super.next
        } else {
            fatalError()
        }
    }
}

extension UITableView {
    override var kbd_isArrowKeyScrollingEnabled: Bool {
        shouldAllowSelection == false
    }

    override var kbd_isSpaceBarScrollingEnabled: Bool {
        shouldAllowSelection == false
    }
}

extension UITableView: SelectableCollection {

    func numberOfItems(inSection section: Int) -> Int {
        numberOfRows(inSection: section)
    }

    var shouldAllowSelection: Bool {
        isEditing ? allowsSelectionDuringEditing : allowsSelection
    }

    var shouldAllowMultipleSelection: Bool {
        isEditing ? allowsMultipleSelectionDuringEditing : allowsMultipleSelection
    }

    func shouldSelectItemAtIndexPath(_ indexPath: IndexPath) -> Bool {
        delegate?.tableView?(self, shouldHighlightRowAt: indexPath) ?? true
    }

    var indexPathsForSelectedItems: [IndexPath]? {
        indexPathsForSelectedRows
    }

    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        selectRow(at: indexPath, animated: animated, scrollPosition: .init(scrollPosition))
    }

    func activateSelection(at indexPath: IndexPath) {
        delegate?.tableView?(self, didSelectRowAt: indexPath)
    }

    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        scrollToRow(at: indexPath, at: .init(scrollPosition), animated: animated)
    }

    func cellVisibility(atIndexPath indexPath: IndexPath) -> CellVisibility {
        let rowFrame = rectForRow(at: indexPath)
        if bounds.inset(by: adjustedContentInset).contains(rowFrame) {
            return .fullyVisible
        }

        let position: UICollectionView.ScrollPosition = rowFrame.midY < bounds.midY ? .top : .bottom
        return .notFullyVisible(position)
    }

    func indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection direction: NavigationDirection, step: NavigationStep) -> IndexPath? {
            switch (direction, step) {
            case (.up, .closest):
                // Select the first highlightable item before the current selection, or select the last highlightable
                // item if there is no current selection or if the current selection is the first highlightable item.
                if let indexPath = indexPath, let target = selectableIndexPathBeforeIndexPath(indexPath) {
                    return target
                } else {
                    return lastSelectableIndexPath
                }

            case (.up, .end):
                return firstSelectableIndexPath

            case (.down, .closest):
                // Select the first highlightable item after the current selection, or select the first highlightable
                // item if there is no current selection or if the current selection is the last highlightable item.
                if let oldSelection = indexPath, let target = selectableIndexPathAfterIndexPath(oldSelection) {
                    return target
                } else {
                    return firstSelectableIndexPath
                }

            case (.down, .end):
                return lastSelectableIndexPath

            case (.left, _), (.right, _):
                return nil
        }
    }
}

// MARK: - Deletion

private extension UITableView {

    var canDeleteSelectedRows: Bool {
        // TODO: Maybe don’t check so thoroughly here and just allow the key command to be there and do nothing if there is nothing to delete.

        guard let indexPathsForSelectedRows = indexPathsForSelectedRows, indexPathsForSelectedRows.isEmpty == false else {
            // You could say you can delete all zero selected rows but makes more sense to say no selected rows means no deletion.
            return false
        }

        // Implementing this method enables swipe to delete.
        guard let dataSource = dataSource, dataSource.responds(to: #selector(UITableViewDataSource.tableView(_:commit:forRowAt:))) else {
            return false
        }

        guard let delegate = delegate, delegate.responds(to: #selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:))) else {
            // Default is UITableViewCellEditingStyleDelete.
            return true
        }

        for indexPath in indexPathsForSelectedRows {
            if delegate.tableView!(self, editingStyleForRowAt: indexPath) != .delete {
                return false
            }
        }

        // All selected index paths have the delete editing style.
        return true
    }

    @objc func kbd_deleteSelectedRows(_ keyCommand: UIKeyCommand) {
        guard let indexPathsForSelectedRows = indexPathsForSelectedRows, indexPathsForSelectedRows.isEmpty == false else {
            return
        }

        let indexPathsToDelete = indexPathsForSelectedRows

        let newSelectedIndexPath = selectableIndexPathAfterIndexPath(indexPathsForSelectedRows.first!)
        // TODO: End up selecting the last index path if deleting the bottom row.
        selectRow(at: newSelectedIndexPath, animated: false, scrollPosition: .none)

        for indexPath in indexPathsToDelete {
            guard delegate?.tableView?(self, editingStyleForRowAt: indexPath) ?? .delete == .delete else {
                continue
            }

            dataSource!.tableView!(self, commit: .delete, forRowAt: indexPath)
        }
    }
}

// MARK: - ScrollPosition type conversion

private extension UITableView.ScrollPosition {
    init(_ position: UICollectionView.ScrollPosition) {
        if position.contains( .top) {
            self = .top
        } else if position.contains(.bottom) {
            self = .bottom
        } else if position.contains(.centeredVertically) {
            self = .middle
        } else {
            self = .none
        }
    }
}

private extension UICollectionView.ScrollPosition {
    init(_ position: UITableView.ScrollPosition) {
        switch position {
        case .top: self = .top
        case .bottom: self = .bottom
        case .middle: self = .centeredVertically
        case .none: fallthrough @unknown default: self = []
        }
    }
}
