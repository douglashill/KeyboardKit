// Douglas Hill, July 2020

import UIKit
import KeyboardKit

/// Shows an array of content views in a sidebar in regular widths, collapsing to using a navigation stack in compact widths.
class DoubleColumnSplitViewController: UIViewController, SidebarViewControllerDelegate, KeyboardSplitViewControllerDelegate {
    private let innerSplitViewController: KeyboardSplitViewController
    private let sidebar: SidebarViewController
    private let primaryNavigationController: KeyboardNavigationController
    private let contentViewControllers: [KeyboardNavigationController]

    @available(*, unavailable) override var splitViewController: UISplitViewController? { nil }
    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    init(viewControllers: [UIViewController], initialSelectedIndex: Int = 0) {
        precondition(viewControllers.isEmpty == false)

        innerSplitViewController = KeyboardSplitViewController(style: .doubleColumn)
        innerSplitViewController.primaryBackgroundStyle = .sidebar

        contentViewControllers = viewControllers.map { KeyboardNavigationController(rootViewController: $0) }
        _selectedViewControllerIndex = initialSelectedIndex

        sidebar = SidebarViewController(items: viewControllers.map { ($0.title!, $0.tabBarItem.image) })
        primaryNavigationController = KeyboardNavigationController(rootViewController: sidebar)
        innerSplitViewController.setViewController(primaryNavigationController, for: .primary)

        super.init(nibName: nil, bundle: nil)

        innerSplitViewController.delegate = self
        sidebar.delegate = self

        sidebar.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Modal Examples", menu: UIMenu(title: "", children: modalExampleKeyCommands))

        addChild(innerSplitViewController)
        innerSplitViewController.didMove(toParent: self)

        setSelectedViewControllerIndex(initialSelectedIndex, shouldTransitionToDetail: false)
    }

    private var _selectedViewControllerIndex: Int
    func getSelectedViewControllerIndex() -> Int { _selectedViewControllerIndex }
    func setSelectedViewControllerIndex(_ newValue: Int, shouldTransitionToDetail: Bool) {
        _selectedViewControllerIndex  = newValue

        let newDetailViewController = contentViewControllers[newValue]

        if shouldTransitionToDetail {
            innerSplitViewController.showDetailViewController(newDetailViewController, sender: nil)
        } else {
            innerSplitViewController.setViewController(newDetailViewController, for: .secondary)
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        commands.append(contentsOf: modalExampleKeyCommands)

        return commands
    }

    private let modalExampleKeyCommands: [UIKeyCommand] = [
        UIKeyCommand(title: "Triple Column Split", action: #selector(showTripleColumn), input: "t", modifierFlags: .command),
        UIKeyCommand(title: "Tab Bar", action: #selector(showTabs), input: "t", modifierFlags: [.command, .control]),
    ]

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(showTripleColumn) || action == #selector(showTabs) {
            return presentedViewController == nil
        }
        return super.canPerformAction(action, withSender: sender)
    }

    @objc private func showTripleColumn() {
        let tripleColumnViewController = TripleColumnSplitViewController()
        tripleColumnViewController.modalPresentationStyle = .fullScreen
        self.present(tripleColumnViewController, animated: true)
    }

    @objc private func showTabs() {
        let viewControllers: [UIViewController] = [
            ListViewController(),
            FlowLayoutViewController(),
            CirclesScrollViewController(),
            PagingScrollViewController(),
            TextViewController(),
        ]

        for viewController in viewControllers {
            viewController.navigationItem.rightBarButtonItem = KeyboardBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissModalTabBarController))
        }

        let tabViewController = KeyboardTabBarController()
        tabViewController.viewControllers = viewControllers.map { KeyboardNavigationController(rootViewController: $0) }

        #if targetEnvironment(macCatalyst)
        // For some reason `dismissModalTabBarController` does not get delivered when this uses the default sheet presentation
        // on Mac Catalyst. I’d use ResponderChainDebugging.m to debug this, but that also doesn’t work on Mac Catalyst.
        // This was tested building with the iOS 14.2 SDK (Xcode 12.2) and running on macOS 11.0.1.
        tabViewController.modalPresentationStyle = .fullScreen
        #endif

        self.present(tabViewController, animated: true)
    }

    @objc private func dismissModalTabBarController() {
        precondition(presentedViewController is KeyboardTabBarController)
        dismiss(animated: true)
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

    func didShowSelectionAtIndex(_ index: Int, inSidebarViewController sidebarViewController: SidebarViewController) {
        // This does nothing visible when collapsed but means if it later expands the secondary is already correct.
        setSelectedViewControllerIndex(index, shouldTransitionToDetail: false)
    }

    func didActivateSelectionAtIndex(_ index: Int, inSidebarViewController sidebarViewController: SidebarViewController) {
        setSelectedViewControllerIndex(index, shouldTransitionToDetail: true)
    }

    func shouldRequireSelectionInSidebarViewController(_ sidebarViewController: SidebarViewController) -> Bool {
        // Force there to be a selection when the split view is expanded.
        innerSplitViewController.isCollapsed == false
    }

    func selectedIndexInSidebarViewController(_ sidebarViewController: SidebarViewController) -> Int {
        getSelectedViewControllerIndex()
    }

    // MARK: - KeyboardSplitViewControllerDelegate

    func didChangeFocusedColumn(inSplitViewController splitViewController: KeyboardSplitViewController) {
        // The collapse callback might be called during scene connection before the view loads.
        // If we force the view to load here, then we end up with an exception:
        // > Mutating UISplitViewController with -setView: is not allowed during a delegate callback
        viewIfLoaded?.window?.updateFirstResponder()
    }

    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        sidebar.clearSelection()
    }

    // MARK: - FirstResponderManagement

    override var kd_preferredFirstResponderInHierarchy: UIResponder? {
        if let presented = presentedViewController {
            return presented
        }

        switch innerSplitViewController.focusedColumn {
        case .none:          return primaryNavigationController // The split view is collapsed onto this navigation controller.
        case .primary:       return sidebar // Could also return primaryNavigationController. The result would be the same.
        case .supplementary: preconditionFailure("Unexpectedly found supplementary column focused in double column demo.")
        case .secondary:     return contentViewControllers[getSelectedViewControllerIndex()]
        case .compact:       preconditionFailure("Unexpectedly found compact column focused.")
        @unknown default:    return nil
        }
    }
}
