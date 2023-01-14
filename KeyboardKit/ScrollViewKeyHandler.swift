// Douglas Hill, December 2019

import UIKit

/// Provides key commands for scrolling and implements the actions of those key commands.
/// In order to receive those actions the object must be added to the responder chain
/// by the owner overriding `nextResponder`. Then implement `nextResponderForResponder`
/// to put the responder chain back on its regular path.
///
/// This class is tightly coupled with `UIScrollView`. It’s a separate class so it can be used
/// with the UIKit scroll view subclasses (`UITableView`, `UICollectionView` and `UITextView`).
///
/// This class does not use `UIScrollView`’s `setContentOffset:animated:`. The custom animation ensures
/// that the velocity transitions smoothly when an animation is replaced with another animation before
/// finishing. This is important for keyboard input because it’s common to tap a key multiple times in
/// quick succession. The custom implementation is also required to keep track of the final state.
///
/// The scroll view’s `delegate` can conform to `KeyboardScrollingDelegate`
/// to receive callbacks about keyboard-driven scrolling animations.
class ScrollViewKeyHandler: InjectableResponder, UIScrollViewDelegate {

    private unowned var scrollView: UIScrollView

    /// Creates a new scroll view key handler.
    /// - Parameters:
    ///   - scrollView: The owning scroll view. The scroller is not valid to use if the scroll view deallocates.
    ///   - owner: The object that owns the key handler and can provide it with a next responder.
    init(scrollView: UIScrollView, owner: ResponderChainInjection) {
        self.scrollView = scrollView
        super.init(owner: owner)
    }

    // MARK: - Key commands

    private let scrollAction = #selector(scrollFromKeyCommand)

    private lazy var arrowKeyScrollingCommands: [UIKeyCommand] = [String.upArrow, .downArrow, .leftArrow, .rightArrow].flatMap { input -> [UIKeyCommand] in
        [UIKeyModifierFlags(), .alternate, .command].map { modifierFlags in
            UIKeyCommand((modifierFlags, input), action: scrollAction, wantsPriorityOverSystemBehavior: true, allowsAutomaticMirroring: false)
        }
    }

    private lazy var spaceBarScrollingCommands: [UIKeyCommand] = [
        UIKeyCommand(.space, action: scrollAction, wantsPriorityOverSystemBehavior: true),
        UIKeyCommand((.shift, .space), action: scrollAction, wantsPriorityOverSystemBehavior: true),
    ]

    private lazy var pageUpDownHomeEndScrollingCommands: [UIKeyCommand] = [
        UIKeyCommand(.pageUp, action: scrollAction),
        UIKeyCommand(.pageDown, action: scrollAction),
        UIKeyCommand(.home, action: scrollAction),
        UIKeyCommand(.end, action: scrollAction),
    ]

    private lazy var nonDiscoverableZoomingCommands: [UIKeyCommand] = [
        // This is the one users are expected to press. We don’t want to show = in the UI.
        UIKeyCommand(keyboardInput: .zoomIn, action: #selector(kbd_zoomIn)),
        // This is the one users are expected to press. This is a hyphen.
        UIKeyCommand(keyboardInput: .zoomOut, action: #selector(kbd_zoomOut)),
        // You can hold shift and press the =/+ key and it still zooms in, so match that for zooming out with the -/_ key.
        UIKeyCommand((.command, "_"), action: #selector(kbd_zoomOut)),
    ]

    // This is to show up as + in the UI. Don’t expect users to press this one because it needs shift.
    static let zoomInKeyCommand = DiscoverableKeyCommand((.command, "+"), action: #selector(kbd_zoomIn), title: localisedString(.scrollView_zoomIn))

    // This is a minus sign, not a hyphen, to align nicely in the UI.
    static let zoomOutKeyCommand = DiscoverableKeyCommand((.command, "−"), action: #selector(kbd_zoomOut), title: localisedString(.scrollView_zoomOut))

    static let actualSizeKeyCommand = DiscoverableKeyCommand(keyboardInput: .zoomToActualSize, action: #selector(kbd_resetZoom), title: localisedString(.scrollView_zoomReset))

    static let refreshKeyCommand = DiscoverableKeyCommand(keyboardInput: .refresh, action: #selector(kbd_refresh), title: localisedString(.refresh))

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        // See the comment in SelectableCollectionKeyHandler.keyCommands.
        guard isInResponderChain else {
            return commands
        }

        if scrollView.isScrollEnabled {
            if UIResponder.isTextInputActive == false {
                if scrollView.kbd_isArrowKeyScrollingEnabled {
                    // On iOS 15.0 (as of beta 4) a key command with an action that nothing can perform still blocks
                    // other key commands from handling the same input. This was not an issue on iOS 14 and earlier.
                    // This has been reported as FB9469253.
                    commands += arrowKeyScrollingCommands.filter { targetContentOffsetForKeyCommand($0) != nil }
                }

                if scrollView.kbd_isSpaceBarScrollingEnabled {
                    commands += spaceBarScrollingCommands
                }
            }

            commands += pageUpDownHomeEndScrollingCommands
        }

        if scrollView.isZoomingEnabled {
            commands += nonDiscoverableZoomingCommands
            commands += [Self.zoomInKeyCommand, Self.zoomOutKeyCommand, Self.actualSizeKeyCommand].filter { $0.shouldBeIncludedInResponderChainKeyCommands }
        }

        if Self.refreshKeyCommand.shouldBeIncludedInResponderChainKeyCommands && scrollView.canRefresh {
            commands.append(Self.refreshKeyCommand)
        }

        return commands
    }

    /// A simple check for whether the scroll view can become focused.
    var areKeyCommandsEnabled: Bool {
        scrollView.isScrollEnabled || scrollView.isZooming || scrollView.canRefresh
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // For why isInResponderChain is used, see the comment in SelectableCollectionKeyHandler.keyCommands.
        switch action {
        case scrollAction:
            if isInResponderChain, let keyCommand = sender as? UIKeyCommand {
                return targetContentOffsetForKeyCommand(keyCommand) != nil
            } else {
                return false
            }

        case #selector(kbd_zoomIn), #selector(kbd_zoomOut), #selector(kbd_resetZoom):
            return isInResponderChain && scrollView.isZoomingEnabled

        case #selector(kbd_refresh):
            return isInResponderChain && scrollView.canRefresh

        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }

    @objc func kbd_resetZoom(_ keyCommand: UIKeyCommand) {
        scrollView.resetZoom()
    }

    @objc func kbd_zoomIn(_ sender: Any?) {
        scrollView.zoom(isZoomingIn: true)
    }

    @objc func kbd_zoomOut(_ sender: Any?) {
        scrollView.zoom(isZoomingIn: false)
    }

    @objc func kbd_refresh(_ keyCommand: UIKeyCommand) {
        scrollView.refresh()
    }

    // MARK: - Scroll view delegate interception

    /// The delegate external to KeyboardKit.
    weak var externalDelegate: UIScrollViewDelegate?

    private var keyboardScrollingDelegate: KeyboardScrollingDelegate? {
        (enableScrollViewDelegateInterception ? externalDelegate : scrollView.delegate) as? KeyboardScrollingDelegate
    }

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

    var previousScrollViewDidScroll: (contentOffset: CGPoint, time: CFTimeInterval)?
    var mostRecentScrollViewDidScroll: (contentOffset: CGPoint, time: CFTimeInterval)?

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        previousScrollViewDidScroll = mostRecentScrollViewDidScroll
        mostRecentScrollViewDidScroll = (scrollView.contentOffset, CACurrentMediaTime())

        externalDelegate?.scrollViewDidScroll?(scrollView)
    }

    /// The velocity of the scroll view content offset change found by observing when this property changes.
    private var measuredVelocityOfScrollView: CGPoint? {
        guard
            let (previousContentOffset, previousTime) = previousScrollViewDidScroll,
            let (mostRecentContentOffset, mostRecentTime) = mostRecentScrollViewDidScroll
            else
        {
            return nil
        }

        // This lags behind the actual velocity but it’s better than nothing.
        let dv = mostRecentContentOffset - previousContentOffset
        let dt = mostRecentTime - previousTime
        return dv / dt
    }

    /// The content offset the scroll view is animating to after dragging ends (only with paging enabled).
    ///
    /// This means if the user swipes to change page and then quickly triggers keyboard scrolling
    /// then the keyboard-driven animation will start from the destination page after the swipe.
    var targetContentOffsetFromDragging: CGPoint?

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        externalDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)

        targetContentOffsetFromDragging = targetContentOffset.pointee
    }

    // MARK: - Scrolling

    /// The content offset that should be used as a base when starting an animation to account for active animations.
    private var startingContentOffsetForAnimation: CGPoint {
        if let offsetFromAnimator = contentOffsetAnimator.targetPoint {
            return offsetFromAnimator
        } else if scrollView.isPagingEnabled, scrollView.isDecelerating, let offsetFromDragging = targetContentOffsetFromDragging {
            // Check isDecelerating because trying to nil out the property with scrollViewDidEndDecelerating was not reliable.
            // This only feels good in paging scroll views because the deceleration time is shorter and the final position feels more well defined.
            return offsetFromDragging
        } else {
            return scrollView.contentOffset
        }
    }

    private func targetContentOffsetForKeyCommand(_ keyCommand: UIKeyCommand) -> CGPoint? {
        if scrollView.isTracking {
            return nil
        }

        let startingOffset = startingContentOffsetForAnimation
        let unbounded = scrollView.unboundedContentOffsetFromKeyCommand(keyCommand, startingContentOffset: startingOffset)
        let target = scrollView.boundedContentOffsetFromProposedContentOffset(unbounded)

        if target == startingOffset {
            return nil
        } else {
            return target
        }
    }

    // internal access for tests
    @objc func scrollFromKeyCommand(_ keyCommand: UIKeyCommand) {
        guard let target = targetContentOffsetForKeyCommand(keyCommand) else {
            return
        }

        keyboardScrollingDelegate?.willBeginKeyboardScrollingAnimation(toContentOffset: target, inScrollView: scrollView)
        animateToContentOffset(target)
        scrollView.flashScrollIndicators()
    }

    // MARK: - Scrolling animations

    /// Need to create `contentOffsetAnimator` after self is initialised so use this technique.
    private var _contentOffsetAnimatorStorage: PointAnimator?
    private var contentOffsetAnimator: PointAnimator {
        if let stored = _contentOffsetAnimatorStorage {
            return stored
        }

        let animator = PointAnimator()
        _contentOffsetAnimatorStorage = animator

        animator.stepCallback = { [weak self] point in
            guard let self else { return }
            if self.scrollView.isTracking {
                self.contentOffsetAnimator.cancelAnimation()
            } else {
                self.scrollView.contentOffset = point
            }
        }

        animator.endCallback = { [weak self] isFinished in
            guard let self else { return }
            self.keyboardScrollingDelegate?.didEndKeyboardScrollingAnimation(inScrollView: self.scrollView, isFinished: isFinished)
        }

        return animator
    }

    /// Custom implementation of animated scrolling to:
    /// - Track the destination of the current animation without needing to be the scroll view’s delegate to know when to unset this if we stored it.
    /// - Maintain a continuous velocity if a new animation is started while an existing animation is in progress.
    /// - Interact better with finger scrolling when an animation is in progress.
    private func animateToContentOffset(_ targetContentOffset: CGPoint) {
        if UIAccessibility.isReduceMotionEnabled {
            scrollView.setContentOffset(targetContentOffset, animated: false)
        } else {
            let velocity: CGPoint?

            if scrollView.isDecelerating {
                velocity = measuredVelocityOfScrollView
                // UIKit’s animator would fight with our own on each frame (and it would win) so kill any active deceleration animations.
                // This deliberately passes the current content offset rather than the target.
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            } else {
                velocity = nil
            }

            contentOffsetAnimator.startAnimation(
                fromPoint: scrollView.contentOffset,
                toPoint: targetContentOffset,
                startingVelocity: velocity
            )
        }
    }
}

// MARK: - Key command availability

// Internal access and @objc (AKA dynamic dispatch) so these can be overridden in subclasses.
extension UIScrollView {
    @objc var kbd_isArrowKeyScrollingEnabled: Bool {
        true
    }

    @objc var kbd_isSpaceBarScrollingEnabled: Bool {
        true
    }
}

// MARK: - Determining where to scroll to

private extension UIScrollView {

    /// Restricts a proposed content offset to lie within limits of the scroll view content size.
    func boundedContentOffsetFromProposedContentOffset(_ proposedContentOffset: CGPoint) -> CGPoint {
        let insets = adjustedContentInset
        var offset = proposedContentOffset

        // If the content is smaller than the bounds then the max offset would be less than the min offset.
        // Therefore restrict to the minimum last so content is aligned to the top or left to match UIScrollView.
        offset.x = min(offset.x, insets.right + contentSize.width - bounds.width)
        offset.y = min(offset.y, insets.bottom + contentSize.height - bounds.height)
        offset.x = max(offset.x, -insets.left)
        offset.y = max(offset.y, -insets.top)

        return offset
    }

    /// Returns the desired content offset due to input from a key command. This does not consider the content offset limits.
    func unboundedContentOffsetFromKeyCommand(_ keyCommand: UIKeyCommand, startingContentOffset: CGPoint) -> CGPoint {
        guard let direction = directionFromKeyCommand(keyCommand), let step = scrollStepFromKeyCommand(keyCommand, isPaging: isPagingEnabled) else {
            return startingContentOffset
        }

        let resolvedDirection = resolvedDirectionFromDirection(direction)

        /// The horizontal and vertical distances by which to scroll when scrolling by one page, but with overlap to give the user better sense of place.
        /// This is for when isPagingEnabled if false.
        var viewportScrollSize: CGSize {
            bounds.inset(by: adjustedContentInset).insetBy(dx: 0.5 * viewportScrollingOverlapDistance, dy: 0.5 * viewportScrollingOverlapDistance).size
        }

        // Easier to deal with than CGFloat.greatestFiniteMagnitude to avoid overflow.
        let limit: CGFloat = 1e6

        switch (step, resolvedDirection) {
        case (.nudge, .up):       return startingContentOffset + CGVector(dx: 0, dy: -nudgeDistance)
        case (.nudge, .down):     return startingContentOffset + CGVector(dx: 0, dy: +nudgeDistance)
        case (.nudge, .left):     return startingContentOffset + CGVector(dx: -nudgeDistance, dy: 0)
        case (.nudge, .right):    return startingContentOffset + CGVector(dx: +nudgeDistance, dy: 0)

        case (.viewport, .up):    return startingContentOffset + CGVector(dx: 0, dy: -viewportScrollSize.height)
        case (.viewport, .down):  return startingContentOffset + CGVector(dx: 0, dy: +viewportScrollSize.height)
        case (.viewport, .left):  return startingContentOffset + CGVector(dx: -viewportScrollSize.width, dy: 0)
        case (.viewport, .right): return startingContentOffset + CGVector(dx: +viewportScrollSize.width, dy: 0)

        case (.page, .up):        return unboundedContentOffsetByAddingPageDiff((dx: 0, dy: -1), toContentOffset: startingContentOffset)
        case (.page, .down):      return unboundedContentOffsetByAddingPageDiff((dx: 0, dy: +1), toContentOffset: startingContentOffset)
        case (.page, .left):      return unboundedContentOffsetByAddingPageDiff((dx: -1, dy: 0), toContentOffset: startingContentOffset)
        case (.page, .right):     return unboundedContentOffsetByAddingPageDiff((dx: +1, dy: 0), toContentOffset: startingContentOffset)

        case (.end, .up):         return startingContentOffset + CGVector(dx: 0, dy: -limit)
        case (.end, .down):       return startingContentOffset + CGVector(dx: 0, dy: +limit)
        case (.end, .left):       return startingContentOffset + CGVector(dx: -limit, dy: 0)
        case (.end, .right):      return startingContentOffset + CGVector(dx: +limit, dy: 0)
        }
    }

    /// Returns a modified content offset for incrementing/decrementing through pages with isPagingEnabled.
    /// Locks to page boundaries. No attempt is made to stay within the contentSize.
    private func unboundedContentOffsetByAddingPageDiff(_ pageDiff: (dx: Int, dy: Int), toContentOffset startingContentOffset: CGPoint) -> CGPoint {
        // There is no guarantee the starting offset is on a page boundary. Happens
        // if pressing an arrow key while still decelerating from finger scrolling.

        var contentOffset = startingContentOffset
        let startingPage = pageForContentOffset(startingContentOffset)

        if let startingHorizontalPage = startingPage.x, pageDiff.dx != 0 {
            let finalHorizontalPage = startingHorizontalPage + pageDiff.dx
            contentOffset.x = CGFloat(finalHorizontalPage) * bounds.width
        }
        if let startingVerticalPage = startingPage.y, pageDiff.dy != 0 {
            let finalVerticalPage = startingVerticalPage + pageDiff.dy
            contentOffset.y = CGFloat(finalVerticalPage) * bounds.height
        }

        return contentOffset
    }

    /// Returns the closest current page index for isPagingEnabled with (x, y) components.
    /// Each component may be nil if the bounds has zero size in either dimension. First page is zero.
    private func pageForContentOffset(_ contentOffset: CGPoint) -> (x: Int?, y: Int?) {
        var h: Int?
        var v: Int?
        if bounds.width != 0 {
            h = Int(round(contentOffset.x / bounds.width))
        }
        if bounds.height != 0 {
            v = Int(round(contentOffset.y / bounds.height))
        }
        return (h, v)
    }

    /// Whether scrolling is horizontal or vertical.
    private enum ScrollAxis {
        /// Scrolling left and right.
        case horizontal
        /// Scrolling up and down.
        case vertical
    }

    /// The direction the user is mostly likely to consider the main scrolling direction.
    private var primaryScrollAxis: ScrollAxis {
        if contentSize.width > bounds.width && contentSize.height <= bounds.height {
            return .horizontal
        }

        // Default to vertical when there is no scrolling or is scrolling in both directions, because vertical scrolling is more common.
        return .vertical
    }

    /// A concrete direction in which scrolling can take place.
    private enum ResolvedDirection {
        case up
        case down
        case left
        case right
    }

    /// Returns a concrete direction in which scrolling can take place from a scrolling direction that may be semantic.
    private func resolvedDirectionFromDirection(_ direction: Direction) -> ResolvedDirection {
        switch direction {

        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right

        case .backwards:
            switch primaryScrollAxis {
            case .horizontal:
                switch effectiveUserInterfaceLayoutDirection {
                case .rightToLeft: return .right
                case .leftToRight: fallthrough @unknown default: return .left
                }
            case .vertical: return .up
            }

        case .forwards:
            switch primaryScrollAxis {
            case .horizontal:
                switch effectiveUserInterfaceLayoutDirection {
                case .rightToLeft: return .left
                case .leftToRight: fallthrough @unknown default: return .right
                }
            case .vertical: return .down
            }
        }
    }
}

/// Distance in points to scroll with a regular arrow key press.
private var nudgeDistance: CGFloat {
    UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).pointSize * 3
}

/// This distance in points is subtracted from the visible width/height when scrolling by `ScrollStep.viewport`.
private var viewportScrollingOverlapDistance: CGFloat {
    nudgeDistance
}

/// An unresolved direction in which scrolling can take place. Includes semantic directions.
private enum Direction {
    case up
    case down
    case left
    case right
    /// Semantic direction. Towards the start.
    case backwards
    /// Semantic direction. Towards the end.
    case forwards
}

/// Returns the direction in which to scroll due to input from a key command.
private func directionFromKeyCommand(_ keyCommand: UIKeyCommand) -> Direction? {
    switch keyCommand.input ?? "" {

    case .upArrow: return .up
    case .downArrow: return .down
    case .leftArrow: return .left
    case .rightArrow: return .right

    case .space: return keyCommand.modifierFlags.contains(.shift) ? .backwards : .forwards

    case .pageUp, .home: return .backwards
    case .pageDown, .end: return .forwards

    default: return nil
    }
}

/// A distance to scroll.
private enum ScrollStep {
    /// Scroll by a few lines of text.
    case nudge
    /// Scroll by the width or height of the visible region minus a bit of overlap for context.
    case viewport
    /// Scroll by the exact width or height of the scroll view. Used when paging is enabled.
    case page
    /// Scroll all the way to the top, bottom, left or right.
    case end
}

/// Returns the distance to scroll due to input from a key command.
private func scrollStepFromKeyCommand(_ keyCommand: UIKeyCommand, isPaging: Bool) -> ScrollStep? {
    switch keyCommand.input ?? "" {

    case .upArrow, .downArrow, .leftArrow, .rightArrow:
        return scrollStepForArrowKeyWithModifierFlags(keyCommand.modifierFlags, isPaging: isPaging)

    case .space, .pageUp, .pageDown:
        return isPaging ? .page : .viewport

    case .home, .end:
        return .end

    default: return nil
    }
}

/// Returns the distance to scroll due to input from an arrow key.
private func scrollStepForArrowKeyWithModifierFlags(_ modifierFlags: UIKeyModifierFlags, isPaging: Bool) -> ScrollStep {
    if modifierFlags.contains(.command) {
        return .end
    }
    if isPaging {
        return .page
    }
    if modifierFlags.contains(.alternate) {
        return .viewport
    }
    return .nudge
}

// MARK: - Zooming

private extension UIScrollView {

    var isZoomingEnabled: Bool {
        // As documented in UIScrollView.h.
        pinchGestureRecognizer != nil
    }

    private var shouldAnimate: Bool {
        UIAccessibility.isReduceMotionEnabled == false
    }

    func resetZoom() {
        setZoomScale(1, animated: shouldAnimate)
    }

    /// Zooms in or out by one step with animation. Snaps to an even logarithmic scale over the zoom range. Also snaps to a scale of 1.
    func zoom(isZoomingIn: Bool) {
        guard minimumZoomScale < maximumZoomScale else {
            // UIScrollView doesn’t crash in this case so let’s not either.
            return
        }

        // It’s nice if zooming exactly hits a scale of 1. Therefore when the zoom range spans 1 we work only in the range greater than or less than 1.
        let minScale: CGFloat
        let maxScale: CGFloat
        if minimumZoomScale >= 1 || maximumZoomScale <= 1 {
            // Don’t need to worry about hitting a scale of exactly 1.
            minScale = minimumZoomScale
            maxScale = maximumZoomScale
        } else if zoomScale < 1 || zoomScale == 1 && !isZoomingIn {
            minScale = minimumZoomScale
            maxScale = 1
        } else if zoomScale > 1 || zoomScale == 1 && isZoomingIn {
            minScale = 1
            maxScale = maximumZoomScale
        } else {
            preconditionFailure("Numbers are broken.")
        }

        // Zooming should use a logarithmic scale. The base of the logarithmic scale is the zoomStepMultiple.

        // Multiplying or dividing the zoom scale by the golden ratio feels about right. The exact base will be adjusted so there are an integer number of steps in the zoom range.
        let approxZoomStepMultiple: CGFloat = 1.618
        // Find the number of steps.
        let maxPower = round(log(maxScale / minScale) / log(approxZoomStepMultiple))
        // Divide the zoom range up evenly on the logarithmic scale.
        let zoomStepMultiple = pow(exp(1), (log(maxScale / minScale) / maxPower))

        // Convert the current zoom scale to the logarithmic scale.
        let currentPower = log(zoomScale / minScale) / log(zoomStepMultiple)
        // Increment or decrement on the logarithmic scale. If we’re nearly at a step, go to the next step instead of zooming a tiny little bit.
        let targetPower = round(currentPower + (isZoomingIn ? 0.75 : -0.75))
        // Convert back from the logarithmic scale.
        let targetZoomScale = minScale * pow(zoomStepMultiple, targetPower)

        setZoomScale(targetZoomScale, animated: shouldAnimate)
    }
}

// MARK: - Refreshing

private extension UIScrollView {

    var canRefresh: Bool {
        refreshControl?.allControlEvents.contains(.valueChanged) ?? false
    }

    func refresh() {
        guard let refreshControl = refreshControl, refreshControl.isRefreshing == false else {
            return
        }

        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
    }
}

// MARK: -

private func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

private func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

private func / (lhs: CGPoint, rhs: Double) -> CGPoint {
    CGPoint(x: lhs.x / CGFloat(rhs), y: lhs.y / CGFloat(rhs))
}

/// If this is set, `KeyboardScrollView` will hook into its own delegate to slightly improve
/// keyboard-driven animations started while the scroll view is decelerating after dragging.
/// This is currently inconsistent because it’s only applied to `KeyboardScrollView` and not table views etc.
/// This is not considered supported public API.
let enableScrollViewDelegateInterception = (Bundle.main.object(forInfoDictionaryKey: "KeyboardKitEnableScrollViewDelegateInterception") as? NSNumber)?.boolValue ?? false
