// Douglas Hill, December 2020

import UIKit

/// A date picker that supports using a hardware keyboard arrow keys to change the date.
///
/// Only changing the day in an inline date or date & time picker is supported.
@available(iOS 14.0, *)
open class KeyboardDatePicker: UIDatePicker {
    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var adjustmentCommands: [UIKeyCommand] = [
        UIKeyCommand(.leftArrow, action: #selector(kdb_adjustDate)),
        UIKeyCommand(.rightArrow, action: #selector(kdb_adjustDate)),
        UIKeyCommand(.upArrow, action: #selector(kdb_adjustDate)),
        UIKeyCommand(.downArrow, action: #selector(kdb_adjustDate)),
        UIKeyCommand((.alternate, .leftArrow), action: #selector(kdb_adjustDate)),
        UIKeyCommand((.alternate, .rightArrow), action: #selector(kdb_adjustDate)),
        UIKeyCommand((.alternate, .upArrow), action: #selector(kdb_adjustDate)),
        UIKeyCommand((.alternate, .downArrow), action: #selector(kdb_adjustDate)),
    ]

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        commands.append(contentsOf: adjustmentCommands)

        return commands
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard action == #selector(kdb_adjustDate), let keyCommand = sender as? UIKeyCommand else {
            return super.canPerformAction(action, withSender: sender)
        }

        let (value, component) = adjustmentForKeyCommand(keyCommand)
        guard var adjustedDate = calendar.date(byAdding: component, value: value, to: date) else {
            return false
        }

        if let minimumDate = self.minimumDate {
            adjustedDate = max(adjustedDate, minimumDate)
        }
        if let maximumDate = self.maximumDate {
            adjustedDate = min(adjustedDate, maximumDate)
        }

        return adjustedDate != date
    }

    @objc private func kdb_adjustDate(_ sender: UIKeyCommand) {
        let (value, component) = adjustmentForKeyCommand(sender)
        if let adjustedDate = calendar.date(byAdding: component, value: value, to: date) {
            setDate(adjustedDate, animated: true)
        }
    }

    private func adjustmentForKeyCommand(_ keyCommand: UIKeyCommand) -> (valueChange: Int, component: Calendar.Component) {
        precondition(keyCommand.action == #selector(kdb_adjustDate))

        var isRtL: Bool { effectiveUserInterfaceLayoutDirection == .rightToLeft }

        if keyCommand.modifierFlags.contains(.alternate) {
            switch keyCommand.input! {
            case .upArrow:    return (-1, .year)
            case .downArrow:  return (+1, .year)
            case .leftArrow:  return (isRtL ? +1 : -1, .month)
            case .rightArrow: return (isRtL ? -1 : +1, .month)
            default: preconditionFailure("Unexpected input on key command for adjusting date.")
            }
        } else {
            switch keyCommand.input! {
            case .upArrow:    return (-1, .weekOfMonth)
            case .downArrow:  return (+1, .weekOfMonth)
            case .leftArrow:  return (isRtL ? +1 : -1, .day)
            case .rightArrow: return (isRtL ? -1 : +1, .day)
            default: preconditionFailure("Unexpected input on key command for adjusting date.")
            }
        }
    }
}
