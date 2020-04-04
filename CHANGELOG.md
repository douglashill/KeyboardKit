# KeyboardKit change log

- 2020-04-26
    - Breaking change: KeyboardKit scroll views will no longer send their delegate `scrollViewDidEndScrollingAnimation(_:)` after keyboard-driven animations end. Instead, the scroll view’s delegate can conform to `KeyboardScrollingDelegate` to receive callbacks when keyboard-driven scrolling animations start or finish.
- 2020-04-05
    - Fixes scroll views with `isPagingEnabled` set ending up off page boundaries if starting keyboard scrolling while the scrolling view was in-between pages while decelerating from touch scrolling.
- 2020-04-04
    - Changes Page Up and Page Down to semantic directions so they will scroll horizontally in a scroll view that can only scroll horizontally.
    - Fixes keyboard scrolling resulting in an incorrect scroll position when content size is smaller than the bounds (seen as unwanted scrolling in the non-scrolling direction).
