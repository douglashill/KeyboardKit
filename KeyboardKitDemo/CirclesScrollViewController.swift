// Douglas Hill, December 2019

import UIKit
import KeyboardKit

class CirclesScrollViewController: UIViewController {
    override var title: String? {
        get { "Scroll View" }
        set {}
    }

    lazy private var scrollView = KeyboardScrollView()
    lazy private var contentView = CirclesView(frame: CGRect(x: 0, y: 0, width: 3000, height: 3000))

    override func loadView() {
        view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.backgroundColor = .white

        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
    }
}

private class CirclesView: UIView {
    override var contentMode: UIView.ContentMode {
        get { .redraw }
        set {}
    }

    override func draw(_ rect: CGRect) {
        UIColor.blue.setStroke()

        let initialLength: CGFloat = 20
        var circleFrame = CGRect(x: bounds.midX - initialLength / 2, y: bounds.midY - initialLength / 2, width: initialLength, height: initialLength)

        while circleFrame.contains(bounds) == false {
            let path = UIBezierPath(ovalIn: circleFrame)
            path.lineWidth = 5
            path.stroke()

            circleFrame = circleFrame.insetBy(dx: -20, dy: -20)
        }
    }
}
