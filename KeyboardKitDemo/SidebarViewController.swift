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

    // TODO: Clear the selection when collapsing.
    // TODO: Activate the selection (show detail VC) when expanding.

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let delegate = delegate, delegate.shouldRequireSelectionInSidebarViewController(self) {
            collectionView.selectItem(at: IndexPath(item: delegate.selectedIndexInSidebarViewController(self), section: 0), animated: false, scrollPosition: [])
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: items[indexPath.item])
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didActivateSelectionAtIndex(indexPath.item, inSidebarViewController: self)
    }

    // MARK: - KeyboardCollectionViewDelegate

    func collectionViewDidChangeSelectedItemsUsingKeyboard(_ collectionView: UICollectionView) {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            delegate?.didShowSelectionAtIndex(indexPath.item, inSidebarViewController: self)
        }
    }

    func collectionViewShouldClearSelection(_ collectionView: UICollectionView) -> Bool {
        if let delegate = delegate {
            return delegate.shouldRequireSelectionInSidebarViewController(self) == false
        } else {
            return true
        }
    }
}

// MARK: -

protocol SidebarViewControllerDelegate: NSObjectProtocol {
    /// Called when the selected item in the sidebar changes using arrow keys.
    func didShowSelectionAtIndex(_ index: Int, inSidebarViewController sidebarViewController: SidebarViewController)

    /// Called when the user taps an item or uses space or return to activate the item that was previously selected using arrow keys.
    func didActivateSelectionAtIndex(_ index: Int, inSidebarViewController sidebarViewController: SidebarViewController)

    /// Whether the sidebar must have an item selected. I.e. it does not allow an empty selection.
    func shouldRequireSelectionInSidebarViewController(_ sidebarViewController: SidebarViewController) -> Bool

    /// The index of the selected item if the sidebar.
    /// This is only used if the sidebar is required to have a selection due to `shouldRequireSelectionInSidebarViewController`.
    func selectedIndexInSidebarViewController(_ sidebarViewController: SidebarViewController) -> Int
}
