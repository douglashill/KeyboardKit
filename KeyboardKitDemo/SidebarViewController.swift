// Douglas Hill, July 2020

import UIKit
import KeyboardKit

/// Shows a sidebar list.
///
/// Intended for private use in SidebarAndTabBarController. Not intended for any other use.
class SidebarViewController: KeyboardCollectionViewController {
    let items: [((String, UIImage?))]
    weak var delegate: SidebarViewControllerDelegate?

    // TODO: Make image required again by setting an image on all the content VCs.

    private lazy var cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ((String, UIImage?))> { cell, indexPath, item in
        cell.contentConfiguration = {
            var config = cell.defaultContentConfiguration()
            config.text = item.0
            config.image = item.1
            return config
        }()
    }

    init(items: [(String, UIImage?)]) {
        self.items = items

        let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .sidebar))
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController!.navigationBar.prefersLargeTitles = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Without this after going from 50% split to major split on 11-inch iPad in landscape, the view
        // appears about 100 points wide (with a big black region to the right) until you first scroll.
        let originalFrame = navigationController!.view.frame
        var frame = originalFrame
        frame.size.width += 1
        navigationController!.view.frame = frame
        navigationController!.view.frame = originalFrame
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.selectItem(at: IndexPath(item: delegate!.selectedIndexInSidebarViewController(self), section: 0), animated: false, scrollPosition: [])
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: items[indexPath.item])
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAtIndex(indexPath.item, inSidebarViewController: self)
    }
}

protocol SidebarViewControllerDelegate: NSObjectProtocol {
    func didSelectItemAtIndex(_ index: Int, inSidebarViewController sidebarViewController: SidebarViewController)
    func selectedIndexInSidebarViewController(_ sidebarViewController: SidebarViewController) -> Int
}
