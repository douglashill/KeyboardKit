// Douglas Hill, December 2018
// Made for https://douglashill.co/reading-app/

import UIKit

/// A table view that supports navigation and selection using a hardware keyboard.
open class KeyboardTableView: UITableView, ResponderChainInjection {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var selectableCollectionKeyHandler = SelectableCollectionKeyHandler(selectableCollection: self, owner: self)
    private lazy var scrollViewKeyHandler = ScrollViewKeyHandler(scrollView: self, owner: self)

    public override var next: UIResponder? {
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

    func indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection direction: NavigationDirection, step: NavigationStep, forKeyHandler keyHandler: SelectableCollectionKeyHandler) -> IndexPath? {
            switch (direction, step) {
            case (.up, .closest):
                // Select the first highlightable item before the current selection, or select the last highlightable
                // item if there is no current selection or if the current selection is the first highlightable item.
                if let indexPath = indexPath, let target = keyHandler.selectableIndexPathBeforeIndexPath(indexPath) {
                    return target
                } else {
                    return keyHandler.lastSelectableIndexPath
                }

            case (.up, .end):
                return keyHandler.firstSelectableIndexPath

            case (.down, .closest):
                // Select the first highlightable item after the current selection, or select the first highlightable
                // item if there is no current selection or if the current selection is the last highlightable item.
                if let oldSelection = indexPath, let target = keyHandler.selectableIndexPathAfterIndexPath(oldSelection) {
                    return target
                } else {
                    return keyHandler.firstSelectableIndexPath
                }

            case (.down, .end):
                return keyHandler.lastSelectableIndexPath

            case (.left, _), (.right, _):
                return nil
        }
    }
}

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
