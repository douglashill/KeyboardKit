// Douglas Hill, November 2019

import UIKit

/// A scroll view that supports scrolling using a hardware keyboard like `NSScrollView`.
/// Supports arrow keys, option + arrow keys, command + arrow keys, space bar, page up, page down, home and end.
/// Limitations:
/// - The scroll view must become its own delegate so setting the delegate is not supported yet.
/// - Does not consider zooming. This has not been tested at all.
public class KeyboardScrollView: UIScrollView, UIScrollViewDelegate {

    // MARK: - Key commands

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        guard isScrollEnabled else {
            return commands
        }

        commands += [UIKeyCommand.inputUpArrow, UIKeyCommand.inputDownArrow, UIKeyCommand.inputLeftArrow, UIKeyCommand.inputRightArrow].flatMap { input -> [UIKeyCommand] in
            [UIKeyModifierFlags(), .alternate, .command].map { modifierFlags in
                UIKeyCommand(input: input, modifierFlags: modifierFlags, action: #selector(scrollFromKeyCommand))
            }
        }

        commands += [
            UIKeyCommand(input: " ", modifierFlags: [], action: #selector(scrollFromKeyCommand)),
            UIKeyCommand(input: " ", modifierFlags: .shift, action: #selector(scrollFromKeyCommand)),
            UIKeyCommand(input: keyInputPageUp, modifierFlags: [], action: #selector(scrollFromKeyCommand)),
            UIKeyCommand(input: keyInputPageDown, modifierFlags: [], action: #selector(scrollFromKeyCommand)),
            UIKeyCommand(input: keyInputHome, modifierFlags: [], action: #selector(scrollFromKeyCommand)),
            UIKeyCommand(input: keyInputEnd, modifierFlags: [], action: #selector(scrollFromKeyCommand)),
        ]

        return commands
    }

    @objc private func scrollFromKeyCommand(_ keyCommand: UIKeyCommand) {
        let diff = contentOffsetDiffFromKeyCommand(keyCommand)
        let target = boundedContentOffsetFromProposedContentOffset(startingContentOffsetForAnimation + diff)

        if target != startingContentOffsetForAnimation {
            setContentOffset(target, animated: true)
            flashScrollIndicators()
        }
    }

    // MARK: - Allowing animations to be redirected

    /// The content offsets the scroll view is heading towards in animations.
    ///
    /// When no animation is happening, this array will be empty.
    /// When an animation is in-flight, there will be one offset in this array.
    ///
    /// At the point when an animation is being added while an existing animation is in progress,
    /// there will briefly be two offsets in this array. The first offset is for the animation
    /// that is ending (early) and the second offset is the new animation being started.
    private var currentAnimationsTargetContentOffsets: [CGPoint] = []

    /// The content offset that should be used as a base when starting an animation to account for in-flight animations.
    private var startingContentOffsetForAnimation: CGPoint {
        return currentAnimationsTargetContentOffsets.last ?? contentOffset
    }

    public override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        currentAnimationsTargetContentOffsets.append(contentOffset)
        super.setContentOffset(contentOffset, animated: animated)
    }

    // MARK: - Delegate handling

    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    /// Initialisation common to both designated initialisers.
    private func sharedInit() {
        super.delegate = self
    }

    public override var delegate: UIScrollViewDelegate? {
        get {
            super.delegate
        }
        set {
            if newValue == nil {
                // This happens during deallocation so don’t assert in this case.
                super.delegate = newValue
            } else {
                // TODO: Support setting the delegate.
                fatalError("Setting the delegate is not supported. Needs a bunch of code forwarding methods. Contributions to fix this are welcome.")
            }
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === self else {
            return
        }

        currentAnimationsTargetContentOffsets.removeFirst()
    }

    // MARK: - Determining where to scroll to

    /// Restricts a proposed content offset to lie within limits of the scroll view content size.
    private func boundedContentOffsetFromProposedContentOffset(_ proposedContentOffset: CGPoint) -> CGPoint {
        let insets = adjustedContentInset
        var offset = proposedContentOffset

        offset.x = max(offset.x, -insets.left)
        offset.y = max(offset.y, -insets.top)
        offset.x = min(offset.x, insets.right + contentSize.width - bounds.width)
        offset.y = min(offset.y, insets.bottom + contentSize.height - bounds.height)

        return offset
    }

    /// Returns the vector by which to change the content offset due to input from a key command. This does not consider the content offset limits.
    private func contentOffsetDiffFromKeyCommand(_ keyCommand: UIKeyCommand) -> CGVector {
        guard let direction = directionFromKeyCommand(keyCommand), let step = scrollStepFromKeyCommand(keyCommand, isPaging: isPagingEnabled) else {
            return .zero
        }

        let resolvedDirection = resolvedDirectionFromDirection(direction)

        // TODO: Have not considered zooming yet.
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

    /// Distance in points to scroll with a regular arrow key press.
    private var nudgeDistance: CGFloat {
        UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).pointSize * 3
    }

    /// This distance in points is subtracted from the visible width/height when scrolling by `ScrollStep.viewport`.
    private var viewportScrollingOverlapDistance: CGFloat {
        nudgeDistance
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
        // TODO: Consider zooming.
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
    switch keyCommand.input {

    case UIKeyCommand.inputUpArrow: return .up
    case UIKeyCommand.inputDownArrow: return .down
    case UIKeyCommand.inputLeftArrow: return .left
    case UIKeyCommand.inputRightArrow: return .right

    case " ": return keyCommand.modifierFlags.contains(.shift) ? .backwards : .forwards

    case keyInputPageUp: return .up
    case keyInputPageDown: return .down
    case keyInputHome: return .backwards
    case keyInputEnd: return .forwards

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
    switch keyCommand.input {

    case UIKeyCommand.inputUpArrow, UIKeyCommand.inputDownArrow, UIKeyCommand.inputLeftArrow, UIKeyCommand.inputRightArrow:
        return scrollStepForArrowKeyWithModifierFlags(keyCommand.modifierFlags, isPaging: isPaging)

    case " ", keyInputPageUp, keyInputPageDown:
        return isPaging ? .page : .viewport

    case keyInputHome, keyInputEnd:
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

private func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

// These were found in the open source WebKit.
private let keyInputPageUp = "UIKeyInputPageUp"
private let keyInputPageDown = "UIKeyInputPageDown"
// These were found by guessing.
private let keyInputHome = "UIKeyInputHome"
private let keyInputEnd = "UIKeyInputEnd"
