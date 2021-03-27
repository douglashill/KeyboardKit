// Douglas Hill, December 2020

import UIKit

/// A date picker that supports using hardware keyboard arrow keys to change the date.
///
/// The only supported style and mode combinations are:
///
/// - `UIDatePickerStyle.inline` and `UIDatePicker.Mode.date`
/// - `UIDatePickerStyle.inline` and `UIDatePicker.Mode.dateAndTime`
///
/// Key commands will not be available with any other style and mode combinations
/// such as using the `.wheels` style.
///
/// In these supported configurations, users can use the following key inputs when
/// the date picker is the first responder:
///
/// - Arrow keys to spatially change the selected day.
/// - Option + left/right arrow to change the month.
/// - Option + up/down arrow to change the year.
/// - Command + T to jump to today.
///
/// Actions that would set the date outside the range of `minimumDate` to `maximumDate`
/// will not be handled, leaving these key inputs able to be handled by objects
/// further along the responder chain.
///
/// All calendars with identifiers provided by Foundation are supported, including
/// Gregorian, Buddhist, Chinese etc. Inputs are flipped for right-to-left layouts.
@available(iOS 14.0, *)
open class KeyboardDatePicker: UIDatePicker {
    open override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var adjustmentCommands: [UIKeyCommand] = [
        UIKeyCommand(.leftArrow, action: #selector(kbd_adjustDate)),
        UIKeyCommand(.rightArrow, action: #selector(kbd_adjustDate)),
        UIKeyCommand(.upArrow, action: #selector(kbd_adjustDate)),
        UIKeyCommand(.downArrow, action: #selector(kbd_adjustDate)),
        UIKeyCommand((.alternate, .leftArrow), action: #selector(kbd_adjustDate)),
        UIKeyCommand((.alternate, .rightArrow), action: #selector(kbd_adjustDate)),
        UIKeyCommand((.alternate, .upArrow), action: #selector(kbd_adjustDate)),
        UIKeyCommand((.alternate, .downArrow), action: #selector(kbd_adjustDate)),
        UIKeyCommand((.command, "t"), action: #selector(kbd_adjustDate)),
    ]

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if isInSupportedStyleAndMode {
            commands += adjustmentCommands
        }

        return commands
    }

    private var isInSupportedStyleAndMode: Bool {
        switch (datePickerStyle, datePickerMode) {
        case (.inline, .date), (.inline, .dateAndTime):
            return true
        case (.inline, .time), (.inline, .countDownTimer), (.wheels, _), (.compact, _), (.automatic, _): fallthrough @unknown default:
            return false
        }
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard action == #selector(kbd_adjustDate), let keyCommand = sender as? UIKeyCommand else {
            return super.canPerformAction(action, withSender: sender)
        }

        guard isInSupportedStyleAndMode, let targetDate = targetDateForKeyCommand(keyCommand) else {
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

    @objc private func kbd_adjustDate(_ sender: UIKeyCommand) {
        if let targetDate = targetDateForKeyCommand(sender) {
            setDate(targetDate, animated: true)
        }
    }

    private func targetDateForKeyCommand(_ keyCommand: UIKeyCommand) -> Date? {
        precondition(keyCommand.action == #selector(kbd_adjustDate))

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

    open override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        // Disable UIKit focus system because otherwise on Mac Catalyst you end up with a focus ring when
        // pressing cmd + arrows, which does not provide as good a user experience as what we do here.
        // This was tested building with the iOS 14.4 SDK (Xcode 12.4) and running on macOS 11.2.3.
        false
    }
}
