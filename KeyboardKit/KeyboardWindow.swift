// Douglas Hill, December 2019

import UIKit

/// A window that supports using escape on a hardware keyboard to dismiss any topmost modal sheet or popover.
/// Calls the presentation controller delegate like for any other user-driven dismissal.
open class KeyboardWindow: UIWindow {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var dismissKeyCommands = [
        UIKeyCommand(.escape, action: #selector(kbd_dismissTopmostModalViewIfPossible)),
        UIKeyCommand((.command, "W"), action: #selector(kbd_dismissTopmostModalViewIfPossible)),
    ]

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        commands += dismissKeyCommands

        return commands
    }

    @objc func kbd_dismissTopmostModalViewIfPossible(_ sender: Any?) {
        guard
            let topmost = topmostViewController,
            topmost.isBeingPresented == false && topmost.isBeingDismissed == false,
            topmost.modalPresentationStyle.isDismissibleWithoutConfirmation
        else {
            return
        }

        let presentationController = topmost.presentationController!

        guard
            topmost.isModal == false,
            delegateSaysPresentationControllerShouldDismiss(presentationController)
        else {
            tellDelegatePresentationControllerDidAttemptToDismiss(presentationController)
            return
        }

        tellDelegatePresentationControllerWillDismiss(presentationController)
        topmost.presentingViewController!.dismiss(animated: true) {
            tellDelegatePresentationControllerDidDismiss(presentationController)
        }
    }

    private var topmostViewController: UIViewController? {
        guard var viewController = rootViewController?.presentedViewController else {
            return nil
        }
        while let presentedViewController = viewController.presentedViewController {
            viewController = presentedViewController
        }
        return viewController
    }
}

private func delegateSaysPresentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
    // TODO: Verify this matches what UIKit does. Not yet documented so should find by experimentation.

    if #available(iOS 13, *), let should = presentationController.delegate?.presentationControllerShouldDismiss?(presentationController) {
        return should
    }

    // Since Catalyst did not start until iOS 13 this warns even though the deployment target is iOS 12.
    #if !targetEnvironment(macCatalyst)
    if
        let popoverPresentationController = presentationController as? UIPopoverPresentationController,
        let should = popoverPresentationController.delegate?.popoverPresentationControllerShouldDismissPopover?(popoverPresentationController)
    {
        return should
    }
    #endif

    return true
}

private func tellDelegatePresentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
    if #available(iOS 13, *) {
        presentationController.delegate?.presentationControllerDidAttemptToDismiss?(presentationController)
    }
}

private func tellDelegatePresentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    if #available(iOS 13, *) {
        presentationController.delegate?.presentationControllerWillDismiss?(presentationController)
    }
}

private func tellDelegatePresentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    // TODO: Verify whether UIKit calls both if both are implemented or whether it stops after the first one is implemented.

    if #available(iOS 13, *) {
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }

    // Since Catalyst did not start until iOS 13 this warns even though the deployment target is iOS 12.
    #if !targetEnvironment(macCatalyst)
    if let popoverPresentationController = presentationController as? UIPopoverPresentationController {
        popoverPresentationController.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController)
    }
    #endif
}

private extension UIModalPresentationStyle {
    /// Whether the style itself allows the user to dismiss the presented view controller.
    var isDismissibleWithoutConfirmation: Bool {
        switch self {
        case .automatic:
            preconditionFailure("UIKit should have resolved automatic to a concrete style.")
        case .popover:
            return true
        case .pageSheet, .formSheet:
            if #available(iOS 13, *) {
                return true
            } else {
                return false
            }
        case .fullScreen, .currentContext, .custom, .overFullScreen, .overCurrentContext, .none: fallthrough @unknown default:
            return false
        }
    }
}

private extension UIViewController {
    /// Same as `isModalInPresentation` on iOS 13 and later, or `isModalInPopover` on earlier versions.
    var isModal: Bool {
        if #available(iOS 13, *) {
            return isModalInPresentation
        } else {
            return isModalInPopover
        }
    }
}
