// Douglas Hill, July 2020

import UIKit

/// A split view controller that supports navigating between columns using tab or arrows keys on a hardware keyboard.
///
/// This subclass only support iOS 14 split view controllers that are initialised with a `style` and have their
/// view controllers set as columns. Using the `.unspecified` style is not supported.
@available(iOS 14.0, *)
open class KeyboardSplitViewController: UISplitViewController {

    /// The column in the split view that currently has focus.
    ///
    /// If the user focuses a column using the keyboard and then hides
    /// that column by other means, no change occurs in KeyboardKit.
    private var storedFocusedColumn: Column? {
        didSet {
            precondition(storedFocusedColumn != nil, "Focused column should not be cleared.")
            show(storedFocusedColumn!)
            keyboardDelegate?.didChangeFocusedColumn(inSplitViewController: self)
        }
    }

    // TODO: One thing not supported currently is if the first responder is set to a column using anything other than the storedFocusedColumn.
    // This happens if you focus the sidebar, go into compact width (detail view gets focus) and then go back into expanded (focus is restored to sidebar, which feels a bit odd)

    public var focusedColumn: Column? {
        if isCollapsed {
            // Primary doesn’t quite make sense. Yes the focus in in the primary *navigation* controller but this may or may not be the primary VC that was set.
            // It might be better to say the focused column is nil.
            // And/or have API to get the focused VC rather than column.
            // That way I could see if the set primary VC is a navigation controller and find its parent navigation controller if necessary.
            return viewController(for: .compact) != nil ? .compact : .primary
        }

        switch displayMode {
        case .automatic:
            preconditionFailure("Read displayMode must not be automatic.")
        case .secondaryOnly:
            return .secondary
        case .oneBesideSecondary:
            switch (style, storedFocusedColumn) {
            case (.unspecified, _): preconditionFailure("Keyboard control is not supported in split views with an unspecified style.")
            case (.doubleColumn, .none): return .primary // Move focus to first column.
            case (.doubleColumn, .primary): return .primary
            case (.doubleColumn, .supplementary): preconditionFailure("There should not be a supplementary column with the double column style.")
            case (.tripleColumn, .none): return .supplementary // Move focus to first column.
            case (.tripleColumn, .primary): return .supplementary // Move focus to closest column.
            case (.tripleColumn, .supplementary): return .supplementary
            case (_, .secondary): return .secondary
            case (_, .compact): preconditionFailure("The compact column should never be stored as focused.")
            @unknown default: return nil
            }
        case .oneOverSecondary:
            switch style {
            case .doubleColumn: return .primary
            case .tripleColumn: return .supplementary
            case .unspecified: preconditionFailure("Keyboard control is not supported in split views with an unspecified style.")
            @unknown default: return nil
            }
        case .twoBesideSecondary:
            return storedFocusedColumn
        case .twoOverSecondary, .twoDisplaceSecondary:
            switch storedFocusedColumn {
            case .primary: return .primary
            case .supplementary: return .supplementary
            default: return .primary // Move focus to first column.
            }
        @unknown default:
            return nil
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

    // TODO: Localised titles

    private lazy var changeColumnFocusCommands: [UIKeyCommand] = [
        UIKeyCommand(.tab, action: #selector(moveFocusInLeadingDirectionWithWrapping), title: "Focus Next Column"),
        UIKeyCommand((.shift, .tab), action: #selector(moveFocusInTrailingDirectionWithWrapping), title: "Focus Previous Column"),
        UIKeyCommand(.rightArrow, action: #selector(moveFocusRight)),
        UIKeyCommand(.leftArrow, action: #selector(moveFocusLeft)),
    ]

    private lazy var dismissTemporaryColumnKeyCommands: [UIKeyCommand] = [
        UIKeyCommand(.escape, action: #selector(dismissTemporaryColumn)),
    ]

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if presentedViewController == nil, style == .doubleColumn || style == .tripleColumn, isCollapsed == false, UIResponder.isTextInputActive == false {
            commands += changeColumnFocusCommands

            switch displayMode {
            case .automatic:
                preconditionFailure()
            case .oneOverSecondary, .twoOverSecondary, .twoDisplaceSecondary:
                commands += dismissTemporaryColumnKeyCommands
            case .secondaryOnly, .oneBesideSecondary, .twoBesideSecondary: fallthrough @unknown default:
                break
            }
        }

        return commands
    }

    // TODO: Don’t steal arrow keys when can’t go further in direction.

    // Generally this is a problem if there are nested split views since the action might end up handled by the wrong object.

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        // To avoid duplicating the conditions in keyCommands it seems best to just
        // always provide key commands and rely on canPerformAction to filter things out.

//        if action == #selector(dismissTemporaryColumn) {
//
//        }

        return super.canPerformAction(action, withSender: sender)
    }

    @objc private func moveFocusInLeadingDirectionWithWrapping(_ sender: UIKeyCommand) {
        moveFocusInLeadingDirection(shouldWrap: true)
    }

    @objc private func moveFocusInTrailingDirectionWithWrapping(_ sender: UIKeyCommand) {
        moveFocusInTrailingDirection(shouldWrap: true)
    }

    @objc private func moveFocusRight(_ sender: UIKeyCommand) {
        switch view.effectiveUserInterfaceLayoutDirection {
        case .leftToRight: moveFocusInLeadingDirection(shouldWrap: false)
        case .rightToLeft: moveFocusInTrailingDirection(shouldWrap: false)
        @unknown default: break
        }
    }

    @objc private func moveFocusLeft(_ sender: UIKeyCommand) {
        switch view.effectiveUserInterfaceLayoutDirection {
        case .leftToRight: moveFocusInTrailingDirection(shouldWrap: false)
        case .rightToLeft: moveFocusInLeadingDirection(shouldWrap: false)
        @unknown default: break
        }
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
            storedFocusedColumn = .primary
        case .secondary:
            if shouldWrap {
                storedFocusedColumn = .primary
            }
        case .primary:
            switch style {
            case .doubleColumn:
                storedFocusedColumn = .secondary
            case .tripleColumn:
                storedFocusedColumn = .supplementary
            case .unspecified: fallthrough @unknown default:
                preconditionFailure()
            }
        case .supplementary:
            precondition(style == .tripleColumn)
            storedFocusedColumn = .secondary
        case .compact:
            preconditionFailure("Moving focus should not be enabled when compact.")
        @unknown default:
            break
        }
    }

    private func moveFocusTowardsPrimary(shouldWrap: Bool) {
        switch focusedColumn {
        case .none:
            storedFocusedColumn = .secondary
        case .primary:
            if shouldWrap {
                storedFocusedColumn = .secondary
            }
        case .secondary:
            switch style {
            case .doubleColumn:
                storedFocusedColumn = .primary
            case .tripleColumn:
                storedFocusedColumn = .supplementary
            case .unspecified: fallthrough @unknown default:
                preconditionFailure()
            }
        case .supplementary:
            precondition(style == .tripleColumn)
            storedFocusedColumn = .primary
        case .compact:
            preconditionFailure("Moving focus should not be enabled when compact.")
        @unknown default:
            break
        }
    }

    @objc private func dismissTemporaryColumn(_ sender: UIKeyCommand) {
        switch displayMode {
        case .oneOverSecondary, .twoOverSecondary:
            // Dismiss one or two overlaid columns. This matches what tapping the dimmed area above the secondary does.
            storedFocusedColumn = .secondary
        case .twoDisplaceSecondary:
            // Either the primary or supplementary must have been focused and in either case focusing the supplementary makes sense.
            // TODO: Does this two step sequence of calls work?
            // I need to make a modal example that shows a 3 column split view.
            hide(.primary)
            storedFocusedColumn = .supplementary
        case .automatic, .secondaryOnly, .oneBesideSecondary, .twoBesideSecondary: fallthrough @unknown default:
            preconditionFailure("Can’t dismiss temporary column with no suitable column. The key command should not have been supplied in this case.")
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
