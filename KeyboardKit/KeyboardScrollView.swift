// Douglas Hill, November 2019

import UIKit

/// A scroll view that supports scrolling and zooming using a hardware keyboard.
///
/// Behaviour is modelled on `NSScrollView`.
/// Supports arrow keys, ⌥ + arrow keys, ⌘ + arrow keys, space bar, page up, page down, home and end.
///
/// From iOS 17, `UIScrollView` has partial built-in support for keyboard scrolling. This is
/// disabled in KeyboardKit classes because KeyboardKit’s support is more comprehensive.
open class KeyboardScrollView: UIScrollView, ResponderChainInjection {

    /// A key command that enables users to enlarge content in a scroll view.
    ///
    /// Title: Zoom In
    ///
    /// Input: ⌘+ (Users actually press ⌘=. This is implemented by an internally-provided, non-discoverable key command.)
    ///
    /// Recommended location in main menu: View
    ///
    /// Note that the default main menu as of iOS 15 includes a Bigger menu command with the same key input in the
    /// `.textSize` menu. For some reason, `UIMenuBuilder` disallows adding two commands with the same input even if
    /// those commands would be applicable in mutually exclusive contexts. Therefore to include Zoom In in the main
    /// menu the `.textSize` menu must be removed. If you need both text size commands and zooming in different parts
    /// of your app then you probably have to dynamically rebuild the main menu as the first responder moves around.
    public static let zoomInKeyCommand = ScrollViewKeyHandler.zoomInKeyCommand

    /// A key command that enables users to shrink content in a scroll view.
    ///
    /// Title: Zoom Out
    ///
    /// Input: ⌘−
    ///
    /// Recommended location in main menu: View
    ///
    /// Note that the default main menu as of iOS 15 includes a Smaller menu command with the same key input in the
    /// `.textSize` menu. For some reason, `UIMenuBuilder` disallows adding two commands with the same input even if
    /// those commands would be applicable in mutually exclusive contexts. Therefore to include Zoom Out in the main
    /// menu the `.textSize` menu must be removed. If you need both text size commands and zooming in different parts
    /// of your app then you probably have to dynamically rebuild the main menu as the first responder moves around.
    public static let zoomOutKeyCommand = ScrollViewKeyHandler.zoomOutKeyCommand

    /// A key command that enables users to reset a scroll view to a zoom scale of 1.
    ///
    /// Title: Actual Size
    ///
    /// Input: ⌘0
    ///
    /// Recommended location in main menu: View
    public static let actualSizeKeyCommand = ScrollViewKeyHandler.actualSizeKeyCommand

    /// A key command that enables users to refresh content in a scroll view. This is a keyboard equivalent to pull to refresh.
    ///
    /// Title: Refresh
    ///
    /// Input: ⌘R
    ///
    /// Recommended location in main menu: View
    ///
    /// To enable this command, set up pull to refresh in the usual way with the `refreshControl` of a `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardScrollView`  or `KeyboardTextView`.
    public static let refreshKeyCommand = ScrollViewKeyHandler.refreshKeyCommand

    open override var canBecomeFirstResponder: Bool {
        true
    }

    open override var canBecomeFocused: Bool {
        keyHandler.areKeyCommandsEnabled ? true : super.canBecomeFocused
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        if enableScrollViewDelegateInterception {
            delegate = keyHandler
        }
    }

    open override var delegate: UIScrollViewDelegate? {
        get {
            // It may be unexpected that reading this property will not return the object that was set,
            // which is why this is not currently publicly supported.
            super.delegate
        }
        set {
            if enableScrollViewDelegateInterception && newValue !== keyHandler {
                keyHandler.externalDelegate = newValue
            } else {
                super.delegate = newValue
            }
        }
    }

    private lazy var keyHandler = ScrollViewKeyHandler(scrollView: self, owner: self)

    open override var next: UIResponder? {
        keyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        super.next
    }
}
