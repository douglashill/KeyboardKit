// Douglas Hill, August 2020

import UIKit
import KeyboardKit

/// Manages a view that shows list of strings set using the `data` property. Intended for use in `TripleColumnSplitViewController`.
class TripleColumnListViewController: FirstResponderViewController, UICollectionViewDelegate, KeyboardCollectionViewDelegate {
    init(appearance: UICollectionLayoutListConfiguration.Appearance) {
        self.appearance = appearance
        super.init()
    }

    let appearance: UICollectionLayoutListConfiguration.Appearance
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>? = nil

    weak var delegate: TripleColumnListViewControllerDelegate?

    private lazy var collectionView: UICollectionView = {
        var listConfig = UICollectionLayoutListConfiguration(appearance: appearance)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return KeyboardCollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    var selectedIndex = 0

    private func updateSelectedIndexFromCollectionView() {
        selectedIndex = collectionView.indexPathsForSelectedItems?.first?.item ?? 0
    }

    override func loadView() {
        // If the collection view starts off with zero frame is briefly shows as black when appearing.
        // I’ve only seen this happen with lists using UICollectionView, not in other compositional layouts.
        super.loadView() // Hack: Load the default view to get the initial frame from UIKit.
        let initialFrame = view.frame
        view = collectionView
        collectionView.frame = initialFrame
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, stringItem in
            cell.contentConfiguration = {
                var config = cell.defaultContentConfiguration()
                config.text = stringItem
                config.secondaryText = "The detail text goes here."
                config.image = UIImage(systemName: "star")
                return config
            }()

            cell.accessories = [.disclosureIndicator()]
        }

        let dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { collectionView, indexPath, identifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        reloadDataWithDataSource(dataSource)

        self.dataSource = dataSource
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0), animated: false, scrollPosition: [])
    }

    var data: [String] = [] {
        didSet {
            if let dataSource = dataSource {
                reloadDataWithDataSource(dataSource)
            }
        }
    }

    private func reloadDataWithDataSource(_ dataSource: UICollectionViewDiffableDataSource<Int, String>) {
        dataSource.apply({
            var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
            snapshot.appendSections([0])
            snapshot.appendItems(data)
            return snapshot
        }(), animatingDifferences: false)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateSelectedIndexFromCollectionView()
        delegate?.didChangeSelectedItemsInListViewController(self, isExplicitActivation: true)
    }

    // MARK: - KeyboardCollectionViewDelegate

    func collectionViewDidChangeSelectedItemsUsingKeyboard(_ collectionView: UICollectionView) {
        updateSelectedIndexFromCollectionView()
        delegate?.didChangeSelectedItemsInListViewController(self, isExplicitActivation: false)
    }

    func collectionViewShouldClearSelectionUsingKeyboard(_ collectionView: UICollectionView) -> Bool {
        // Not allowing clearing selection feels better for sidebars because usually want
        // to force something to be selected. This also means the user can dismiss an
        // overlaid or displacing sidebar with one press of the escape key instead of two.
        false
    }
}

protocol TripleColumnListViewControllerDelegate: NSObjectProtocol {
    func didChangeSelectedItemsInListViewController(_ listViewController: TripleColumnListViewController, isExplicitActivation: Bool)
}
