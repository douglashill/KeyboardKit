// Douglas Hill, July 2020

import UIKit

/// A split view controller that supports navigating between columns using tab or arrows keys on a hardware keyboard.
///
/// This class does not read or set the first responder itself, because it would not know which descendant
/// within a column should be first responder. Instead instances of this class have a `focusedColumn` property.
/// This is simply tracking the state and does nothing on its own. To actually update the first responder the
/// `delegate` of the split view controller should conform to `KeyboardSplitViewControllerDelegate`. In the
/// delegate’s implementation of `didChangeFocusedColumn` it should update the first responder based on the
/// split view controller’s `focusedColumn`.
///
/// To read more about how to set up this class, please see the documentation in `KeyboardSplitViewController.md`.
///
/// This subclass only supports iOS 14 split view controllers that are initialised with a `style` and have their
/// view controllers set as columns. Using the `.unspecified` style is not supported.
///
/// This class requires certain delegate callbacks from the split view. Therefore an intermediate delegate
/// is added. This is mostly transparent. You can set the delegate and receive callbacks as normal, but if
/// you read the value of the delegate property it will not be the same as the object you set.
@available(iOS 14.0, *)
open class KeyboardSplitViewController: UISplitViewController, IntermediateDelegateOwner {

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
    }

    private lazy var intermediateDelegate = IntermediateDelegate(owner: self)

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
        // This might be unnecessary after willChangeToDisplayMode changed to use dispatch_async.
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
    /// You can’t simply find the focused view controller with `viewController(for: focusedColumn)`
    /// because there might be a compact column or the supplementary and secondary view controllers
    /// may have been collapsed onto the primary navigation controller.
    ///
    /// This property may be set, which would typically be done to sync the split view with changes to the
    /// first responder. Setting this property will make no attempt to show the focused column or validate
    /// the column is already visible, and the delegate will not called with `didChangeFocusedColumn`.
    open var focusedColumn: Column? {
        didSet {
            precondition(focusedColumn != .compact, "An attempt was made to focus the compact column. The focused column should be nil when collapsed.")
        }
    }

    private func focusColumn(_ column: UISplitViewController.Column) {
        focusedColumn = column
        show(column)
        keyboardDelegate?.didChangeFocusedColumn(inSplitViewController: self)
    }

    fileprivate func validateFocusedColumnAfterDisplayStateChange() {
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
            // secondary are. It gets messy, so let’s skip this.
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

    // MARK: - Key commands

    open override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var tabCommands: [UIKeyCommand] = [
        UIKeyCommand(.tab, action: #selector(moveFocusInLeadingDirectionWithWrapping)),
        UIKeyCommand((.shift, .tab), action: #selector(moveFocusInTrailingDirectionWithWrapping)),
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

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if canChangeFocusedColumn && UIResponder.isTextInputActive == false {
            // The UIKit focus system is supposed to automatically have precedence over these,
            // but for some reason these left and right arrow commands are still triggered in
            // TripleColumnSplitViewController in the KeyboardKit demo app.
            // Therefore disable them explicitly on iOS 15.
            if UIFocusSystem(for: self) == nil {
                commands += tabCommands
                if canMoveFocusRight {
                    commands += rightArrowKeyCommands
                }
                if canMoveFocusLeft  {
                    commands += leftArrowKeyCommands
                }
            }

            // This is still useful when using the UIKit focus system.
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

        /// The object that owns this intermediate delegate.
        unowned var owner: IntermediateDelegateOwner

        init(owner: IntermediateDelegateOwner) {
            self.owner = owner
        }

        var currentOrFutureDisplayMode: UISplitViewController.DisplayMode?

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

            /*
             If we validated immediately, then when tapping back button when in secondary-only on iPad portrait
             (and probably in other cases too) this willChangeTo callback is too soon so the primary view is not
             in the hierarchy yet. This is smoothed over in the demo app by FirstResponderViewController
             updating the first responder whenever it appears or disappears but this should work without that.

             We don’t want to use the completion of the transitionCoordinator because that would run after the
             animation, so would feel slow. Keyboard focus should move immediately in transitions.

             This issue does not occur when using arrow keys because we first set the final focusedColumn then
             change the display mode. The callback in the middle of this will be ignored because we already
             have the correct focusedColumn. But then the actual delegate callback happens last, after the view
             has been added so it’s fine.

             We are relying on UIKit adding the views for the incoming column synchronously, but if it didn’t
             do this the same issue would likely trigger when calling show/hide so would be noticed quickly.
             */
            DispatchQueue.main.async {
                self.owner.validateFocusedColumnAfterDisplayStateChange()
            }
            externalDelegate?.splitViewController?(svc, willChangeTo: displayMode)
        }

        func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
            owner.validateFocusedColumnAfterDisplayStateChange()
            externalDelegate?.splitViewControllerDidCollapse?(svc)
        }

        func splitViewControllerDidExpand(_ svc: UISplitViewController) {
            owner.validateFocusedColumnAfterDisplayStateChange()
            externalDelegate?.splitViewControllerDidExpand?(svc)
        }

        func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
            // The default behaviour is to show the secondary if there is no compact column.
            // Since we have a first-class concept of user focus let’s use that.
            let ourProposedTopColumn = proposedTopColumn == .compact ? proposedTopColumn : owner.focusedColumn ?? proposedTopColumn
            return externalDelegate?.splitViewController?(svc, topColumnForCollapsingToProposedTopColumn: ourProposedTopColumn) ?? ourProposedTopColumn
        }
    }
}

// MARK: -

@available(iOS 14.0, *)
private protocol IntermediateDelegateOwner: NSObjectProtocol {
    func validateFocusedColumnAfterDisplayStateChange()
    var focusedColumn: UISplitViewController.Column? { get }
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

 You can see this problem in a triple column split view by focusing the primary on an
 iPad in portrait or major split view and then pressing shift-tab three times quickly.

 If you tell UISVC to show(.supplementary) while it is transitioning from twoOverSecondary to
 secondaryOnly, it will initially say that it will transition to twoOverSecondary. However shortly
 after this, a deferred callback comes in saying it will transition to oneOverSecondary. This sort
 of makes sense: the expected end state for showing the supplementary from secondaryOnly would be
 oneOverSecondary but since it started at twoOverSecondary maybe it thinks it can take a shortcut
 to show the supplementary and then decides actually it can’t for some reason.

 The problem is that if you call show(.primary) in this window between the twoOverSecondary
 callback and the deferred oneOverSecondary callback, the UISVC does nothing. Presumably it
 thinks it’s already in or heading to twoOverSecondary and therefore the primary is or will
 be visible, so there’s nothing to do.

 TODO: File a feedback

 */
