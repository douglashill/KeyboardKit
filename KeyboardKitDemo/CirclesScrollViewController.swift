// Douglas Hill, December 2019

import UIKit
import KeyboardKit

class CirclesScrollViewController: FirstResponderViewController, UIScrollViewDelegate {
    override var title: String? {
        get { "Scrolling" }
        set {}
    }

    private lazy var scrollView = KeyboardScrollView()
    private lazy var contentView = CirclesView(frame: CGRect(x: 0, y: 0, width: 3000, height: 3000))

    override func loadView() {
        view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.backgroundColor = .white

        scrollView.addSubview(contentView)

        scrollView.delegate = self
        scrollView.maximumZoomScale = 5
        scrollView.minimumZoomScale = 0.5
        scrollView.contentSize = contentView.bounds.size
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // In a real app you’d probably want to re-render. This is fine for a demo app though.
    }
}

private class CirclesView: UIView {
    override var contentMode: UIView.ContentMode {
        get { .redraw }
        set {}
    }

    override func draw(_ rect: CGRect) {
        for _ in 1 ... 150 {
            let randomRadius = CGFloat.random(in: 10...150)
            let insetBounds = bounds.insetBy(dx: randomRadius, dy: randomRadius)
            let randomPoint = CGPoint(x: .random(in: insetBounds.minX...insetBounds.maxX), y: .random(in: insetBounds.minY...insetBounds.maxY))
            let randomColour = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: .random(in: 0.5...1))

            let path = UIBezierPath(ovalIn: CGRect(x: randomPoint.x - randomRadius, y: randomPoint.y - randomRadius, width: 2 * randomRadius, height: 2 * randomRadius))

            randomColour.setFill()
            path.fill()
        }
    }
}
