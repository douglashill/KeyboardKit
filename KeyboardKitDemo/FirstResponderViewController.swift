// Douglas Hill, December 2019

import UIKit

/// An abstract view controller that makes its view first responder when it appears.
///
/// This is not the most robust way to manage the first responder when there are multiple potential first responder
/// views visible at once (such as with a split view) but this technique is easy and good enough for now.
class FirstResponderViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.becomeFirstResponder()
    }
}
