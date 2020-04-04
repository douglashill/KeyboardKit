// Douglas Hill, November 2019

import UIKit

/// A scroll view that supports scrolling and zooming using a hardware keyboard.
/// Behaviour is modelled on `NSScrollView`.
/// Supports arrow keys, ⌥ + arrow keys, ⌘ + arrow keys, space bar, page up, page down, home and end.
open class KeyboardScrollView: UIScrollView, ResponderChainInjection {

    public override var canBecomeFirstResponder: Bool {
        true
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

    public override var next: UIResponder? {
        keyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        super.next
    }
}
