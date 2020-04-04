// Douglas Hill, April 2020

import UIKit

/// A scroll view’s `delegate` can conform to this protocol to receive callbacks about keyboard-driven scrolling animations.
///
/// This can be used with any scrolling component from KeyboardKit: `KeyboardScrollView`, `KeyboardTableView`,
/// `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` or `KeyboardTextView`.
///
/// When an animation is interrupted by a new keyboard event, the delegate will receive
/// willBegin for the new animation before receiving didEnd for the animation being cancelled.
///
/// If it conforms to `KeyboardScrollingDelegate`, the scroll view’s delegate will receive
/// `willBeginKeyboardScrollingAnimation(toContentOffset:inScrollView:)` and
/// `didEndKeyboardScrollingAnimation(inScrollView:)` when keyboard-driven scrolling animations begin and end.
///
/// The delegate will not receive `scrollViewDidEndScrollingAnimation(_:)` callbacks due to keyboard scrolling.
public protocol KeyboardScrollingDelegate: UIScrollViewDelegate {
    /// Called at the start of a scrolling animation that is occurring due to a keyboard event.
    /// - Parameters:
    ///   - targetContentOffset: The content offset the animation will end at if not interrupted.
    ///   - scrollView: The scroll view that is being scrolled.
    func willBeginKeyboardScrollingAnimation(toContentOffset targetContentOffset: CGPoint, inScrollView scrollView: UIScrollView)
    /// Called at the end of a scrolling animation that occurred due to a keyboard event.
    /// - Parameters:
    ///   - scrollView: The scroll view that was scrolled.
    ///   - isFinished: Whether the animation reached it’s target content offset. This will be false if the animation was interrupted.
    func didEndKeyboardScrollingAnimation(inScrollView scrollView: UIScrollView, isFinished: Bool)
}
