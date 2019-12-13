// Douglas Hill, December 2019

import UIKit

protocol ResponderChainInjection: NSObjectProtocol {
    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder?
}

class InjectableResponder: UIResponder {
    private unowned var owner: ResponderChainInjection

    init(owner: ResponderChainInjection) {
        self.owner = owner
    }

    override var next: UIResponder? {
        owner.nextResponderForResponder(self)
    }
}
