// Douglas Hill, December 2019

import UIKit
import KeyboardKit

class CirclesScrollViewController: FirstResponderViewController, UIScrollViewDelegate {
    override init() {
        super.init()
        title = "Scrolling"
        tabBarItem.image = UIImage(systemName: "circle.grid.hex")
    }

    private lazy var scrollView = KeyboardScrollView()
    private lazy var contentView = CirclesView(frame: CGRect(x: 0, y: 0, width: 2500, height: 2500))

    override func loadView() {
        view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.backgroundColor = .systemBackground

        scrollView.addSubview(contentView)

        scrollView.delegate = self
        scrollView.maximumZoomScale = 5
        scrollView.minimumZoomScale = 0.5
        scrollView.contentSize = contentView.bounds.size

        // Disable the navigation bar background disappearing when scrolling to the top because that looks bad in this case.
        navigationController!.navigationBar.scrollEdgeAppearance = navigationController!.navigationBar.standardAppearance
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
        for _ in 1 ... 100 {
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
