// Douglas Hill, August 2020

import KeyboardKit

class ListViewController: KeyboardCollectionViewController {
    init() {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.headerMode = .firstItemInSection
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)

        super.init(collectionViewLayout: layout)

        title = "List"
        tabBarItem.image = UIImage(systemName: "list.dash")
        installsStandardGestureForInteractiveMovement = true
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    var windowIWasIn: UIWindow?

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.window?.updateFirstResponder()

        windowIWasIn = view.window
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        windowIWasIn?.updateFirstResponder()
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, String>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

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

        // Implementing this seems to be the minimum needed to enable reordering.
        dataSource.reorderingHandlers.canReorderItem = { _ in
            true
        }

//        dataSource.reorderingHandlers.willReorder = { _ in
//
//        }

//        dataSource.reorderingHandlers.didReorder = { _ in
//
//        }

        self.dataSource = dataSource
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        indexPath.item != 0
    }

    // This is not called. I can delete this. Yeah because this method is frrom the data source and I changed the data source to be the managed one intead of self
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        indexPath.item != 0
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ListViewController(), animated: true)
    }
}
