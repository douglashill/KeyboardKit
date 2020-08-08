// Douglas Hill, July 2020

import UIKit
import KeyboardKit

/// Shows a sidebar list.
///
/// Intended for private use in SplitContainer. Not intended for any other use.
class SidebarViewController: FirstResponderViewController, UICollectionViewDataSource, KeyboardCollectionViewDelegate {
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

        super.init()
    }

    // TODO: it might not like being created with zero frame. Might have to do the initial sizing trick.
    lazy var collectionView: UICollectionView = KeyboardCollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .sidebar)))

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

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

        // TODO: Allow empty selection when the split view is collapsed.

        if let delegate = delegate {
            collectionView.selectItem(at: IndexPath(item: delegate.selectedIndexInSidebarViewController(self), section: 0), animated: false, scrollPosition: [])
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: items[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAtIndex(indexPath.item, inSidebarViewController: self)
    }

    func collectionViewDidChangeSelectedItemsUsingKeyboard(_ collectionView: UICollectionView) {
        // TODO: Don’t do this when the split view is collapsed.
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            delegate?.didSelectItemAtIndex(indexPath.item, inSidebarViewController: self)
        }
    }

    func collectionViewShouldClearSelection(_ collectionView: UICollectionView) -> Bool {
        // TODO: Allow this when the split view is collapsed.
        false
    }
}

protocol SidebarViewControllerDelegate: NSObjectProtocol {
    func didSelectItemAtIndex(_ index: Int, inSidebarViewController sidebarViewController: SidebarViewController)
    func selectedIndexInSidebarViewController(_ sidebarViewController: SidebarViewController) -> Int
}
