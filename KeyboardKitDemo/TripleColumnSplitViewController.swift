// Douglas Hill, August 2020

import UIKit
import KeyboardKit

class TripleColumnSplitViewController: UIViewController, KeyboardSplitViewControllerDelegate {
    private let innerSplitViewController: KeyboardSplitViewController

    @available(*, unavailable) override var splitViewController: UISplitViewController? { nil }
    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    init() {
        innerSplitViewController = KeyboardSplitViewController(style: .tripleColumn)

        // The primary would ideally use the sidebar style, but as of Xcode 12 beta 4 using the
        // sidebar style in the primary column results in a crash as soon as the view appears:
        // *** Assertion failure in -[UIListContentConfiguration _enforcesMinimumHeight], UIListContentConfiguration.m:470
        // Unknown style: 10
        let primaryList = ListViewController(appearance: .insetGrouped)
        let supplementaryList = ListViewController(appearance: .sidebarPlain)
        let secondaryList = ListViewController(appearance: .insetGrouped)

        primaryList.title = "Primary"
        supplementaryList.title = "Supplementary"
        secondaryList.title = "Secondary"

        innerSplitViewController.setViewController(KeyboardNavigationController(rootViewController: primaryList), for: .primary)
        innerSplitViewController.setViewController(KeyboardNavigationController(rootViewController: supplementaryList), for: .supplementary)
        innerSplitViewController.setViewController(KeyboardNavigationController(rootViewController: secondaryList), for: .secondary)

        super.init(nibName: nil, bundle: nil)

        innerSplitViewController.delegate = self

        addChild(innerSplitViewController)
        innerSplitViewController.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(innerSplitViewController.view)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        innerSplitViewController.view.frame = view.bounds
    }

    // MARK: - KeyboardSplitViewControllerDelegate

    func didChangeFocusedColumn(inSplitViewController splitViewController: KeyboardSplitViewController) {
        viewIfLoaded?.window?.updateFirstResponder()
    }

    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        viewIfLoaded?.window?.updateFirstResponder()
    }

    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        // This can be called during scene connection before the view loads.
        // If we force the view to load here, then we end up with an exception:
        // > Mutating UISplitViewController with -setView: is not allowed during a delegate callback
        viewIfLoaded?.window?.updateFirstResponder()
    }

    // MARK: - FirstResponderManagement

    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? innerSplitViewController
    }

    private class ListViewController: FirstResponderViewController, UICollectionViewDelegate {
        init(appearance: UICollectionLayoutListConfiguration.Appearance) {
            self.appearance = appearance
            super.init()
        }

        let appearance: UICollectionLayoutListConfiguration.Appearance
        private var dataSource: UICollectionViewDiffableDataSource<Int, String>? = nil

        private lazy var collectionView: UICollectionView = {
            var listConfig = UICollectionLayoutListConfiguration(appearance: appearance)
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

        // MARK: - UICollectionViewDelegate

        func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
            indexPath.item != 0
        }
    }
}
