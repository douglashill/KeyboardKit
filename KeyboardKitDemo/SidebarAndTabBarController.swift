// Douglas Hill, July 2020

import UIKit
import KeyboardKit

/// Shows an array of content views. The user switches views using a tab bar in compact widths or using a sidebar in regular widths.
class SidebarAndTabBarController: UIViewController, SidebarViewControllerDelegate, UITabBarControllerDelegate {
    private let innerSplitViewController: UISplitViewController
    private let innerTabBarController: UITabBarController
    private let sidebar: SidebarViewController
    private let secondarySplitNavigationController: UINavigationController
    private let secondarySplitPartialParents: [PartialParentViewController]

    private var selectedViewControllerIndex: Int {
        didSet {
            updateSelectedContentViewController()
        }
    }

    private func updateSelectedContentViewController() {
        secondarySplitNavigationController.viewControllers = [secondarySplitPartialParents[selectedViewControllerIndex]]
        innerTabBarController.selectedIndex = selectedViewControllerIndex
    }

    @available(*, unavailable) override var splitViewController: UISplitViewController? { nil }
    @available(*, unavailable) override var tabBarController: UITabBarController? { nil }
    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    init(viewControllers: [UIViewController], initialSelectedIndex: Int = 0) {
        precondition(viewControllers.isEmpty == false)

        secondarySplitPartialParents = viewControllers.map {
            PartialParentViewController(childViewController: $0)
        }
        selectedViewControllerIndex = initialSelectedIndex

        let splitViewController = UISplitViewController(style: .doubleColumn)
        splitViewController.presentsWithGesture = false
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.preferredSplitBehavior = .tile

        sidebar = SidebarViewController(items: viewControllers.map { ($0.title!, $0.tabBarItem.image) })
        splitViewController.setViewController(sidebar, for: .primary)

        secondarySplitNavigationController = KeyboardNavigationController()
        splitViewController.setViewController(secondarySplitNavigationController, for: .secondary)

        innerTabBarController = KeyboardTabBarController()
        innerTabBarController.viewControllers = viewControllers.map { contentViewController in
            KeyboardNavigationController(rootViewController: PartialParentViewController(childViewController: contentViewController))
        }
        splitViewController.setViewController(innerTabBarController, for: .compact)

        innerSplitViewController = splitViewController

        super.init(nibName: nil, bundle: nil)

        sidebar.delegate = self
        innerTabBarController.delegate = self

        addChild(splitViewController)
        splitViewController.didMove(toParent: self)

        updateSelectedContentViewController()
    }

    override var title: String? {
        get { sidebar.title }
        set { sidebar.title = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(innerSplitViewController.view)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        innerSplitViewController.view.frame = view.bounds
    }

    // MARK: - SidebarViewControllerDelegate

    func didSelectItemAtIndex(_ index: Int, inSidebarViewController sidebarViewController: SidebarViewController) {
        selectedViewControllerIndex = index
    }

    func selectedIndexInSidebarViewController(_ sidebarViewController: SidebarViewController) -> Int {
        selectedViewControllerIndex
    }

    // MARK: - UITabBarControllerDelegate

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        selectedViewControllerIndex = tabBarController.selectedIndex
    }
}
