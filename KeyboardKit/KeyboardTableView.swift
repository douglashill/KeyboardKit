// Douglas Hill, December 2018
// Made for https://douglashill.co/reading-app/

import UIKit

/// A table view that supports navigation and selection using a hardware keyboard.
///
/// This class can be seen in action in the *Table View* example in the demo app,
/// which shows selecting, reordering, deleting and refreshing.
///
/// **Focus system**
///
/// KeyboardKit sets `allowsFocus` and `remembersLastFocusedIndexPath` to true by default,
/// so if a `UIFocusSystem` is available then UIKit will provide support for arrow key
/// navigation in the table view.
///
/// If no `UIFocusSystem` is available then KeyboardKit fills in by providing similar
/// functionality as long as the table view becomes first responder. In this case, it is
/// your app’s responsibility to manage which object is first responder. The item that the
/// user navigates to is modelled with the table view selection state, not the focus state.
///
/// The focus system is available from iOS 15 on iPad and from iOS 14 on Mac (macOS 11 Big Sur
/// and later). As of iOS 15, the focus system is not available at all on iPhone.
///
/// Moving items with opt-cmd-arrow and deleting items with the delete key will act on the
/// focused item if `UIFocusSystem` is available and on the selected item otherwise.
///
/// **Reordering**
///
/// If the app enables reordering then KeyboardKit allows users to move rows using
/// the *option + command + up* and *option + command + down* key combinations. This will
/// move the selected row into the position of the row immediately above or below it.
///
/// KeyboardKit’s support for reordering uses standard UIKit API. To enable reordering,
/// the table view’s `dataSource` must implement `tableView(_:moveRowAt:to:)`. To disable
/// moving certain rows, the data source should implement `tableView(_:canMoveRowAt:)`.
/// If this is not implemented then moving will be allowed. To alter the destination
/// index path of a move operation, the table view’s `delegate` should implement
/// `tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)`.
///
/// ⚠️ Moving rows using a hardware keyboard is not supported when using a `UITableViewDiffableDataSource`.
///
/// Moving *sections* using a hardware keyboard is not supported.
open class KeyboardTableView: UITableView, ResponderChainInjection {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
#if iOS_15_SDK
        if #available(iOS 15.0, *) {
            allowsFocus = true
            remembersLastFocusedIndexPath = true
        }
#endif
    }

    open override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var keyHandler = TableViewKeyHandler(tableView: self, owner: self)

    open override var next: UIResponder? {
        keyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        return super.next
    }
}

/// A table view controller that supports navigation and selection using a hardware keyboard.
///
/// See `KeyboardTableView` for further details. There is no difference in
/// functionality between the view subclass and the view controller subclass.
open class KeyboardTableViewController: UITableViewController, ResponderChainInjection {
    open override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var keyHandler = TableViewKeyHandler(tableView: tableView, owner: self)

    open override var next: UIResponder? {
        keyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        return super.next
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

#if iOS_15_SDK
        if #available(iOS 15.0, *) {
            tableView.allowsFocus = true
            tableView.remembersLastFocusedIndexPath = true
        }
#endif
    }
}

/// A table view’s `delegate` can conform to this protocol to receive callbacks about keyboard-specific events.
///
/// This can be used with either `KeyboardTableView` or `KeyboardTableViewController`.
///
/// When selection is activated with return or space, the regular delegate method `tableView(_:didSelectRowAt:)` is called.
public protocol KeyboardTableViewDelegate: UITableViewDelegate {
    /// Called when a keyboard is used to change the selected rows.
    ///
    /// This happens in response to arrow keys, escape and ⌘A.
    /// When there is a `UIFocusSystem`, this is only called for Select All (⌘A).
    /// The rows show as selected but `tableView(_:didSelectRowAt:)` is not
    /// called unless return or space is pressed while a single row shows selection.
    ///
    /// The new selected rows can be read using `tableView.indexPathsForSelectedRows`.
    ///
    /// Typically this callback would be used for changes in a table view in a sidebar to update the
    /// content in a detail view. This callback should typically be ignored when a split view controller
    /// is collapsed because updating a detail view that isn’t visible may be wasteful.
    func tableViewDidChangeSelectedRowsUsingKeyboard(_ tableView: UITableView)

    /// Asks the delegate whether the selection is allowed to be cleared by pressing the escape key.
    ///
    /// This is not called when there is a `UIFocusSystem`.
    ///
    /// If not implemented, the collection view assumes it can clear the selection (i.e. this defaults to true).
    func tableViewShouldClearSelection(_ tableView: UITableView) -> Bool
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

    override var next: UIResponder? {
        selectableCollectionKeyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        if responder === selectableCollectionKeyHandler {
            return scrollViewKeyHandler
        } else if responder === scrollViewKeyHandler {
            return super.next
        } else {
            preconditionFailure()
        }
    }

    private lazy var deleteCommand = UIKeyCommand(.delete, action: #selector(kbd_deleteSelectedRows), title: localisedString(.delete))

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if tableView.canDeleteFocusOrSelectedRows {
            commands.append(deleteCommand)
        }

        return commands
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(kbd_deleteSelectedRows) {
            return tableView.canDeleteFocusOrSelectedRows
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    // This must be on the key handler not on the table view because in the case of a KeyboardTableViewController
    // being first responder the table view would not be on the responder chain so would not receive the message.

    @objc func kbd_deleteSelectedRows(_ keyCommand: UIKeyCommand) {
        tableView.deleteFocusOrSelectedRows()
    }
}

extension UITableView {
    override var kbd_isArrowKeyScrollingEnabled: Bool {
        isKeyboardScrollingEnabled
    }

    override var kbd_isSpaceBarScrollingEnabled: Bool {
        isKeyboardScrollingEnabled
    }
}

extension UITableView: SelectableCollection {
    private var keyboardDelegate: KeyboardTableViewDelegate? {
        delegate as? KeyboardTableViewDelegate
    }

    func numberOfItems(inSection section: Int) -> Int {
        numberOfRows(inSection: section)
    }

    var allowsSelectionDuringEditing_: Bool {
        allowsSelectionDuringEditing
    }

    var allowsMultipleSelectionDuringEditing_: Bool {
        allowsMultipleSelectionDuringEditing
    }

    var isEditing_: Bool {
        isEditing
    }

    var shouldAllowEmptySelection: Bool? {
        keyboardDelegate?.tableViewShouldClearSelection(self)
    }

    func shouldSelectItemAtIndexPath(_ indexPath: IndexPath) -> Bool {
        delegate?.tableView?(self, shouldHighlightRowAt: indexPath) ?? true
    }

    var indexPathsForFocusedOrSelectedItems: [IndexPath] {
        if UIFocusSystem(for: self) != nil {
            return preferredFocusEnvironments.compactMap { $0 as? UITableViewCell }.compactMap { indexPath(for: $0) }
        } else {
            return indexPathsForSelectedRows ?? []
        }
    }

    func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        selectRow(at: indexPath, animated: animated, scrollPosition: .init(scrollPosition))
    }

    func notifyDelegateOfSelectionChange() {
        keyboardDelegate?.tableViewDidChangeSelectedRowsUsingKeyboard(self)
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

            case (.up, .closestForMoving):
                return indexPathToMoveToBeforeIndexPath(indexPath!)

            case (.up, .end):
                return firstSelectableIndexPath

            case (.down, .closest):
                // Select the first highlightable item after the current selection, or select the first highlightable
                // item if there is no current selection or if the current selection is the last highlightable item.
                if let indexPath = indexPath, let target = selectableIndexPathAfterIndexPath(indexPath) {
                    return target
                } else {
                    return firstSelectableIndexPath
                }

            case (.down, .closestForMoving):
                return indexPathToMoveToAfterIndexPath(indexPath!)

            case (.down, .end):
                return lastSelectableIndexPath

            case (.left, _), (.right, _):
                return nil
        }
    }

    var shouldAllowMoving: Bool {
        guard let dataSource = dataSource else {
            return false
        }
        // Diff-able data sources are not supported. See the comment in the implementation of shouldAllowMoving for UICollectionView.
        if NSStringFromClass(type(of: dataSource)).contains("UITableViewDiffableDataSource") {
            return false
        }
        return dataSource.responds(to: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:)))
    }

    func canMoveItem(at indexPath: IndexPath) -> Bool? {
        dataSource!.tableView?(self, canMoveRowAt: indexPath)
    }

    func targetIndexPathForMoveFromItem(at originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath? {
        delegate?.tableView?(self, targetIndexPathForMoveFromRowAt: originalIndexPath, toProposedIndexPath: proposedIndexPath)
    }

    func kdb_moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        // It is important to update the data source first otherwise you can end up ‘duplicating’ the cell being moved when moving quickly at the edges.
        // nil data source and not implementing method was checked in canMoveItem so force here.
        dataSource!.tableView!(self, moveRowAt: indexPath, to: newIndexPath)
        moveRow(at: indexPath, to: newIndexPath)
    }
}

// MARK: - Deletion

private extension UITableView {

    var canDeleteFocusOrSelectedRows: Bool {
        let indexPathsForFocusedOrSelectedItems = self.indexPathsForFocusedOrSelectedItems

        guard indexPathsForFocusedOrSelectedItems.isEmpty == false else {
            // No selected rows means no deletion.
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

        for indexPath in indexPathsForFocusedOrSelectedItems {
            if delegate.tableView!(self, editingStyleForRowAt: indexPath) != .delete {
                return false
            }
        }

        // All selected index paths have the delete editing style.
        return true
    }

    func deleteFocusOrSelectedRows() {
        let indexPathsForFocusedOrSelectedItems = self.indexPathsForFocusedOrSelectedItems

        guard indexPathsForFocusedOrSelectedItems.isEmpty == false else {
            return
        }

        let indexPathsToDelete = indexPathsForFocusedOrSelectedItems

        if UIFocusSystem(for: self) != nil {
            // The focus system either focuses the item right at the top of loses focus, but it’s hard to force it to focus something better.
        } else {
            let newSelectedIndexPath = selectableIndexPathAfterIndexPath(indexPathsForFocusedOrSelectedItems.last!) ?? selectableIndexPathBeforeIndexPath(indexPathsForFocusedOrSelectedItems.first!)
            selectRow(at: newSelectedIndexPath, animated: false, scrollPosition: .none)
        }

        for indexPath in indexPathsToDelete {
            // This is a precaution because canDeleteSelectedRows should have blocked this action if any row had a different editing style.
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
