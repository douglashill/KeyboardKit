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

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if canGoUp {
            commands.append(UIKeyCommand(.upArrow, action: #selector(kdb_goUp)))
        }
        if canGoDown {
            commands.append(UIKeyCommand(.downArrow, action: #selector(kdb_goDown)))
        }
        if canGoLeft {
            commands.append(UIKeyCommand(.leftArrow, action: #selector(kdb_goLeft)))
        }
        if canGoRight {
            commands.append(UIKeyCommand(.rightArrow, action: #selector(kdb_goRight)))
        }

        return commands
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(kdb_goUp): return canGoUp
        case #selector(kdb_goDown): return canGoDown
        case #selector(kdb_goLeft): return canGoLeft
        case #selector(kdb_goRight): return canGoRight
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }

    // MARK: - Change day

    private var canGoLeft: Bool {
        canAdjustDate(byAdding: effectiveUserInterfaceLayoutDirection == .rightToLeft ? +1 : -1, to: .day)
    }

    @objc private func kdb_goLeft(_ sender: AnyObject?) {
        adjustDate(byAdding: effectiveUserInterfaceLayoutDirection == .rightToLeft ? +1 : -1, to: .day)
    }

    private var canGoRight: Bool {
        canAdjustDate(byAdding: effectiveUserInterfaceLayoutDirection == .rightToLeft ? -1 : +1, to: .day)
    }

    @objc private func kdb_goRight(_ sender: AnyObject?) {
        adjustDate(byAdding: effectiveUserInterfaceLayoutDirection == .rightToLeft ? -1 : +1, to: .day)
    }

    // MARK: - Change week

    private var canGoUp: Bool {
        canAdjustDate(byAdding: -1, to: .weekOfMonth)
    }

    @objc private func kdb_goUp(_ sender: AnyObject?) {
        adjustDate(byAdding: -1, to: .weekOfMonth)
    }

    private var canGoDown: Bool {
        canAdjustDate(byAdding: +1, to: .weekOfMonth)
    }

    @objc private func kdb_goDown(_ sender: AnyObject?) {
        adjustDate(byAdding: +1, to: .weekOfMonth)
    }

    // MARK: -

    private func canAdjustDate(byAdding value: Int, to component: Calendar.Component) -> Bool {
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

    private func adjustDate(byAdding value: Int, to component: Calendar.Component) {
        if let adjustedDate = calendar.date(byAdding: component, value: value, to: date) {
            setDate(adjustedDate, animated: true)
        }
    }
}
