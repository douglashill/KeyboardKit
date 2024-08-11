// Douglas Hill, December 2019

import UIKit
import KeyboardKit

/// Posted by the object that became first responder after calling `UIWindow.updateFirstResponder`.
let firstResponderDidChangeNotification = Notification.Name("KBDFirstResponderDidChange")

/// An abstract view controller that updates first responder when it appears.
class FirstResponderViewController: InitialiserClearingViewController {
    init() {
        super.init(onMainActor: ())
    }

    var windowIWasIn: UIWindow?

    override var canBecomeFirstResponder: Bool {
        if UIFocusSystem(for: self) != nil {
            // If we return true here then focus is lost when pushing in TableViewController and ListViewController.
            return super.canBecomeFirstResponder
        } else {
            return true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.window?.updateFirstResponder()

        windowIWasIn = view.window
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        windowIWasIn?.updateFirstResponder()
        windowIWasIn = nil
    }
}

extension UIWindow {
    func updateFirstResponder() {
        if UIFocusSystem(for: self) == nil {
            rootViewController!.kd_becomeFirstResponderInHierarchy()
        }
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
    @discardableResult @objc func kd_becomeFirstResponderInHierarchy() -> Bool {
        if let preferredFirstResponderInHierarchy = kd_preferredFirstResponderInHierarchy,
           preferredFirstResponderInHierarchy.kd_becomeFirstResponderInHierarchy() {
            return true
        } else {
            // For views and view controllers where the view not added to a window, canBecomeFirstResponder will return true
            // but becomeFirstResponder will return false, so let’s avoid that when state callbacks occur during setup.
            var isSetUp: Bool {
                if let view = self as? UIView {
                    return view.window != nil
                } else if let viewController = self as? UIViewController {
                    return viewController.viewIfLoaded?.window != nil
                } else {
                    return true
                }
            }

            if canBecomeFirstResponder && isSetUp {
                reallyBecomeFirstResponder()
                return true
            } else {
                return false
            }
        }
    }

    /// UIKit does an annoying thing where during transitions it returns NO to becomeFirstResponder
    /// and then becomes first responder anyway after a delay. It’s hard to be in control of what’s
    /// going on if that happens, so such situations should be caught and fixed up.
    func reallyBecomeFirstResponder() {
        if becomeFirstResponder() {
            NotificationCenter.default.post(name: firstResponderDidChangeNotification, object: self)
            return
        }
        print("❌ Could not become first responder: \(self)")
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
        // This won’t work if there is a More tab. The selectedViewController might be a navigation controller
        // but that isn’t actually present in the VC hierarchy because the child of the navigation controller
        // will be extracted and pushed onto the UIMoreNavigationController.
        presentedViewController ?? selectedViewController
    }
}
