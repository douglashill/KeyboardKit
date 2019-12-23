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
/// The scroll view’s `scrollViewDidEndScrollingAnimation:` will be called after a scrolling
/// animation finishes or is interrupted by a new scrolling animation.
class ScrollViewKeyHandler: InjectableResponder {

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

    private lazy var arrowKeyScrollingCommands: [UIKeyCommand] = [.upArrow, .downArrow, .leftArrow, .rightArrow].flatMap { input -> [UIKeyCommand] in
        [UIKeyModifierFlags(), .alternate, .command].map { modifierFlags in
            UIKeyCommand(input: input, modifierFlags: modifierFlags, action: scrollAction)
        }
    }

    private lazy var spaceBarScrollingCommands: [UIKeyCommand] = [
        UIKeyCommand(.space, action: scrollAction),
        UIKeyCommand((.shift, .space), action: scrollAction),
    ]

    private lazy var pageUpDownHomeEndScrollingCommands: [UIKeyCommand] = [
        UIKeyCommand(.pageUp, action: scrollAction),
        UIKeyCommand(.pageDown, action: scrollAction),
        UIKeyCommand(.home, action: scrollAction),
        UIKeyCommand(.end, action: scrollAction),
    ]

    private lazy var zoomingCommands: [UIKeyCommand] = [
        // This is to show up as + in the UI. Don’t expect users to press this one because it needs shift.
        UIKeyCommand((.command, "+"), action: #selector(UIScrollView.kbd_zoomIn), title: localisedString(.scrollView_zoomIn)),
        // This is the one users are expected to press. We don’t want to show = in the UI.
        UIKeyCommand((.command, "="), action: #selector(UIScrollView.kbd_zoomIn)),

        // This is a minus sign, not a hyphen, to align nicely in the UI.
        UIKeyCommand((.command, "−"), action: #selector(UIScrollView.kbd_zoomOut), title: localisedString(.scrollView_zoomOut)),
        // This is the one users are expected to press. This is a hyphen.
        UIKeyCommand((.command, "-"), action: #selector(UIScrollView.kbd_zoomOut)),
        // You can hold shift and press the =/+ key and it still zooms in, so match that for zooming out with the -/_ key.
        UIKeyCommand((.command, "_"), action: #selector(UIScrollView.kbd_zoomOut)),

        UIKeyCommand((.command, "0"), action: #selector(UIScrollView.kbd_resetZoom), title: localisedString(.scrollView_zoomReset)),
    ]

    private lazy var refreshingCommands = [
        UIKeyCommand((.command, "r"), action: #selector(UIScrollView.kbd_refresh), title: localisedString(.scrollView_refresh))
    ]

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if scrollView.isScrollEnabled {

            if UIResponder.isTextInputActive == false {
                if scrollView.kbd_isArrowKeyScrollingEnabled {
                    commands += arrowKeyScrollingCommands
                }

                if scrollView.kbd_isSpaceBarScrollingEnabled {
                    commands += spaceBarScrollingCommands
                }
            }

            commands += pageUpDownHomeEndScrollingCommands
        }

        if scrollView.isZoomingEnabled {
            commands += zoomingCommands
        }

        if scrollView.canRefresh {
            commands += refreshingCommands
        }

        return commands
    }

    // MARK: - Scrolling

    @objc private func scrollFromKeyCommand(_ keyCommand: UIKeyCommand) {
        if scrollView.isTracking {
            return
        }

        let diff = scrollView.contentOffsetDiffFromKeyCommand(keyCommand)
        let target = scrollView.boundedContentOffsetFromProposedContentOffset(startingContentOffsetForAnimation + diff)

        if target != startingContentOffsetForAnimation {
            animateToContentOffset(target)
            scrollView.flashScrollIndicators()
        }
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
            guard let self = self else { return }
            if self.scrollView.isTracking {
                self.contentOffsetAnimator.cancelAnimation()
            } else {
                self.scrollView.contentOffset = point
            }
        }

        animator.endCallback = { [weak self] isFinished in
            guard let self = self else { return }
            self.scrollView.delegate?.scrollViewDidEndScrollingAnimation?(self.scrollView)
        }

        return animator
    }

    /// The content offset that should be used as a base when starting an animation to account for active animations.
    private var startingContentOffsetForAnimation: CGPoint {
        return contentOffsetAnimator.targetPoint ?? scrollView.contentOffset
    }

    /// Custom implementation of animated scrolling to:
    /// - Track the destination of the current animation without needing to be the scroll view’s delegate to know when to unset this if we stored it.
    /// - Maintain a continuous velocity if a new animation is started while an existing animation is in progress.
    /// - Interact better with finger scrolling when an animation is in progress.
    private func animateToContentOffset(_ targetContentOffset: CGPoint) {
        if scrollView.isDecelerating {
            // UIKit’s animator would fight with our own on each frame (and it would win) so kill any active deceleration animations.
            // This deliberately passed the current content offset rather than the target.
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        }

        contentOffsetAnimator.startAnimation(fromPoint: scrollView.contentOffset, toPoint: targetContentOffset)
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

        offset.x = max(offset.x, -insets.left)
        offset.y = max(offset.y, -insets.top)
        offset.x = min(offset.x, insets.right + contentSize.width - bounds.width)
        offset.y = min(offset.y, insets.bottom + contentSize.height - bounds.height)

        return offset
    }

    /// Returns the vector by which to change the content offset due to input from a key command. This does not consider the content offset limits.
    func contentOffsetDiffFromKeyCommand(_ keyCommand: UIKeyCommand) -> CGVector {
        guard let direction = directionFromKeyCommand(keyCommand), let step = scrollStepFromKeyCommand(keyCommand, isPaging: isPagingEnabled) else {
            return .zero
        }

        let resolvedDirection = resolvedDirectionFromDirection(direction)

        let viewportScrollSize = bounds.inset(by: adjustedContentInset).insetBy(dx: 0.5 * viewportScrollingOverlapDistance, dy: 0.5 * viewportScrollingOverlapDistance).size

        // Easier to deal with than CGFloat.greatestFiniteMagnitude to avoid overflow.
        let limit: CGFloat = 1e6

        switch (step, resolvedDirection) {
        case (.nudge, .up):       return CGVector(dx: 0, dy: -nudgeDistance)
        case (.nudge, .down):     return CGVector(dx: 0, dy: +nudgeDistance)
        case (.nudge, .left):     return CGVector(dx: -nudgeDistance, dy: 0)
        case (.nudge, .right):    return CGVector(dx: +nudgeDistance, dy: 0)

        case (.viewport, .up):    return CGVector(dx: 0, dy: -viewportScrollSize.height)
        case (.viewport, .down):  return CGVector(dx: 0, dy: +viewportScrollSize.height)
        case (.viewport, .left):  return CGVector(dx: -viewportScrollSize.width, dy: 0)
        case (.viewport, .right): return CGVector(dx: +viewportScrollSize.width, dy: 0)

        case (.page, .up):        return CGVector(dx: 0, dy: -bounds.height)
        case (.page, .down):      return CGVector(dx: 0, dy: +bounds.height)
        case (.page, .left):      return CGVector(dx: -bounds.width, dy: 0)
        case (.page, .right):     return CGVector(dx: +bounds.width, dy: 0)

        case (.end, .up):         return CGVector(dx: 0, dy: -limit)
        case (.end, .down):       return CGVector(dx: 0, dy: +limit)
        case (.end, .left):       return CGVector(dx: -limit, dy: 0)
        case (.end, .right):      return CGVector(dx: +limit, dy: 0)
        }
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

    case .pageUp: return .up
    case .pageDown: return .down
    case .home: return .backwards
    case .end: return .forwards

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

    @objc func kbd_resetZoom(_ keyCommand: UIKeyCommand) {
        setZoomScale(1, animated: true)
    }

    @objc func kbd_zoomIn(_ keyCommand: UIKeyCommand) {
        zoom(isZoomingIn: true)
    }

    @objc func kbd_zoomOut(_ keyCommand: UIKeyCommand) {
        zoom(isZoomingIn: false)
    }

    /// Zooms in or out by one step with animation. Snaps to an even logarithmic scale over the zoom range. Also snaps to a scale of 1.
    private func zoom(isZoomingIn: Bool) {
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
            fatalError("Numbers are broken.")
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

        setZoomScale(targetZoomScale, animated: true)
    }
}

// MARK: - Refreshing

private extension UIScrollView {

    var canRefresh: Bool {
        refreshControl?.allControlEvents.contains(.valueChanged) ?? false
    }

    @objc func kbd_refresh(_ keyCommand: UIKeyCommand) {
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
