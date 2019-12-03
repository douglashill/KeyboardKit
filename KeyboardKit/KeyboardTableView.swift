// Douglas Hill, December 2018
// Made for https://douglashill.co/reading-app/

import UIKit

/// A table view that allows navigation and selection using a hardware keyboard.
/// Only supports a single section.
public class KeyboardTableView: UITableView {
    // These properties may be set or overridden to provide discoverability titles for key commands.
    public var selectAboveDiscoverabilityTitle: String?
    public var selectBelowDiscoverabilityTitle: String?
    public var selectTopDiscoverabilityTitle: String?
    public var selectBottomDiscoverabilityTitle: String?
    public var clearSelectionDiscoverabilityTitle: String?
    public var activateSelectionDiscoverabilityTitle: String?

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        commands.append(UIKeyCommand(maybeTitle: selectAboveDiscoverabilityTitle, action: #selector(selectAbove), input: UIKeyCommand.inputUpArrow, modifierFlags: []))
        commands.append(UIKeyCommand(maybeTitle: selectBelowDiscoverabilityTitle, action: #selector(selectBelow), input: UIKeyCommand.inputDownArrow, modifierFlags: []))
        commands.append(UIKeyCommand(maybeTitle: selectTopDiscoverabilityTitle, action: #selector(selectTop), input: UIKeyCommand.inputUpArrow, modifierFlags: .command))
        commands.append(UIKeyCommand(maybeTitle: selectBottomDiscoverabilityTitle, action: #selector(selectBottom), input: UIKeyCommand.inputDownArrow, modifierFlags: .command))
        commands.append(UIKeyCommand(maybeTitle: clearSelectionDiscoverabilityTitle, action: #selector(clearSelection), input: UIKeyCommand.inputEscape, modifierFlags: []))

        commands.append(UIKeyCommand(maybeTitle: nil, action: #selector(activateSelection), input: " ", modifierFlags: []))
        commands.append(UIKeyCommand(maybeTitle: activateSelectionDiscoverabilityTitle, action: #selector(activateSelection), input: "\r", modifierFlags: []))

        return commands
    }

    @objc private func selectAbove() {
        if let oldSelectedIndexPath = indexPathForSelectedRow {
            selectRowAtIndex(oldSelectedIndexPath.row - 1)
        } else {
            selectBottom()
        }
    }

    @objc private func selectBelow() {
        if let oldSelectedIndexPath = indexPathForSelectedRow {
            selectRowAtIndex(oldSelectedIndexPath.row + 1)
        } else {
            selectTop()
        }
    }

    @objc private func selectTop() {
        selectRowAtIndex(0)
    }

    @objc private func selectBottom() {
        selectRowAtIndex(numberOfRows(inSection: 0) - 1)
    }

    /// Tries to select and scroll to the row at the given index in section 0.
    /// Does not require the index to be in bounds. Does nothing if out of bounds.
    private func selectRowAtIndex(_ rowIndex: Int) {
        guard rowIndex >= 0 && rowIndex < numberOfRows(inSection: 0) else {
            return
        }

        let indexPath = IndexPath(row: rowIndex, section: 0)

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

    @objc private func clearSelection() {
        selectRow(at: nil, animated: false, scrollPosition: .none)
    }

    @objc private func activateSelection() {
        guard let indexPathForSelectedRow = indexPathForSelectedRow else {
            return
        }
        delegate?.tableView?(self, didSelectRowAt: indexPathForSelectedRow)
    }
}
