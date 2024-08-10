// Douglas Hill, July 2020

import UIKit
import KeyboardKit

/// Shows a sidebar list.
///
/// Intended for private use in `DoubleColumnSplitViewController`.
class SidebarViewController: FirstResponderViewController, UICollectionViewDataSource, KeyboardCollectionViewDelegate {
    init(items: [(String, UIImage?)]) {
        self.items = items

        super.init()
    }

    /// The data displayed by the list as an array of the text and image for each item.
    let items: [((String, UIImage?))]

    /// The delegate to be notified when the selection changes in the list and to provide details about what the selection should be.
    weak var delegate: SidebarViewControllerDelegate?

    private lazy var collectionView = KeyboardCollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .sidebar)))

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.accessibilityIdentifier = "sidebar"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController!.navigationBar.prefersLargeTitles = true
        // Fix large title not being shown until the user scrolls a little bit. Thanks to https://stackoverflow.com/a/53165371
        navigationController!.navigationBar.sizeToFit()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This seems the most robust way to ensure the collection view always has a selected item when required.
        if let delegate = delegate, delegate.shouldRequireSelectionInSidebarViewController(self) {
            collectionView.selectItem(at: IndexPath(item: delegate.selectedIndexInSidebarViewController(self), section: 0), animated: false, scrollPosition: [])
        }
    }

    func clearSelection() {
        collectionView.selectItem(at: nil, animated: false, scrollPosition: [])
    }

    private let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ((String, UIImage?))> { cell, indexPath, item in
        cell.contentConfiguration = {
            var config = cell.defaultContentConfiguration()
            config.text = item.0
            config.image = item.1
            return config
        }()
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

    // This provides a little bit of extra polish. This prevents the focus becoming detached from the
    // selection, since that would look confusing. It also means that when the sidebar is overlaid on top
    // of the detail view, we update the detail view underneath immediately as the arrow keys change focus.
    // We can’t use selectionFollowsFocus because that would push the detail view controller (compact
    // widths) or hide the overlaid sidebar (medium widths) every time you press the up or down arrows.
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn focusUpdateContext: UICollectionViewFocusUpdateContext, with animationCoordinator: UIFocusAnimationCoordinator) {
        if let indexPath = focusUpdateContext.nextFocusedIndexPath {
            delegate?.didShowSelectionAtIndex(indexPath.item, inSidebarViewController: self)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }

    // MARK: - KeyboardCollectionViewDelegate

    func collectionViewDidChangeSelectedItemsUsingKeyboard(_ collectionView: UICollectionView) {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            delegate?.didShowSelectionAtIndex(indexPath.item, inSidebarViewController: self)
        }
    }

    func collectionViewShouldClearSelectionUsingKeyboard(_ collectionView: UICollectionView) -> Bool {
        if let delegate {
            return delegate.shouldRequireSelectionInSidebarViewController(self) == false
        } else {
            return true
        }
    }
}

// MARK: -

/// An object to assist with managing the selection in a sidebar.
@MainActor protocol SidebarViewControllerDelegate: NSObjectProtocol {
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
