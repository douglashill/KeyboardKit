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
                becomeFirstResponderOrCrash()
                return true
            } else {
                return false
            }
        }
    }

    // UIKit does an annoying thing where during transitions it returns NO to becomeFirstResponder and then becomes first responder anyway after a delay. I can’t keep the state in sync if that happens.
    func becomeFirstResponderOrCrash() {
        if becomeFirstResponder() {

            // As a POC this is OK.  So I might make this function @objc so it can be overridden.
            // And add a parameter  that trickles down from UIWindow.updateFirstResponder
            // to set whether become 1R should make a selection if none exists.
            // So a view simply appearing does not trigger this.
            // But tab or left/right arrow keys in a split view do.
            // This is getting quite complex for the demo app, but I think that’s the nature of 1R management.
            if
                let collectionView = self as? UICollectionView,
                collectionView.indexPathsForSelectedItems?.isEmpty ?? true
            {
                // This doesn’t call the delegate which is a problem in the triple column example.
                // Because it means when we force this selection in the supplementary, the secondary data is not updated.
//                collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
            }

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

extension KeyboardSplitViewController {
    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? focusedViewController
    }
}
