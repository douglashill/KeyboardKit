// Douglas Hill, August 2020

import KeyboardKit

class ListViewController: FirstResponderViewController, UICollectionViewDelegate {
    override init() {
        super.init()
        title = "List"
        tabBarItem.image = UIImage(systemName: "list.dash")
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, String>? = nil

    private lazy var collectionView: UICollectionView = {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.headerMode = .firstItemInSection
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return KeyboardCollectionView(frame: .zero, collectionViewLayout: layout)
    }()

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
        collectionView.accessibilityIdentifier = "list collection view"

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, stringItem in
            let isHeader = indexPath.item == 0

            cell.contentConfiguration = {
                var config = cell.defaultContentConfiguration()
                config.text = stringItem
                if isHeader == false {
                    config.secondaryText = "The detail text goes here."
                    config.image = UIImage(systemName: "star")
                }
                return config
            }()

            cell.accessories = isHeader ? [] : [.disclosureIndicator()]
        }

        let dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { collectionView, indexPath, identifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut

        let items = Array(1...40).map { formatter.string(from: NSNumber(value: $0))!.localizedCapitalized }

        dataSource.apply({
            var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
            snapshot.appendSections([0, 1, 2])
            return snapshot
        }(), animatingDifferences: false)

        dataSource.apply({
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
            sectionSnapshot.append(["Section 1"])
            sectionSnapshot.append(Array(items[0..<12]))
            return sectionSnapshot
        }(), to: 0)

        dataSource.apply({
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
            sectionSnapshot.append(["Section 2"])
            sectionSnapshot.append(Array(items[12..<26]))
            return sectionSnapshot
        }(), to: 1)

        dataSource.apply({
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
            sectionSnapshot.append(["Section 3"])
            sectionSnapshot.append(Array(items[26...]))
            return sectionSnapshot
        }(), to: 2)

        self.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard isFocusSystemEnabled else {
            return
        }

        // When dropping iOS 14 (so first responder management is no longer necessary) it would be good to swap the
        // superclass to UICollectionViewController because that handles deselection on appearing automatically.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.selectItem(at: nil, animated: true, scrollPosition: [])
        }
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        indexPath.item != 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ListViewController(), animated: true)
    }
}
