// Douglas Hill, July 2020

import UIKit
import KeyboardKit

/// Shows an array of content views in a sidebar in regular widths, collapsing to using a navigation stack in compact widths.
class SplitContainer: UIViewController, SidebarViewControllerDelegate, KeyboardSplitViewControllerDelegate {
    private let innerSplitViewController: KeyboardSplitViewController
    private let sidebar: SidebarViewController
    private let contentViewControllers: [KeyboardNavigationController]

    private var selectedViewControllerIndex: Int {
        didSet {
            updateSelectedContentViewController()
        }
    }

    private func updateSelectedContentViewController() {
        innerSplitViewController.showDetailViewController(contentViewControllers[selectedViewControllerIndex], sender: nil)
    }

    @available(*, unavailable) override var splitViewController: UISplitViewController? { nil }
    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    init(viewControllers: [UIViewController], initialSelectedIndex: Int = 0) {
        precondition(viewControllers.isEmpty == false)

        contentViewControllers = viewControllers.map { KeyboardNavigationController(rootViewController: $0) }
        selectedViewControllerIndex = initialSelectedIndex

        let splitViewController = KeyboardSplitViewController(style: .doubleColumn)

        sidebar = SidebarViewController(items: viewControllers.map { ($0.title!, $0.tabBarItem.image) })
        splitViewController.setViewController(KeyboardNavigationController(rootViewController: sidebar), for: .primary)

        innerSplitViewController = splitViewController

        super.init(nibName: nil, bundle: nil)

        sidebar.delegate = self
        splitViewController.delegate = self

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

    // MARK: - KeyboardSplitViewControllerDelegate

    func didChangeFocusedColumn(inSplitViewController splitViewController: KeyboardSplitViewController) {
        view.window?.updateFirstResponder()
    }

    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        view.window?.updateFirstResponder()
    }

    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        view.window?.updateFirstResponder()
    }

    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        // The default behaviour is to always show the secondary.
        // Since we have a first-class concept of user focus let’s use that.
        innerSplitViewController.focusedColumn ?? proposedTopColumn
    }

    func splitViewController(_ svc: UISplitViewController, displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode) -> UISplitViewController.DisplayMode {
        // What would be nice to do here is if the navigation controller top controller is the primary content VC then go to a display mode that shows the sidebar and focus it.
        proposedDisplayMode
    }

    // MARK: - FirstResponderManagement

    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        presentedViewController ?? innerSplitViewController
    }
}
