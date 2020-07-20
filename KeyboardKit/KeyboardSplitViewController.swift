// Douglas Hill, July 2020

import UIKit

/// A split view controller that supports navigating between columns using tab or arrows keys on a hardware keyboard.
///
/// This subclass only support iOS 14 split view controllers that are initialised with a `style` and have their
/// view controllers set as columns. Using the `.unspecified` style is not supported.
@available(iOS 14.0, *)
public class KeyboardSplitViewController: UISplitViewController {

    private var focusedColumn: Column?

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
                UIKeyCommand(.tab, action: #selector(moveFocusInLeadingDirection), title: "Focus Next Column"),
                UIKeyCommand((.shift, .tab), action: #selector(moveFocusInTrailingDirection), title: "Focus Previous Column"),
                UIKeyCommand(leadingArrow, action: #selector(moveFocusInLeadingDirection)),
                UIKeyCommand(trailingArrow, action: #selector(moveFocusInTrailingDirection)),
            ]
        }

        // LtR leading edge primary
        // Tab 1 to 2
        // --> 1 to 2

        // LtR trailing edge primary (inspector)
        // Tab 2 to 1
        // --> 2 to 1

        // RtL leading edge primary
        // Tab 1 to 2
        // --> 2 to 1

        // RtL trailing edge primary (inspector)
        // Tab 2 to 1
        // --> 1 to 2

        return commands
    }

    /*
     When you factor in everything there are a bazillion cases.

     - [ ] collapsing
     - [ ] triple column style
     - [ ] display mode
     - [ ] split behaviour
     - [ ] primary edge
     - [ ] UI layout direction
     */

    @objc private func moveFocusInLeadingDirection(_ sender: UIKeyCommand) {
        switch primaryEdge {
        case .leading:
            moveFocusTowardsSecondary()
        case .trailing:
            moveFocusTowardsPrimary()
        @unknown default:
            break
        }
    }

    @objc private func moveFocusInTrailingDirection(_ sender: UIKeyCommand) {
        switch primaryEdge {
        case .leading:
            moveFocusTowardsPrimary()
        case .trailing:
            moveFocusTowardsSecondary()
        @unknown default:
            break
        }
    }

    private func moveFocusTowardsSecondary() {
        switch focusedColumn {
        case .none, .some(.secondary):
            focusedColumn = .primary
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

    private func moveFocusTowardsPrimary() {
        switch focusedColumn {
        case .none, .some(.primary):
            focusedColumn = .secondary
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
