// Douglas Hill, August 2020

import UIKit
import KeyboardKit

class TripleColumnSplitViewController: UIViewController, KeyboardSplitViewControllerDelegate, TListViewControllerDelegate {
    private let innerSplitViewController: KeyboardSplitViewController

    // The primary and supplementary would ideally use the sidebar and sidebarPlain styles. However these seem a bit half baked.
    // In Xcode 12 beta 4 using sidebar always crashed as soon as the view appears:
    // *** Assertion failure in -[UIListContentConfiguration _enforcesMinimumHeight], UIListContentConfiguration.m:470
    // Unknown style: 10
    // In beta 5 the crashing extended to the sidebarPlain style in the supplementary when collapsed.
    // In beta 6 the crashing has stopped but these styles don’t always look good. When collapsed the primary with
    // sidebar style uses a blue selection highlight but does not invert the content colour.
    // Having some highlight stronger than others implies that might be where keyboard focus is, but this isn’t the case.
    private let primaryList = TListViewController(appearance: .insetGrouped)
    private let supplementaryList = TListViewController(appearance: .insetGrouped)
    private let secondaryList = TListViewController(appearance: .insetGrouped)

    private let primaryNavigationController: KeyboardNavigationController
    private let supplementaryNavigationController: KeyboardNavigationController
    private let secondaryNavigationController: KeyboardNavigationController

    @available(*, unavailable) override var splitViewController: UISplitViewController? { nil }
    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    init() {
        innerSplitViewController = KeyboardSplitViewController(style: .tripleColumn)

        primaryNavigationController = KeyboardNavigationController(rootViewController: primaryList)
        supplementaryNavigationController = KeyboardNavigationController(rootViewController: supplementaryList)
        secondaryNavigationController = KeyboardNavigationController(rootViewController: secondaryList)

        innerSplitViewController.setViewController(primaryNavigationController, for: .primary)
        innerSplitViewController.setViewController(supplementaryNavigationController, for: .supplementary)
        innerSplitViewController.setViewController(secondaryNavigationController, for: .secondary)

        super.init(nibName: nil, bundle: nil)

        innerSplitViewController.delegate = self
        primaryList.delegate = self
        supplementaryList.delegate = self
        secondaryList.delegate = self

        secondaryList.navigationItem.rightBarButtonItem = KeyboardBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissSelf))

        updateListData()

        addChild(innerSplitViewController)
        innerSplitViewController.didMove(toParent: self)

        NotificationCenter.default.addObserver(self, selector: #selector(updateTitleTextAttributes), name: firstResponderDidChangeNotification, object: nil)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    @objc private func updateTitleTextAttributes() {
        for navigationController in [primaryNavigationController, supplementaryNavigationController, secondaryNavigationController] {
            let isStrong = innerSplitViewController.isCollapsed || navigationController.viewControllers.first!.view.isFirstResponder
            navigationController.navigationBar.titleTextAttributes = isStrong ? nil : [.foregroundColor: UIColor.secondaryLabel]
        }
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
        // The collapse callback might be called during scene connection before the view loads.
        // If we force the view to load here, then we end up with an exception:
        // > Mutating UISplitViewController with -setView: is not allowed during a delegate callback
        guard let window = viewIfLoaded?.window else {
            return
        }

        window.updateFirstResponder()
    }

    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        innerSplitViewController.focusedColumn ?? proposedTopColumn
    }

    func splitViewController(_ svc: UISplitViewController, displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode) -> UISplitViewController.DisplayMode {
        enum ConcreteColumn {
            case primary
            case supplementary
            case secondary
        }

        enum ConcreteSplitBehavior {
            case tile
            case overlay
            case displace

            init?(splitBehavior: UISplitViewController.SplitBehavior) {
                switch splitBehavior {
                case .automatic:
                    preconditionFailure("splitBehavior is automatic, which is not a concrete behavior.")
                case .tile:
                    self = .tile
                case .overlay:
                    self = .overlay
                case .displace:
                    self = .displace
                @unknown default:
                    return nil
                }
            }
        }

        let visibleColumn: ConcreteColumn
        switch primaryNavigationController.topViewController {
        case primaryList: visibleColumn = .primary
        case supplementaryNavigationController: visibleColumn = .supplementary
        case secondaryNavigationController: visibleColumn = .secondary
        default:
            preconditionFailure("Unexpected top view controller: \(String(describing: primaryNavigationController.topViewController))")
        }

        guard let splitBehavior = ConcreteSplitBehavior(splitBehavior: svc.splitBehavior) else {
            return proposedDisplayMode
        }

        switch (proposedDisplayMode, visibleColumn) {
        case (.automatic, _):
            preconditionFailure("proposedDisplayMode is automatic, which is not a concrete mode.")
        case (.secondaryOnly, .primary), (.oneBesideSecondary, .primary), (.oneOverSecondary, .primary):
            // TODO: Some of this is redundant. E.g. oneOverSecondary must mean the behaviour is overlay so we could go straight to returning twoOverSecondary.
            switch splitBehavior {
            case .tile:
                return .twoBesideSecondary
            case .overlay:
                return .twoOverSecondary
            case .displace:
                return .twoDisplaceSecondary
            }
        case (.secondaryOnly, .supplementary):
            switch splitBehavior {
            case .tile:
                return .oneBesideSecondary
            case .overlay:
                return .oneOverSecondary
            case .displace:
                return .oneBesideSecondary
            }
        case (.oneOverSecondary, .secondary), (.twoOverSecondary, .secondary):
            precondition(splitBehavior == .overlay)
            return .secondaryOnly
        case (.twoDisplaceSecondary, .secondary):
            precondition(splitBehavior == .displace)
            return .oneBesideSecondary
        case (.secondaryOnly, .secondary), (.twoDisplaceSecondary, .primary), (.twoDisplaceSecondary, .supplementary), (.twoOverSecondary, .primary), (.twoOverSecondary, .supplementary), (.oneOverSecondary, .supplementary), (.twoBesideSecondary, _), (.oneBesideSecondary, .supplementary), (.oneBesideSecondary, .secondary):
            return proposedDisplayMode
        @unknown default:
            return proposedDisplayMode
        }
    }

    // MARK: - TListViewControllerDelegate

    fileprivate func didChangeSelectedItemsInListViewController(_ listViewController: TListViewController, isExplicitActivation: Bool) {
        let nextColumn: UISplitViewController.Column
        if listViewController == primaryList {
            nextColumn = .supplementary
            supplementaryList.selectedIndex = 0
            secondaryList.selectedIndex = 0
        } else if listViewController == supplementaryList {
            nextColumn = .secondary
            secondaryList.selectedIndex = 0
        } else if listViewController == secondaryList {
            return
        } else {
            preconditionFailure("Unexpected list: \(listViewController)")
        }

        updateListData()

        guard isExplicitActivation else {
            // We updated the data already. That’s all we need to do for arrow key selection.
            return
        }

        // We can’t use showDetailViewController because we might be showing the supplementary rather than the secondary.
        // Therefore we need to act differently depending on whether collapsed or expanded.
        if innerSplitViewController.isCollapsed {
            // We deliberately want to push the navigation controller rather than the list view controller because this is what
            // UISplitViewController expects when separating the supplementary and secondary from the primary when expanding.
            primaryNavigationController.pushViewController(innerSplitViewController.viewController(for: nextColumn)!, animated: true)
        } else {
            innerSplitViewController.show(nextColumn)
        }
    }

    private func updateListData() {
        primaryList.title = "Food"
        primaryList.data = self.data.map { $0.title }

        let supplementaryData = self.data[primaryList.selectedIndex]
        supplementaryList.title = supplementaryData.title
        supplementaryList.data = supplementaryData.items.map { $0.title }

        let secondaryData = self.data[primaryList.selectedIndex].items[supplementaryList.selectedIndex]
        secondaryList.title = secondaryData.title
        secondaryList.data = secondaryData.items
    }

    // MARK: - FirstResponderManagement

    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? innerSplitViewController
    }

    // MARK: - Data

    private let data: [(title: String, items: [(title: String, items: [String])])] = [
        (title: "Nuts and seeds", items: [
            (title: "Nuts", items: [
                "Almond",
                "Brazil nut",
                "Cashew",
                "Pecan",
                "Walnut",
            ]),
            (title: "Seeds", items: [
                "Pumpkin seed",
                "Sunflower seed",
            ]),
        ]),
        (title: "Fruit and vegetables", items: [
            (title: "Fruit", items: [
                "Apple",
                "Banana",
                "Dragon fruit",
                "Durian",
                "Jack fruit",
                "Mango",
                "Pear",
                "Plum",
            ]),
            (title: "Berries", items: [
                "Bilberry",
                "Blackberry",
                "Blackcurrant",
                "Blueberry",
                "Gooseberry",
                "Raspberry",
                "Redcurrant",
                "Strawberry",
            ]),
            (title: "Root vegetables", items: [
                "Carrot",
                "Cassava",
                "Daikon",
                "Ginger",
                "Lotus root",
                "Potato",
                "Swede",
                "Turnip",
                "Yam",
            ]),
        ]),
    ]
}

// MARK: - List

private class TListViewController: FirstResponderViewController, UICollectionViewDelegate, KeyboardCollectionViewDelegate {
    init(appearance: UICollectionLayoutListConfiguration.Appearance) {
        self.appearance = appearance
        super.init()
    }

    let appearance: UICollectionLayoutListConfiguration.Appearance
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>? = nil

    weak var delegate: TListViewControllerDelegate?

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

private protocol TListViewControllerDelegate: NSObjectProtocol {
    func didChangeSelectedItemsInListViewController(_ listViewController: TListViewController, isExplicitActivation: Bool)
}

private extension String {
    /// Avoids wrapping the string in ‘Optional(...)’ when not nil.
    init<T>(describing instance: Optional<T>) {
        if let value = instance {
            self.init(describing: value)
        } else {
            self = "nil"
        }
    }
}
