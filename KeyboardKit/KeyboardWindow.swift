// Douglas Hill, December 2019

import UIKit

/// A window that supports using escape on a hardware keyboard to dismiss any topmost modal sheet or popover.
/// Calls the presentation controller delegate like for any other user-driven dismissal.
open class KeyboardWindow: UIWindow {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var dismissKeyCommand = UIKeyCommand(UIKeyCommand.inputEscape, action: #selector(kbd_dismissTopmostModalViewIfPossible))

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        commands.append(dismissKeyCommand)

        return commands
    }
}

private extension UIWindow {

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
            presentationController.delegate?.presentationControllerShouldDismiss?(presentationController) ?? true
        else {
            presentationController.delegate?.presentationControllerDidAttemptToDismiss?(presentationController)
            return
        }

        presentationController.delegate?.presentationControllerWillDismiss?(presentationController)
        topmost.presentingViewController!.dismiss(animated: true) {
            presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
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

private extension UIModalPresentationStyle {
    /// Whether the style itself allows the user to dismiss the presented view controller.
    var isDismissibleWithoutConfirmation: Bool {
        switch self {
        case .automatic:
            fatalError("UIKit should have resolved automatic to a concrete style.")
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
