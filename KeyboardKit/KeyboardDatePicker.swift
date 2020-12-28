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

        let adjustment = adjustmentForKeyCommand(keyCommand)
        guard var adjustedDate = calendar.date(byAdding: adjustment.component, value: adjustment.valueChange, to: date) else {
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
        let adjustment = adjustmentForKeyCommand(sender)
        if let adjustedDate = calendar.date(byAdding: adjustment.component, value: adjustment.valueChange, to: date) {
            setDate(adjustedDate, animated: true)
        }
    }

    private func adjustmentForKeyCommand(_ keyCommand: UIKeyCommand) -> Adjustment {
        precondition(keyCommand.action == #selector(kdb_adjustDate))

        var isRtL: Bool { effectiveUserInterfaceLayoutDirection == .rightToLeft }

        switch keyCommand.input! {
        case .upArrow: return .decrementWeek
        case .downArrow: return .incrementWeek
        case .leftArrow: return isRtL ? .incrementDay : .decrementDay
        case .rightArrow: return isRtL ? .decrementDay : .incrementDay
        default: preconditionFailure("Unexpected input on key command for adjusting date.")
        }
    }
}

// MARK: -

private enum Adjustment {
    case incrementDay
    case decrementDay
    case incrementWeek
    case decrementWeek
    case incrementMonth
    case decrementMonth
    case incrementYear
    case decrementYear

    var valueChange: Int {
        switch self {
        case .incrementDay, .incrementWeek, .incrementMonth, .incrementYear:
            return +1
        case .decrementDay, .decrementWeek, .decrementMonth, .decrementYear:
            return -1
        }
    }

    var component: Calendar.Component {
        switch self {
        case .incrementDay, .decrementDay:
            return .day
        case .incrementWeek, .decrementWeek:
            return .weekOfMonth
        case .incrementMonth, .decrementMonth:
            return .month
        case .incrementYear, .decrementYear:
            return .year
        }
    }
}
