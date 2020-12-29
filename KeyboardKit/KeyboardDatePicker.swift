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
        UIKeyCommand((.command, "t"), action: #selector(kdb_adjustDate)),
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

        guard let targetDate = targetDateForKeyCommand(keyCommand) else {
            return false
        }

        if let minimumDate = self.minimumDate, targetDate < minimumDate {
            return false
        }
        if let maximumDate = self.maximumDate, targetDate > maximumDate {
            return false
        }

        return true
    }

    @objc private func kdb_adjustDate(_ sender: UIKeyCommand) {
        if let targetDate = targetDateForKeyCommand(sender) {
            setDate(targetDate, animated: true)
        }
    }

    private func targetDateForKeyCommand(_ keyCommand: UIKeyCommand) -> Date? {
        precondition(keyCommand.action == #selector(kdb_adjustDate))

        if keyCommand.modifierFlags == .command && keyCommand.input == "t" {
            return Date()
        }

        var isRtL: Bool { effectiveUserInterfaceLayoutDirection == .rightToLeft }

        let value: Int
        let component: Calendar.Component

        if keyCommand.modifierFlags == .alternate {
            switch keyCommand.input! {
            case .upArrow:    value = -1;              component = .year
            case .downArrow:  value = +1;              component = .year
            case .leftArrow:  value = isRtL ? +1 : -1; component = .month
            case .rightArrow: value = isRtL ? -1 : +1; component = .month
            default: preconditionFailure("Unexpected input on key command for adjusting date.")
            }
        } else {
            switch keyCommand.input! {
            case .upArrow:    value = -1;              component = .weekOfMonth
            case .downArrow:  value = +1;              component = .weekOfMonth
            case .leftArrow:  value = isRtL ? +1 : -1; component = .day
            case .rightArrow: value = isRtL ? -1 : +1; component = .day
            default: preconditionFailure("Unexpected input on key command for adjusting date.")
            }
        }

        return calendar.date(byAdding: component, value: value, to: date)
    }
}
