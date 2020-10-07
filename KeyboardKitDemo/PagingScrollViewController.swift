// Douglas Hill, December 2019

import UIKit
import KeyboardKit

class PagingScrollViewController: FirstResponderViewController {
    override init() {
        super.init()
        title = "Paging"
        tabBarItem.image = UIImage(systemName: "book")
    }

    lazy var scrollView = KeyboardScrollView()

    let views: [UIView] = [
        "1. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin tincidunt sapien non velit malesuada, pharetra lobortis mauris fermentum. Maecenas tempus ligula sit amet dapibus facilisis. Proin gravida sit amet nibh ut imperdiet. Sed ullamcorper auctor est sed iaculis. Nulla dolor nisi, molestie dapibus iaculis quis, molestie eu augue. Praesent sapien metus, posuere quis dignissim nec, mattis in ipsum. Phasellus finibus ante volutpat vehicula volutpat.",
        "2. Nulla a efficitur eros. Mauris efficitur libero risus, non sagittis nunc lobortis semper. Nam ultricies non odio eget efficitur. Nullam egestas elit vel augue suscipit, non cursus ex pharetra. Nulla aliquam enim eu elit eleifend fringilla. Sed vel pellentesque ante. Vestibulum gravida velit diam, a sodales enim posuere vitae",
        "3. Cras condimentum lacus id dolor mollis lacinia. Mauris vehicula vehicula massa, tincidunt dapibus lectus. Curabitur condimentum tincidunt felis, vitae convallis libero finibus non. Nullam non elit at dolor consectetur tincidunt nec ac odio. Vivamus aliquam faucibus nunc consectetur consequat. Vestibulum magna elit, vestibulum in lorem eu, ultricies condimentum nisi. Ut fringilla metus vitae pellentesque hendrerit. Ut feugiat, lacus nec mollis aliquam, ante magna sodales est, ac faucibus lectus leo quis nibh.",
        "4. Donec ornare dolor et lorem ultricies lacinia. Praesent rutrum eget mi vitae consectetur. Curabitur venenatis fermentum porta. Sed imperdiet dignissim interdum. Cras eu lacinia lorem. Nunc mollis nunc ut pellentesque feugiat. Fusce rhoncus tincidunt elementum.",
        "5. Proin bibendum vulputate imperdiet. Nunc accumsan consectetur enim at dictum. Sed luctus rutrum mi, sit amet ullamcorper odio fringilla id. Vivamus placerat imperdiet pharetra. Integer non interdum tellus, vitae maximus nisi. Maecenas quis malesuada tortor. Maecenas cursus diam vel erat aliquet, quis varius quam imperdiet. Sed vehicula, libero non sodales pulvinar, nisi elit tempus massa, non venenatis justo nisi vitae nunc. Sed sodales odio at nunc rhoncus malesuada.",
    ].map {
        let label = UILabel()
        label.text = $0
        label.numberOfLines = 0
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

        updateColours()
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColours()
        }
    }

    private func updateColours() {
        for view in views {
            view.layer.borderColor = UIColor.label.cgColor
        }
    }
}
