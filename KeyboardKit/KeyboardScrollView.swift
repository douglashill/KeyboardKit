// Douglas Hill, November 2019

import UIKit

/// A scroll view that supports scrolling and zooming using a hardware keyboard.
/// Behaviour is modelled on `NSScrollView`.
/// Supports arrow keys, ⌥ + arrow keys, ⌘ + arrow keys, space bar, page up, page down, home and end.
open class KeyboardScrollView: UIScrollView, ResponderChainInjection {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var keyHandler = ScrollViewKeyHandler(scrollView: self, owner: self)

    public override var next: UIResponder? {
        keyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        super.next
    }
}
