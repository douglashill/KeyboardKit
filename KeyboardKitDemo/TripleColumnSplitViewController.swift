// Douglas Hill, August 2020

import UIKit
import KeyboardKit

/// Show three levels of static hierarchical data in lists occupying the three columns of a split view controller. Collapses to a navigation stack.
///
/// This class also demonstrates one possible way to show the focused column visually to the user:
/// by showing the title in the navigation controller for the focused column darker than the titles
/// in the other columns.
class TripleColumnSplitViewController: UIViewController, TripleColumnListViewControllerDelegate, KeyboardSplitViewControllerDelegate {
    private let innerSplitViewController: KeyboardSplitViewController

    // The primary and supplementary would ideally use the sidebar and sidebarPlain styles.
    // However these have had issues throughout the iOS 14 beta.
    // In Xcode 12 beta 4 using sidebar always crashed as soon as the view appears:
    // *** Assertion failure in -[UIListContentConfiguration _enforcesMinimumHeight], UIListContentConfiguration.m:470
    // Unknown style: 10
    // In beta 5 the crashing extended to the sidebarPlain style in the supplementary when collapsed.
    // In beta 6 the crashing has stopped but these styles don’t always look good. When collapsed the primary with
    // sidebar style uses a blue selection highlight but does not invert the content colour.
    // Having some highlight stronger than others implies that might be where keyboard focus is, but this isn’t the case.
    private let primaryList = TripleColumnListViewController(appearance: .insetGrouped)
    private let supplementaryList = TripleColumnListViewController(appearance: .insetGrouped)
    private let secondaryList = TripleColumnListViewController(appearance: .insetGrouped)

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

    // MARK: - TripleColumnListViewControllerDelegate

    func didChangeSelectedItemsInListViewController(_ listViewController: TripleColumnListViewController, isExplicitActivation: Bool) {
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

    // MARK: - KeyboardSplitViewControllerDelegate

    func didChangeFocusedColumn(inSplitViewController splitViewController: KeyboardSplitViewController) {
        // The collapse callback might be called during scene connection before the view loads.
        // If we force the view to load here, then we end up with an exception:
        // > Mutating UISplitViewController with -setView: is not allowed during a delegate callback
        viewIfLoaded?.window?.updateFirstResponder()
    }

    // MARK: - FirstResponderManagement

    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        if let presented = presentedViewController {
            return presented
        }

        switch innerSplitViewController.focusedColumn {
        case .none:          return primaryNavigationController // The split view is collapsed onto this navigation controller.
        case .primary:       return primaryList
        case .supplementary: return supplementaryList
        case .secondary:     return secondaryList
        case .compact:       preconditionFailure("Unexpectedly found compact column focused.")
        @unknown default:    return nil
        }
    }

    // MARK: - Data

    private func updateListData() {
        primaryList.title = "Food"
        primaryList.items = self.data.map { $0.title }

        let supplementaryData = self.data[primaryList.selectedIndex]
        supplementaryList.title = supplementaryData.title
        supplementaryList.items = supplementaryData.items.map { $0.title }

        let secondaryData = self.data[primaryList.selectedIndex].items[supplementaryList.selectedIndex]
        secondaryList.title = secondaryData.title
        secondaryList.items = secondaryData.items
    }

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
                "Jackfruit",
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
