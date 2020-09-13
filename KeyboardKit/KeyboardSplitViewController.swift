// Douglas Hill, July 2020

import UIKit

/// A split view controller that supports navigating between columns using tab or arrows keys on a hardware keyboard.
///
/// This subclass only support iOS 14 split view controllers that are initialised with a `style` and have their
/// view controllers set as columns. Using the `.unspecified` style is not supported.
///
/// This class requires certain delegate callbacks from the split view. Therefore an intermediate delegate
/// is added. This is mostly transparent. You can set the delegate and receive callbacks as normal, but if
/// you read the value of the delegate property it will not be the same as the object you set.
@available(iOS 14.0, *)
open class KeyboardSplitViewController: UISplitViewController {

    // MARK: - Delegate shenanigans

    public override init(style: UISplitViewController.Style) {
        super.init(style: style)
        sharedInit()
    }

    public override init(nibName name: String?, bundle: Bundle?) {
        super.init(nibName: name, bundle: bundle)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        delegate = intermediateDelegate
        intermediateDelegate.didChangeState = { [unowned self] in
            self.validateFocusedColumnAfterDisplayStateChange()
        }
    }

    private let intermediateDelegate = IntermediateDelegate()

    open override var delegate: UISplitViewControllerDelegate? {
        get {
            super.delegate
        }
        set {
            if newValue === intermediateDelegate {
                super.delegate = newValue
            } else {
                guard let correctTypeNewValue = newValue as? (UISplitViewControllerDelegate & NSObjectProtocol) else {
                    preconditionFailure("Attempt to set the delegate of a split view controller to an object that does not conform to the NSObject protocol. UISplitViewControllerDelegate has optional methods so that requires respondsToSelector which is part of the NSObject protocol. Surely something else broke before reaching this assertion?")
                }
                intermediateDelegate.externalDelegate = correctTypeNewValue
            }
        }
    }

    private var keyboardDelegate: KeyboardSplitViewControllerDelegate? {
        intermediateDelegate.externalDelegate as? KeyboardSplitViewControllerDelegate
    }

    // MARK: - View lifecycle

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Callbacks will be sent during setup such as the display mode changing. However at that
        // point it might not be possible to set up the first responder correctly. Even if the split
        // view controller view is in the window, the views of the column view controllers might not
        // be in the window. Therefore post an update here once setup has finished.
        validateFocusedColumnAfterDisplayStateChange()
    }

    // MARK: - State

    private enum DisplayState {
        case collapsed
        case expanded(DisplayMode)
    }

    private var displayState: DisplayState {
        // In almost all cases, the displayMode of the split view controller is updated immediately
        // after starting a transition to a display mode (immediately after calling showColumn).
        // However in the case of a triple column split view going from twoDisplaceSecondary to
        // oneBesideSecondary by showing the secondary, the displayMode is still twoDisplaceSecondary
        // until a little after the transition ends. So it’s not just not updated right after calling
        // showColumn. It hasn’t even changed by the time the completion handler of the transitioning
        // delegate is called. However we are told about the upcoming display mode through the split
        // view controller delegate so we listen for that. The fallback of just reading `displayMode`
        // will only be used before the display mode has ever changed.
        isCollapsed ? .collapsed : .expanded(intermediateDelegate.currentOrFutureDisplayMode ?? displayMode)
    }

    /// The column in the expanded split view that currently has focus.
    ///
    /// This will be nil when the split view is collapsed.
    ///
    /// Do not use this to find the focused view controller. Use `focusedViewController` instead.
    ///
    /// This property may be set, which would typically be done to sync up the split view with changes to the first responder.
    /// Setting this property will make no attempt to show the focused column
    /// or validate the column is already visible, and the delegate will not called with `didChangeFocusedColumn`.
    ///
    public var focusedColumn: Column? {
        didSet {
            precondition(focusedColumn != .compact, "An attempt was made to focus the compact column. The focused column should be nil when collapsed.")
        }
    }

    // TODO: One thing not supported currently is if the first responder is set to a column using anything other than the focusedColumn.
    // This happens if you focus the sidebar, go into compact width (detail view gets focus) and then go back into expanded (focus is restored to sidebar, which feels a bit odd)
    
    private func focusColumn(_ column: UISplitViewController.Column) {
        focusedColumn = column
        show(column)
        keyboardDelegate?.didChangeFocusedColumn(inSplitViewController: self)
    }

    private func validateFocusedColumnAfterDisplayStateChange() {
        let old = focusedColumn
        focusedColumn = validatedFocusedColumn()
        if focusedColumn != old {
            keyboardDelegate?.didChangeFocusedColumn(inSplitViewController: self)
        }
    }

    private func validatedFocusedColumn() -> UISplitViewController.Column? {
        switch displayState {
        case .collapsed:
            // If there is a collapsed column we could return .collapsed and that would make sense.
            // If the primary is a navigation controller we could return .primary and that could make sense.
            // But if the primary is not a navigation controller then we’d have to find the primary’s navigation controller
            // and look at its child view controllers and try to match them up with what we know the supplementary and
            // secondary are. It gets messy, so let’s skip this. focusedViewController should be used instead.
            return nil
        case .expanded(let displayMode):
            switch displayMode {
            case .automatic:
                preconditionFailure("Read displayMode must not be automatic.")
            case .secondaryOnly:
                return .secondary
            case .oneBesideSecondary:
                switch (style, focusedColumn) {
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
                return focusedColumn
            case .twoOverSecondary, .twoDisplaceSecondary:
                switch focusedColumn {
                case .primary: return .primary
                case .supplementary: return .supplementary
                default: return .primary // Move focus to first column.
                }
            @unknown default:
                return nil
            }
        }
    }

    /// The child view controller of the split view that currently has focus.
    ///
    /// This may return a navigation controller that was implicitly created by `UISplitViewController`.
    /// It’s recommended that you don’t allow `UISplitViewController` to implicitly create
    /// navigation controllers by explicitly using `KeyboardNavigationController` for the columns.
    public var focusedViewController: UIViewController? {
        if let focusedColumn = focusedColumn {
            return viewController(for: focusedColumn)
        } else if isCollapsed == false {
            // The most likely reason that there is no focused column is that the split view is collapsed,
            // but we could also be during setup, or the property may have been explicitly set to nil.
            return nil
        } else if let compactViewController = viewController(for: .compact) {
            // If a view controller for the compact column is set, use it.
            return compactViewController
        }
        // With no compact column set, the split view will collapse onto the primary navigation controller.
        guard let primary = viewController(for: .primary) else {
            preconditionFailure("Using KeyboardSplitViewController without a primary view controller is not supported.")
        }
        if let primaryAsNavController = primary as? UINavigationController {
            return primaryAsNavController
        } else if let navControllerOfPrimary = primary.navigationController {
            return navControllerOfPrimary
        } else {
            NSLog("Warning: viewController(for: .primary) of split view controller is not a navigation controller and does not have a navigation controller. This is not how UISVC is documented to work. Using the primary view controller as the focused view controller. %@", self)
            return primary
        }
    }

    // MARK: - Key commands

    public override var canBecomeFirstResponder: Bool {
        true
    }

    // TODO: Localised titles

    private lazy var tabCommands: [UIKeyCommand] = [
        UIKeyCommand(.tab, action: #selector(moveFocusInLeadingDirectionWithWrapping), title: "Focus Next Column"),
        UIKeyCommand((.shift, .tab), action: #selector(moveFocusInTrailingDirectionWithWrapping), title: "Focus Previous Column"),
    ]
    private lazy var rightArrowKeyCommands: [UIKeyCommand] = [
        UIKeyCommand(.rightArrow, action: #selector(moveFocusRight)),
    ]
    private lazy var leftArrowKeyCommands: [UIKeyCommand] = [
        UIKeyCommand(.leftArrow, action: #selector(moveFocusLeft)),
    ]
    private lazy var dismissTemporaryColumnKeyCommands: [UIKeyCommand] = [
        UIKeyCommand(.escape, action: #selector(dismissTemporaryColumn)),
    ]

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if canChangeFocusedColumn && UIResponder.isTextInputActive == false {
            commands += tabCommands
            if canMoveFocusRight {
                commands += rightArrowKeyCommands
            }
            if canMoveFocusLeft  {
                commands += leftArrowKeyCommands
            }
            if canDismissTemporaryColumn {
                commands += dismissTemporaryColumnKeyCommands
            }
        }

        return commands
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(moveFocusInLeadingDirectionWithWrapping) || action == #selector(moveFocusInTrailingDirectionWithWrapping) {
            return canChangeFocusedColumn
        }
        if action == #selector(moveFocusRight) {
            return canChangeFocusedColumn && canMoveFocusRight
        }
        if action == #selector(moveFocusLeft) {
            return canChangeFocusedColumn && canMoveFocusLeft
        }
        if action == #selector(dismissTemporaryColumn) {
            return canChangeFocusedColumn && canDismissTemporaryColumn
        }

        return super.canPerformAction(action, withSender: sender)
    }

    private var canChangeFocusedColumn: Bool {
        presentedViewController == nil && (style == .doubleColumn || style == .tripleColumn) && isCollapsed == false
    }

    // MARK: -

    @objc private func moveFocusInLeadingDirectionWithWrapping(_ sender: UIKeyCommand) {
        moveFocusInLeadingDirection(shouldWrap: true)
    }

    @objc private func moveFocusInTrailingDirectionWithWrapping(_ sender: UIKeyCommand) {
        moveFocusInTrailingDirection(shouldWrap: true)
    }

    // MARK: -

    private var canMoveFocusRight: Bool {
        switch view.effectiveUserInterfaceLayoutDirection {
        case .leftToRight: return canMoveFocusInLeadingDirection
        case .rightToLeft: return canMoveFocusInTrailingDirection
        @unknown default: return false
        }
    }

    @objc private func moveFocusRight(_ sender: UIKeyCommand) {
        switch view.effectiveUserInterfaceLayoutDirection {
        case .leftToRight: moveFocusInLeadingDirection(shouldWrap: false)
        case .rightToLeft: moveFocusInTrailingDirection(shouldWrap: false)
        @unknown default: break
        }
    }

    private var canMoveFocusLeft: Bool {
        switch view.effectiveUserInterfaceLayoutDirection {
        case .leftToRight: return canMoveFocusInTrailingDirection
        case .rightToLeft: return canMoveFocusInLeadingDirection
        @unknown default: return false
        }
    }

    @objc private func moveFocusLeft(_ sender: UIKeyCommand) {
        switch view.effectiveUserInterfaceLayoutDirection {
        case .leftToRight: moveFocusInTrailingDirection(shouldWrap: false)
        case .rightToLeft: moveFocusInLeadingDirection(shouldWrap: false)
        @unknown default: break
        }
    }

    // MARK: -

    private var canMoveFocusInLeadingDirection: Bool {
        switch primaryEdge {
        case .leading: return canMoveFocusTowardsSecondary
        case .trailing: return canMoveFocusTowardsPrimary
        @unknown default: return false
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

    private var canMoveFocusInTrailingDirection: Bool {
        switch primaryEdge {
        case .leading: return canMoveFocusTowardsPrimary
        case .trailing: return canMoveFocusTowardsSecondary
        @unknown default: return false
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

    // MARK: -

    private var canMoveFocusTowardsSecondary: Bool {
        focusedColumn != .secondary
    }

    private func moveFocusTowardsSecondary(shouldWrap: Bool) {
        switch focusedColumn {
        case .none:
            focusColumn(.primary)
        case .secondary:
            if shouldWrap {
                focusColumn(.primary)
            }
        case .primary:
            switch style {
            case .doubleColumn:
                focusColumn(.secondary)
            case .tripleColumn:
                focusColumn(.supplementary)
            case .unspecified: fallthrough @unknown default:
                preconditionFailure()
            }
        case .supplementary:
            precondition(style == .tripleColumn)
            focusColumn(.secondary)
        case .compact:
            preconditionFailure("Moving focus should not be enabled when compact.")
        @unknown default:
            break
        }
    }

    private var canMoveFocusTowardsPrimary: Bool {
        focusedColumn != .primary
    }

    private func moveFocusTowardsPrimary(shouldWrap: Bool) {
        switch focusedColumn {
        case .none:
            focusColumn(.secondary)
        case .primary:
            if shouldWrap {
                focusColumn(.secondary)
            }
        case .secondary:
            switch style {
            case .doubleColumn:
                focusColumn(.primary)
            case .tripleColumn:
                focusColumn(.supplementary)
            case .unspecified: fallthrough @unknown default:
                preconditionFailure()
            }
        case .supplementary:
            precondition(style == .tripleColumn)
            focusColumn(.primary)
        case .compact:
            preconditionFailure("Moving focus should not be enabled when compact.")
        @unknown default:
            break
        }
    }

    // MARK: -

    private var canDismissTemporaryColumn: Bool {
        switch displayState {
        case .collapsed:
            return false
        case .expanded(let displayMode):
            switch displayMode {
            case .automatic:
                preconditionFailure("UISplitViewController should not return its current displayMode as automatic.")
            case .oneOverSecondary, .twoOverSecondary, .twoDisplaceSecondary:
                return true
            case .secondaryOnly, .oneBesideSecondary, .twoBesideSecondary: fallthrough @unknown default:
                return false
            }
        }
    }

    @objc private func dismissTemporaryColumn(_ sender: UIKeyCommand) {
        switch displayState {
        case .collapsed:
            preconditionFailure("Can’t dismiss temporary column when collapsed.")
        case .expanded(let displayMode):
            switch displayMode {
            case .oneOverSecondary, .twoOverSecondary:
                // Dismiss one or two overlaid columns. This matches what tapping the dimmed area above the secondary does.
                focusColumn(.secondary)
            case .twoDisplaceSecondary:
                // Either the primary or supplementary must have been focused. Go to the supplementary because it’s the same or the nearest.
                hide(.primary)
                focusColumn(.supplementary)
            case .automatic, .secondaryOnly, .oneBesideSecondary, .twoBesideSecondary: fallthrough @unknown default:
                preconditionFailure("Can’t dismiss temporary column with no suitable column. This should be blocked by canDismissTemporaryColumn.")
            }
        }
    }

    // MARK: -

    private class IntermediateDelegate: NSObject, UISplitViewControllerDelegate {

        /// The delegate external to KeyboardKit.
        weak var externalDelegate: (UISplitViewControllerDelegate & NSObjectProtocol)?

        var currentOrFutureDisplayMode: UISplitViewController.DisplayMode?

        var didChangeState: (() -> Void)?

        override func responds(to selector: Selector!) -> Bool {
            if super.responds(to: selector) {
                return true
            } else {
                return externalDelegate?.responds(to: selector) ?? false
            }
        }

        override func forwardingTarget(for selector: Selector!) -> Any? {
            if let delegate = externalDelegate, delegate.responds(to: selector) {
                return delegate
            } else {
                return super.forwardingTarget(for: selector)
            }
        }

        func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
            currentOrFutureDisplayMode = displayMode
            didChangeState?()
            externalDelegate?.splitViewController?(svc, willChangeTo: displayMode)
        }

        func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
            didChangeState?()
            externalDelegate?.splitViewControllerDidCollapse?(svc)
        }

        func splitViewControllerDidExpand(_ svc: UISplitViewController) {
            didChangeState?()
            externalDelegate?.splitViewControllerDidExpand?(svc)
        }
    }
}

// MARK: -

/// The delegate of a `UISplitViewController` can conform to `KeyboardSplitViewControllerDelegate` in
/// addition to `UISplitViewControllerDelegate` to receive a callback when the focused column changes.
@available(iOS 14.0, *)
public protocol KeyboardSplitViewControllerDelegate: UISplitViewControllerDelegate {
    /// Called after the `focusedColumn` has changed.
    ///
    /// This happens if the user uses keyboard input to change the focused column,
    /// display mode changes, the split view collapses, or the split view expands.
    ///
    /// This is typically used to update the first responder to a view within the new focused column.
    ///
    /// This method will not be called when the focused column is hidden because KeyboardKit
    /// does not have enough contexts to handle that case. Your app should handle this.
    ///
    /// Since `splitViewControllerDidCollapse` can be called before the view has loaded, this delegate
    /// method may also be called before the view has loaded.
    func didChangeFocusedColumn(inSplitViewController splitViewController: KeyboardSplitViewController)
}

/*
 Known issue with UISplitViewController

 You can see this problem by focusing the primary on an iPad in portrait or major split view
 and then pressing shift-tab three times quickly.

 If you tell UISVC to show(.supplementary) while it is transitioning from twoOverSecondary to
 secondaryOnly, it will initially say that it will transition to twoOverSecondary. However shortly
 after this, a deferred callback comes in saying it will transition to oneOverSecondary. This sort
 of makes sense: the expected end state for showing the supplementary from secondaryOnly would be
 oneOverSecondary but since it started at twoOverSecondary maybe it thinks it can take a shortcut
 to show the supplementary and then decides actually it can’t for some reason.

 The problem is that if you call show(.primary) in this window between the twoOverSecondary callback
 and the deferred oneOverSecondary callback, the UISVC does nothing. Presumably it thinks it’s already
 in or heading to twoOverSecondary and therefore the primary is or will be visible, so there’s nothing
 to do.

 TODO: File a feedback

 */
