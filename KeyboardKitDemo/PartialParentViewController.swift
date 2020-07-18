// Douglas Hill, July 2020

import UIKit

/// A view controller can have multiple partial parents. Becomes a real parent/child relationship when the view appears.
///
/// The aim is the parent forwards everything to its child. I might have missed some stuff.
///
/// Intended for private use in SidebarAndTabBarController. Not intended for any other use.
///
/// UISplitViewController does not have willExpand and willCollapse delegate methods.
/// It has didExpand and didCollapse but these are too late for a rotation animation.
/// No other delegate methods of `UISplitViewController` seem to work.
/// collapseSecondary and separateSecondary aren’t called, apparently this is due to using double
/// style, but I don’t see why a style would make a different here. Using compact column would though.
/// willShowColumn does not seem to get called when the column is showing each time. Only initially.
class PartialParentViewController: UIViewController {
    let childViewController: UIViewController

    init(childViewController: UIViewController) {
        self.childViewController = childViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    override var childForHomeIndicatorAutoHidden: UIViewController? { childViewController }
    override var childForScreenEdgesDeferringSystemGestures: UIViewController? { childViewController }
    override var childForStatusBarHidden: UIViewController? { childViewController }
    override var childForStatusBarStyle: UIViewController? { childViewController }
    override var childViewControllerForPointerLock: UIViewController? { childViewController }

    override var title: String? {
        get { childViewController.title }
        set { childViewController.title = newValue }
    }

    override var tabBarItem: UITabBarItem! {
        get { childViewController.tabBarItem }
        set { childViewController.tabBarItem = newValue }
    }

    override var navigationItem: UINavigationItem {
        childViewController.navigationItem
    }

    override var toolbarItems: [UIBarButtonItem]? {
        get { childViewController.toolbarItems }
        set { childViewController.toolbarItems = newValue }
    }

    override func setToolbarItems(_ toolbarItems: [UIBarButtonItem]?, animated: Bool) {
        childViewController.setToolbarItems(toolbarItems, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        childViewController.view.frame =  view.bounds
    }
}
