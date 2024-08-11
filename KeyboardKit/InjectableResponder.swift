// Douglas Hill, December 2019

import UIKit

@MainActor protocol ResponderChainInjection: NSObjectProtocol {
    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder?
}

class InjectableResponder: UIResponder {
    private unowned var owner: ResponderChainInjection

    init(owner: ResponderChainInjection) {
        self.owner = owner
        super.init()
    }

    override var next: UIResponder? {
        owner.nextResponderForResponder(self)
    }
}
