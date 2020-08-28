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

        primaryList.title = "Primary"
        supplementaryList.title = "Supplementary"
        secondaryList.title = "Secondary"

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

    // Handle and issue where if you have 1 over 2rd in portrait the rotate to landscape and focus
    // the 2rd then rotate to portrait it shows 1 over 2ry but the focus remains on the hidden 2ry.

    // willShowColumn and willHideColumn are not useful because when portrait shows one over
    // secondary and landscape shows two columns, no columns are shown or hidden when rotating.

    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        // We want a didChangeToDisplayMode callback. Try to approximate that here.
        // I’d really like to find some way to move this into KeyboardSplitViewController
        // rather than expecting everyone using that class to repeat the same code.
        // Since updating first responder at the start of transitions is better than at the end,
        // it might make sense to use the dispatch after patch even if there is a transitionCoordinator.

        let didChangeToDisplayMode = {
            self.viewIfLoaded?.window?.updateFirstResponder()
        }

        if let transitionCoordinator = svc.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: nil, completion: { transitionCoordinatorContext in
                didChangeToDisplayMode()
            })
        }  else {
            // This happens during initial setup and on device rotation. The initial setup does not matter but we need to handle the rotation case. Try dispatch after.
            DispatchQueue.main.async {
                guard svc.displayMode == displayMode else {
                    NSLog("Display mode is not change to \(displayMode.rawValue) after willChangeTo callback. Instead the display mode is \(svc.displayMode.rawValue).")
                    return
                }

                didChangeToDisplayMode()
            }
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

    fileprivate func didSelectItemAtIndexPath(_ indexPath: IndexPath, inListViewController listViewController: TListViewController) {
        let nextColumn: UISplitViewController.Column
        if listViewController == primaryList {
            nextColumn = .supplementary
        } else if listViewController == supplementaryList {
            nextColumn = .secondary
        } else {
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
    }

    // Public API to change focused column should be showColumn + changing the first responder externally.
    // This example is flawed without using actual hierarchical data so the sub-lists updated when changing the higher ones.
    // Like continents, countries, cities or something. Or countries/counties/towns in the UK.
    // It will always feel wrong without that.

    // MARK: - FirstResponderManagement

    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? innerSplitViewController
    }
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAtIndexPath(indexPath, inListViewController: self)
    }

    // MARK: - KeyboardCollectionViewDelegate

    func collectionViewDidChangeSelectedItemsUsingKeyboard(_ collectionView: UICollectionView) {
        // Normally this would update the contents of a details view.
        // But we’re using static lists in this example.
    }

    func collectionViewShouldClearSelection(_ collectionView: UICollectionView) -> Bool {
        // Not allowing clearing selection feels better for sidebars because usually want
        // to force something to be selected. This also means the user can dismiss an
        // overlaid or displacing sidebar with one press of the escape key instead of two.
        false
    }
}

private protocol TListViewControllerDelegate: NSObjectProtocol {
    func didSelectItemAtIndexPath(_ indexPath: IndexPath, inListViewController listViewController: TListViewController)
}
