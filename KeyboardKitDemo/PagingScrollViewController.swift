// Douglas Hill, December 2019

import UIKit
import KeyboardKit

class PagingScrollViewController: UIViewController {
    override var title: String? {
        get { "Paging" }
        set {}
    }

    lazy var scrollView = KeyboardScrollView()

    let views: [UIView] = ["One", "Two", "Three", "Four", "Five"].map {
        let label = UILabel()
        label.text = $0
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.backgroundColor = .secondarySystemGroupedBackground
        label.layer.borderWidth = 2
        label.layer.cornerRadius = 20
        label.layer.cornerCurve = .continuous
        return label
    }

    override func loadView() {
        view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.backgroundColor = .systemGroupedBackground
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        for view in views {
            scrollView.addSubview(view)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scrollView.contentSize = CGSize(width: CGFloat(views.count) * scrollView.bounds.width, height: scrollView.bounds.height)

        let safeBounds = scrollView.bounds.inset(by: scrollView.safeAreaInsets)

        // TODO: Not bothering with side safe area insets here. Would need to put the whole paging scroll view inside the safe area so it pages the right distance.
        var x: CGFloat = 0
        for view in views {
            view.frame = CGRect(x: x, y: safeBounds.minY, width: scrollView.bounds.width, height: safeBounds.height)
            x += scrollView.bounds.width
        }
    }
}
