// Douglas Hill, July 2020

import UIKit

/// A split view controller that supports navigating between columns using tab or arrows keys on a hardware keyboard.
///
/// This subclass only support iOS 14 split view controllers that are initialised with a `style` and have their
/// view controllers set as columns. Using the `.unspecified` style is not supported.
@available(iOS 14.0, *)
public class KeyboardSplitViewController: UISplitViewController {

    /// The column in the split view that currently has focus.
    ///
    /// If the user focuses a column using the keyboard and then hides
    /// that column by other means, no change occurs in KeyboardKit.
    public private(set) var focusedColumn: Column? {
        didSet {
            precondition(focusedColumn != nil, "Focused column should not be cleared.")
            show(focusedColumn!)
            keyboardDelegate?.didChangeFocusedColumn(inSplitViewController: self)
        }
    }

    private var keyboardDelegate: KeyboardSplitViewControllerDelegate? {
        delegate as? KeyboardSplitViewControllerDelegate
    }

    // TODO: Somehow update the 1R when the focused column changes.
    // Probably by letting the app observe the change and the app decides how to update the 1R.

    public override var canBecomeFirstResponder: Bool {
        true
    }

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if presentedViewController == nil, style == .doubleColumn || style == .tripleColumn, isCollapsed == false, UIResponder.isTextInputActive == false {
            let isRtL = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
            let leadingArrow: String = isRtL ? .leftArrow : .rightArrow
            let trailingArrow: String = isRtL ? .rightArrow : .leftArrow

            // TODO: Localised titles

            commands += [
                UIKeyCommand(.tab, action: #selector(moveFocusInLeadingDirectionWithWrapping), title: "Focus Next Column"),
                UIKeyCommand((.shift, .tab), action: #selector(moveFocusInTrailingDirectionWithWrapping), title: "Focus Previous Column"),
                UIKeyCommand(leadingArrow, action: #selector(moveFocusInLeadingDirectionWithoutWrapping)),
                UIKeyCommand(trailingArrow, action: #selector(moveFocusInTrailingDirectionWithoutWrapping)),
            ]
        }

        return commands
    }

    /*
     When you factor in everything there are a bazillion cases.

     - [x] collapsing
     - [x] triple column style
     - [-] display mode
     - [-] split behaviour
     - [x] primary edge
     - [x] UI layout direction
     */

    @objc private func moveFocusInLeadingDirectionWithWrapping(_ sender: UIKeyCommand) {
        moveFocusInLeadingDirection(shouldWrap: true)
    }

    @objc private func moveFocusInTrailingDirectionWithWrapping(_ sender: UIKeyCommand) {
        moveFocusInTrailingDirection(shouldWrap: true)
    }

    @objc private func moveFocusInLeadingDirectionWithoutWrapping(_ sender: UIKeyCommand) {
        moveFocusInLeadingDirection(shouldWrap: false)
    }

    @objc private func moveFocusInTrailingDirectionWithoutWrapping(_ sender: UIKeyCommand) {
        moveFocusInTrailingDirection(shouldWrap: false)
    }

    private func moveFocusInLeadingDirection(shouldWrap: Bool) {
        switch primaryEdge {
        case .leading:
            moveFocusTowardsSecondary(shouldWrap: shouldWrap)
        case .trailing:
            moveFocusTowardsPrimary(shouldWrap: shouldWrap)
        @unknown default:
            break
        }
    }

    private func moveFocusInTrailingDirection(shouldWrap: Bool) {
        switch primaryEdge {
        case .leading:
            moveFocusTowardsPrimary(shouldWrap: shouldWrap)
        case .trailing:
            moveFocusTowardsSecondary(shouldWrap: shouldWrap)
        @unknown default:
            break
        }
    }

    private func moveFocusTowardsSecondary(shouldWrap: Bool) {

        // TODO: Validate the column we thought was focused could still be focused since it might have been hidden or overlaid.

        switch focusedColumn {
        case .none:
            focusedColumn = .primary
        case .some(.secondary):
            if shouldWrap {
                focusedColumn = .primary
            }
        case .some(.primary):
            switch style {
            case .doubleColumn:
                focusedColumn = .secondary
            case .tripleColumn:
                focusedColumn = .supplementary
            case .unspecified: fallthrough @unknown default:
                preconditionFailure()
            }
        case .some(.supplementary):
            precondition(style == .tripleColumn)
            focusedColumn = .secondary
        case .some(.compact):
            preconditionFailure("Compact column should never be focused.")
        @unknown default:
            break
        }
    }

    private func moveFocusTowardsPrimary(shouldWrap: Bool) {
        switch focusedColumn {
        case .none:
            focusedColumn = .secondary
        case .some(.primary):
            if shouldWrap {
                focusedColumn = .secondary
            }
        case .some(.secondary):
            switch style {
            case .doubleColumn:
                focusedColumn = .primary
            case .tripleColumn:
                focusedColumn = .supplementary
            case .unspecified: fallthrough @unknown default:
                preconditionFailure()
            }
        case .some(.supplementary):
            precondition(style == .tripleColumn)
            focusedColumn = .primary
        case .some(.compact):
            preconditionFailure("Compact column should never be focused.")
        @unknown default:
            break
        }
    }
}

/// The delegate of a `UISplitViewController` can conform to `KeyboardSplitViewControllerDelegate` in addition
/// to `UISplitViewControllerDelegate` to receive a callback when the focused tab changes via keyboard input.
@available(iOS 14.0, *)
public protocol KeyboardSplitViewControllerDelegate: UISplitViewControllerDelegate {
    /// Called after the user uses keyboard input to change the focused column.
    ///
    /// This is typically used to update the first responder to a view within the new focused column.
    ///
    /// This method will not be called when the focused column is hidden because KeyboardKit
    /// does not have enough contexts to handle that case. Your app should handle this.
    func didChangeFocusedColumn(inSplitViewController splitViewController: KeyboardSplitViewController)
}
