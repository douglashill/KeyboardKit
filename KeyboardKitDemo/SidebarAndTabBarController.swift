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

    // TODO: Support using cmd-1 to cmd-5 to change the secondary column while expanded.
    // While compact, the tab bar controller deals with this.
    // Possible approach: put the sidebar in the responder chain after the detail VC.
    // However this would mean making the sidebar a lot more aware of how it is used.
    // Another possibility: replicate what the tab bar controller does in this class SidebarAndTabBarController.
    // This makes the tab bar support redundant but does seem the most correct locations for responsibilities.

    init(viewControllers: [UIViewController], initialSelectedIndex: Int = 0) {
        precondition(viewControllers.isEmpty == false)

        secondarySplitPartialParents = viewControllers.map {
            PartialParentViewController(childViewController: $0)
        }
        selectedViewControllerIndex = initialSelectedIndex

        // TODO: Create and use a KeyboardSplitViewController that supports moving focus between the columns.
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

        for (index, contentViewController) in viewControllers.prefix(9).enumerated() {
            addKeyCommand(UIKeyCommand(title: contentViewController.title!, action: #selector(scrollToNumberedTab), input: String(index + 1), modifierFlags: .command))
        }
    }

    // For using command-1 to command-9.
    @objc private func scrollToNumberedTab(_ sender: UIKeyCommand) {
        guard let keyInput = sender.input, let targetTabNumber = Int(keyInput), targetTabNumber > 0 else {
            return
        }

        selectedViewControllerIndex = targetTabNumber - 1
    }

    // TODO: The split view and tab bar aren’t always showing the same content view. I don’t think this is related to this keyboard control I just added for changing sidebar selection.

    // TODO: Also after using cmd-1 etc the selection in the sidebar is not updated until you scroll the sidebar a little bit.

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
