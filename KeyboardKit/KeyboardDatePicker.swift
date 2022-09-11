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
/// the date picker is focused or is the first responder:
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
///
/// In a supported configurations, `KeyboardDatePicker` will be focusable as part of the
/// tab loop. Since it uses arrow key inputs, it gives itself a unique focus group
/// identifier. The `focusEffect` is set to a rounded `UIFocusHaloEffect` by default.
@available(iOS 14.0, *)
open class KeyboardDatePicker: UIDatePicker {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        // Create a unique focus group because if the date picker is focusable then arrow keys should change the selected date within the picker.
        focusGroupIdentifier = "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())>"
    }

    open override var canBecomeFirstResponder: Bool {
        true
    }

    open override var canBecomeFocused: Bool {
        isInSupportedStyleAndMode ? true : super.canBecomeFocused
    }

    /// Backing store for `customFocusEffect` because stored properties can’t have availability conditions.
    private var customFocusEffectStorage: NSObject??

    /// Backing property for if `focusEffect` is changed from its default.
    ///
    /// This is deliberately double optional:
    /// - `.none` means the property hasn’t been set so use the default value.
    /// - `.some(.none)` means the property has been explicitly set to nil so don’t show a focus effect.
    @available(iOS 15.0, *)
    private var customFocusEffect: UIFocusEffect?? {
        get {
            customFocusEffectStorage as! UIFocusEffect??
        }
        set {
            customFocusEffectStorage = newValue
        }
    }

    /// The focus effect on `KeyboardDatePicker` defaults to a halo with rounded corners that tracks the view bounds.
    @available(iOS 15.0, *)
    open override var focusEffect: UIFocusEffect? {
        // It’s easiest to have this be a computed getter so it can track the bounds.
        // The empty initialiser does track the bounds but has no corner radius.
        get {
            customFocusEffect ?? UIFocusHaloEffect(roundedRect: bounds, cornerRadius: 8, curve: .continuous)
        }
        set {
            customFocusEffect = .some(newValue)
        }
    }

    private lazy var adjustmentCommands: [UIKeyCommand] = [
        // Want priority over focus system because KeyboardDatePicker defines its own focus group so arrow keys wouldn’t do anything in the focus system anyway.
        UIKeyCommand(.leftArrow,                action: #selector(kbd_adjustDate), wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false),
        UIKeyCommand(.rightArrow,               action: #selector(kbd_adjustDate), wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false),
        UIKeyCommand(.upArrow,                  action: #selector(kbd_adjustDate), wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false),
        UIKeyCommand(.downArrow,                action: #selector(kbd_adjustDate), wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false),
        UIKeyCommand((.alternate, .leftArrow),  action: #selector(kbd_adjustDate), wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false),
        UIKeyCommand((.alternate, .rightArrow), action: #selector(kbd_adjustDate), wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false),
        UIKeyCommand((.alternate, .upArrow),    action: #selector(kbd_adjustDate), wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false),
        UIKeyCommand((.alternate, .downArrow),  action: #selector(kbd_adjustDate), wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false),
        UIKeyCommand((.command, "t"),           action: #selector(kbd_adjustDate)),
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
            // We want the scrolling animation to be less disorienting, but don’t want any animation if no scrolling would occur so it feels fast.
            // iOS 15 and earlier didn’t animate anything except scrolling so this logic isn’t actually needed on those older versions.
            let eraYearMonth: Set<Calendar.Component> = [.era, .year, .month]
            let isAnimated = calendar.dateComponents(eraYearMonth, from: date) != calendar.dateComponents(eraYearMonth, from: targetDate)
            setDate(targetDate, animated: isAnimated)
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

    // There is a problem on Big Sur where if you press tab while focused on the date picker
    // the focus moves to nothing visible (?) but first responder stays on the date picker.
    // This leads to an incorrect extra focus ring being visible on the date picker
    // Overriding shouldUpdateFocusInContext to return false can break the focus system
    // and this is not a problem on iOS 15 on iPad, so this problem is not being addressed.
}
