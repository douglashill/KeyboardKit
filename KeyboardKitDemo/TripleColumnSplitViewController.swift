// Douglas Hill, August 2020

import UIKit
import KeyboardKit

class TripleColumnSplitViewController: UIViewController, KeyboardSplitViewControllerDelegate, TListViewControllerDelegate {
    private let innerSplitViewController: KeyboardSplitViewController
//    private let primaryNavigationController: KeyboardNavigationController

//    private var _selectedViewControllerIndex: Int
//    func getSelectedViewControllerIndex() -> Int { _selectedViewControllerIndex }
//    func setSelectedViewControllerIndex(_ newValue: Int, shouldTransitionToDetail: Bool) {
//        _selectedViewControllerIndex  = newValue
//
//        let newDetailViewController = contentViewControllers[newValue]
//
//        if shouldTransitionToDetail {
//            innerSplitViewController.showDetailViewController(newDetailViewController, sender: nil)
//        } else {
//            innerSplitViewController.setViewController(newDetailViewController, for: .secondary)
//        }
//    }

    // The primary would ideally use the sidebar style, but as of Xcode 12 beta 4 using the
    // sidebar style in the primary column results in a crash as soon as the view appears:
    // *** Assertion failure in -[UIListContentConfiguration _enforcesMinimumHeight], UIListContentConfiguration.m:470
    // Unknown style: 10
    // OK this also happens for the sidebarPlain style in the supplementary when collapsed. (Beta 5)
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

        primaryList.title = "Food"

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

        primaryList.data = self.data.map { $0.title }

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
        // The collapse callback might be called during scene connection before the view loads.
        // If we force the view to load here, then we end up with an exception:
        // > Mutating UISplitViewController with -setView: is not allowed during a delegate callback
        guard let window = viewIfLoaded?.window else {
            return
        }

        window.updateFirstResponder()

        guard innerSplitViewController.isCollapsed == false else {
            return
        }

        for navigationController in [primaryNavigationController, supplementaryNavigationController, secondaryNavigationController] {
            let isFocused = navigationController.viewControllers.first!.view.isFirstResponder
            navigationController.navigationBar.titleTextAttributes = isFocused ? nil : [.foregroundColor: UIColor.secondaryLabel]
        }
    }

//    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
//        // The default behaviour is to always show the secondary.
//        // Since we have a first-class concept of user focus let’s use that.
////        innerSplitViewController.focusedColumn ?? proposedTopColumn
//        // TODO: Is this actually doing anything since the primary and secondary get combined?
//
//
//        // The bit not working is the UISVC is already collapsed at this point
//        // so focusedColumn is returning the primary. But really there is no clear meaning of focused column when collapsed.
//
//
//        // Since we have a first-class concept of user focus let’s use that.
//        if let focusedColumn = innerSplitViewController.focusedColumn, focusedColumn == .primary {
//            // Sidebar is focused so just showing that is fine. No combining needed.
////            primaryNavigationController.viewControllers = [sidebar]
//            return .primary // This does work. The UISVC doesn’t push the secondary if we return this.
//        } else {
//            // Sidebar is not focused. Let UIKit push the secondary onto the primary’s navigation stack.
//            return .secondary
//        }
//
////        return proposedTopColumn
//    }
//
//    func splitViewController(_ svc: UISplitViewController, displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode) -> UISplitViewController.DisplayMode {
//        // If the primary was the top view controller when collapsed, keep it visible after expanding.
//        if proposedDisplayMode == .secondaryOnly && primaryNavigationController.topViewController === sidebar {
//            return .oneOverSecondary
//        } else {
//            return proposedDisplayMode
//        }
//    }

    // MARK: - TListViewControllerDelegate

    fileprivate func didChangeSelectedItemsInListViewController(_ listViewController: TListViewController, isExplicitActivation: Bool) {
        let nextColumn: UISplitViewController.Column
        if listViewController == primaryList {
            // Since clearing selection is disabled, the indices can be force unwrapped.
            let supplementaryData = self.data[primaryList.selectedIndex!]
            supplementaryList.title = supplementaryData.title
            supplementaryList.data = supplementaryData.items.map { $0.title }
            secondaryList.title = nil
            secondaryList.data = []


            nextColumn = .supplementary
        } else if listViewController == supplementaryList {
            // Since clearing selection is disabled, the indices can be force unwrapped.
            let secondaryData = self.data[primaryList.selectedIndex!].items[supplementaryList.selectedIndex!]
            secondaryList.title = secondaryData.title
            secondaryList.data = secondaryData.items

            nextColumn = .secondary
        } else {
            return
        }

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
            return
        }

        innerSplitViewController.show(nextColumn)
        // It might feel a bit nicer if this also changed  the first responder to the next column.
        // I need to update KeyboardSplitViewController to account for the first responder being changed externally.
        // Public API to change focused column could be showColumn + changing the first responder externally.
    }

    // MARK: - FirstResponderManagement

    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? innerSplitViewController
    }

    // MARK: - Data

    let data: [(title: String, items: [(title: String, items: [String])])] = [
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

    var selectedIndex: Int? {
        collectionView.indexPathsForSelectedItems?.first?.item
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
        delegate?.didChangeSelectedItemsInListViewController(self, isExplicitActivation: true)
    }

    // MARK: - KeyboardCollectionViewDelegate

    func collectionViewDidChangeSelectedItemsUsingKeyboard(_ collectionView: UICollectionView) {
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
