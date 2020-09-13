// Douglas Hill, August 2020

import UIKit
import KeyboardKit

class TripleColumnSplitViewController: UIViewController, KeyboardSplitViewControllerDelegate, TripleColumnListViewControllerDelegate {
    private let innerSplitViewController: KeyboardSplitViewController

    // The primary and supplementary would ideally use the sidebar and sidebarPlain styles. However these seem a bit half baked.
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

        enum ConcreteSplitBehaviour {
            case tile
            case overlay
            case displace

            init?(splitBehavior: UISplitViewController.SplitBehavior) {
                switch splitBehavior {
                case .automatic:
                    preconditionFailure("splitBehavior is automatic, which is not a concrete behaviour.")
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
            preconditionFailure("Unexpected top view controller: \(primaryNavigationController.topViewController?.description ?? "nil")")
        }

        guard let splitBehavior = ConcreteSplitBehaviour(splitBehavior: svc.splitBehavior) else {
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
