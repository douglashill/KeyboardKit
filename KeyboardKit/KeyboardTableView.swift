// Douglas Hill, December 2018
// Made for https://douglashill.co/reading-app/

import UIKit

/// A table view that supports navigation and selection using a hardware keyboard.
public class KeyboardTableView: UITableView, ResponderChainInjection {
    // These properties may be set or overridden to provide discoverability titles for key commands.
    public var selectAboveDiscoverabilityTitle: String?
    public var selectBelowDiscoverabilityTitle: String?
    public var selectTopDiscoverabilityTitle: String?
    public var selectBottomDiscoverabilityTitle: String?
    public var clearSelectionDiscoverabilityTitle: String?
    public var activateSelectionDiscoverabilityTitle: String?

    private lazy var scrollViewKeyHandler = ScrollViewKeyHandler(scrollView: self)

    public override var canBecomeFirstResponder: Bool {
        true
    }

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        commands += [
            UIKeyCommand(UIKeyCommand.inputUpArrow, action: #selector(selectAbove), title: selectAboveDiscoverabilityTitle),
            UIKeyCommand(UIKeyCommand.inputDownArrow, action: #selector(selectBelow), title: selectBelowDiscoverabilityTitle),
            UIKeyCommand((.alternate, UIKeyCommand.inputUpArrow), action: #selector(selectTop), title: selectTopDiscoverabilityTitle),
            UIKeyCommand((.alternate, UIKeyCommand.inputDownArrow), action: #selector(selectBottom), title: selectBottomDiscoverabilityTitle),

            UIKeyCommand(UIKeyCommand.inputEscape, action: #selector(clearSelection), title: clearSelectionDiscoverabilityTitle),
            UIKeyCommand(" ", action: #selector(activateSelection)),
            UIKeyCommand("\r", action: #selector(activateSelection), title: activateSelectionDiscoverabilityTitle),
        ]

        commands += scrollViewKeyHandler.pageUpDownHomeEndScrollingCommands

        return commands
    }

    // MARK: - Arrow key selection

    /// Selects the first highlightable row above the current selection, or selects the bottom highlightable row if there is no
    /// current selection or if the current selection is the top highlightable row. Scrolls so new selected row is visible.
    @objc private func selectAbove() {
        if let oldSelection = indexPathForSelectedRow, let target = selectableIndexPathBeforeIndexPath(oldSelection) {
            selectAndShowRowAtIndexPath(target)
        } else {
            selectBottom()
        }
    }

    /// Selects the first highlightable row below the current selection, or selects the top highlightable row if there is no
    /// current selection or if the current selection is the bottom highlightable row. Scrolls so new selected row is visible.
    @objc private func selectBelow() {
        if let oldSelection = indexPathForSelectedRow, let target = selectableIndexPathAfterIndexPath(oldSelection) {
            selectAndShowRowAtIndexPath(target)
        } else {
            selectTop()
        }
    }

    /// Selects the top highlightable row if there is one. Scrolls so new selected row is visible.
    @objc private func selectTop() {
        if let indexPath = firstSelectableIndexPath {
            selectAndShowRowAtIndexPath(indexPath)
        }
    }

    /// Selects the bottom highlightable row if there is one. Scrolls so new selected row is visible.
    @objc private func selectBottom() {
        if let indexPath = lastSelectableIndexPath {
            selectAndShowRowAtIndexPath(indexPath)
        }
    }

    private var delegateRespondsToShouldHighlightRow: Bool {
        delegate?.responds(to: #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:))) ?? false
    }

    private func uncheckedShouldHighlightRowAtIndexPath(_ indexPath: IndexPath) -> Bool {
        delegate!.tableView!(self, shouldHighlightRowAt: indexPath)
    }

    private func checkIndexPathIsInValidRange(_ indexPath: IndexPath) {
        precondition(indexPath.section >= 0, "Index path is out-of-bounds.")
        precondition(indexPath.section < numberOfSections, "Index path is out-of-bounds.")
        precondition(indexPath.row >= 0, "Index path is out-of-bounds.")
        precondition(indexPath.row < numberOfRows(inSection: indexPath.section), "Index path is out-of-bounds.")
    }

    /// Returns the index path to select before (above) a given index path or nil if there is no such index path.
    private func selectableIndexPathBeforeIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        checkIndexPathIsInValidRange(indexPath)
        let responds = delegateRespondsToShouldHighlightRow

        var section = indexPath.section
        while section >= 0 {
            let numberOfRows_ = numberOfRows(inSection: section)
            // For the first section we look in, we want to just check the row above in the same section.
            // When the section changes, we need to start from the last row.
            var row = section == indexPath.section ? indexPath.row - 1 : numberOfRows_ - 1

            while row >= 0 {
                let targetIndexPath = IndexPath(row: row, section: section)
                if responds == false || uncheckedShouldHighlightRowAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                row -= 1
            }

            section -= 1
        }

        return nil
    }

    /// Returns the index path to select after (below) a given index path or nil if there is no such index path.
    private func selectableIndexPathAfterIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        checkIndexPathIsInValidRange(indexPath)
        let responds = delegateRespondsToShouldHighlightRow

        var section = indexPath.section
        while section < numberOfSections {
            let numberOfRows_ = numberOfRows(inSection: section)
            // For the first section we look in, we want to just check the row below in the same section.
            // When the section changes, we need to start from the first row.
            var row = section == indexPath.section ? indexPath.row + 1 : 0

            while row < numberOfRows_ {
                let targetIndexPath = IndexPath(row: row, section: section)
                if responds == false || uncheckedShouldHighlightRowAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                row += 1
            }

            section += 1
        }

        return nil
    }

    private var firstSelectableIndexPath: IndexPath? {
        let responds = delegateRespondsToShouldHighlightRow

        // Select the first highlightable row.
        var section = 0
        while section < numberOfSections {
            let numberOfRows_ = numberOfRows(inSection: section)

            var row = 0
            while row < numberOfRows_ {
                let targetIndexPath = IndexPath(row: row, section: section)
                if responds == false || uncheckedShouldHighlightRowAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                row += 1
            }

            section += 1
        }

        return nil
    }

    private var lastSelectableIndexPath: IndexPath? {
        let responds = delegateRespondsToShouldHighlightRow

        // Select the last highlightable row.
        var section = numberOfSections - 1
        while section >= 0 {
            let numberOfRows_ = numberOfRows(inSection: section)

            var row = numberOfRows_ - 1
            while row >= 0 {
                let targetIndexPath = IndexPath(row: row, section:section)
                if responds == false || uncheckedShouldHighlightRowAtIndexPath(targetIndexPath) {
                    return targetIndexPath
                }

                row -= 1
            }

            section -= 1
        }

        return nil
    }

    /// Selects the row at the given index path and scrolls if needed so that row is visible.
    /// The index path must be in-bounds or an assertion will fail.
    private func selectAndShowRowAtIndexPath(_ indexPath: IndexPath) {
        checkIndexPathIsInValidRange(indexPath)

        switch cellVisibility(atIndexPath: indexPath) {
        case .fullyVisible:
            selectRow(at: indexPath, animated: false, scrollPosition: .none)
        case .notFullyVisible(let scrollPosition):
            // Looks better and feel more responsive if the selection updates without animation.
            selectRow(at: indexPath, animated: false, scrollPosition: .none)
            scrollToRow(at: indexPath, at: scrollPosition, animated: true)
            flashScrollIndicators()
        }
    }

    /// Whether a row is fully visible, or if not if it’s above or below the viewport.
    private enum CellVisibility { case fullyVisible; case notFullyVisible(ScrollPosition); }

    /// Whether the given row is fully visible, or if not if it’s above or below the viewport.
    private func cellVisibility(atIndexPath indexPath: IndexPath) -> CellVisibility {
        let rowRect = rectForRow(at: indexPath)
        if bounds.inset(by: adjustedContentInset).contains(rowRect) {
            return .fullyVisible
        }

        let position: ScrollPosition = rowRect.midY < bounds.midY ? .top : .bottom
        return .notFullyVisible(position)
    }

    // MARK: - Using the selection

    @objc private func clearSelection() {
        selectRow(at: nil, animated: false, scrollPosition: .none)
    }

    @objc private func activateSelection() {
        guard let indexPathForSelectedRow = indexPathForSelectedRow else {
            return
        }
        delegate?.tableView?(self, didSelectRowAt: indexPathForSelectedRow)
    }

    // MARK: - Responder chain

    public override var next: UIResponder? {
        scrollViewKeyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        super.next
    }
}
