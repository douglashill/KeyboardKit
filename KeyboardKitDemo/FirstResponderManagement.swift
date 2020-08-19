// Douglas Hill, December 2019

import UIKit
import KeyboardKit

/// An abstract view controller that updates first responder when it appears.
class FirstResponderViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    var windowIWasIn: UIWindow?

    override var canBecomeFirstResponder: Bool {
        true
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        view.window?.updateFirstResponder()
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.window?.updateFirstResponder()

        windowIWasIn = view.window
    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        windowIWasIn?.updateFirstResponder()
//    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        windowIWasIn?.updateFirstResponder()
    }
}

extension UIWindow {
    func updateFirstResponder() {
        precondition(rootViewController!.kd_becomeFirstResponderInHierarchy())
    }
}

extension UIResponder {
    /// An object in the receiver’s responder hierarchy that should become first responder instead
    /// of the receiver. For example a view controller’s view or a view’s subview.
    ///
    /// This should be nil (or just not overridden) if the preferred first responder is the receiver.
    ///
    /// This can be used to implement a kind of reverse responder chain so focus can be given to an expected view.
    /// This mainly exists so the focused side of a split view can be managed and restored.
    @objc var kd_preferredFirstResponderInHierarchy: UIResponder? {
        nil
    }

    /// Asks the responder to either become the first responder or forward this request to a child responder.
    ///
    /// Override to make changes to reflect obtaining focus.
    /// Call super to make sure this is forwarded to `kd_preferredFirstResponderInHierarchy`.
    ///
    /// - Returns: True if the responder or a child became first responder. False if no responder change was made.
    @objc func kd_becomeFirstResponderInHierarchy() -> Bool {
        if let preferredFirstResponderInHierarchy = kd_preferredFirstResponderInHierarchy,
           preferredFirstResponderInHierarchy.kd_becomeFirstResponderInHierarchy() {
            return true
        } else {
            if canBecomeFirstResponder {
                becomeFirstResponderOrCrash()
                return true
            } else {
                return false
            }
        }
    }

    // UIKit does an annoying thing where during transitions it returns NO to becomeFirstResponder and then becomes first responder anyway after a delay. I can’t keep the state in sync if that happens.
    func becomeFirstResponderOrCrash() {
        precondition(becomeFirstResponder(), "Could not become first responder.")
    }
}

extension UIViewController {
    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? view
    }
}

extension UINavigationController {
    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        visibleViewController // This already checks for presentedViewController.
    }
}

extension UITabBarController {
    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? selectedViewController
    }
}

extension KeyboardSplitViewController {
    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? (focusedColumn != nil ? viewController(for: focusedColumn!) : nil)
    }
}

extension PartialParentViewController {
    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? childViewController
    }
}
