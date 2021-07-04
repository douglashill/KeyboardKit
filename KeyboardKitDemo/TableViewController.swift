// Douglas Hill, May 2019

import UIKit
import KeyboardKit

class TableViewController: FirstResponderViewController, UITableViewDataSource, UITableViewDelegate {
    override init() {
        super.init()
        title = "Table View"
        tabBarItem.image = UIImage(systemName: "list.bullet")
    }

    private let cellReuseIdentifier = "a"
    private lazy var tableView = KeyboardTableView()

    override func loadView() {
        view = tableView
    }

    var bookmarksBarButtonItem: KeyboardBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // The keyboard equivalents for these buttons won’t work if the sidebar is first responder
        // because this table view’s navigation controller won’t be on the responder chain.

        bookmarksBarButtonItem = KeyboardBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showBookmarks))

        let testItem = KeyboardBarButtonItem(title: "Alert", style: .plain, target: self, action: #selector(testAction))
        testItem.keyEquivalent = ([.command, .alternate], "t")
        navigationItem.rightBarButtonItems = [editButtonItem, testItem, bookmarksBarButtonItem!]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // UIRefreshControl is not available when optimised for Mac. Crashes at runtime.
        // https://steipete.com/posts/forbidden-controls-in-catalyst-mac-idiom/
        if traitCollection.userInterfaceIdiom != .mac {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Making this animated does not seem to work with iOS 15.0 beta 2. Therefore the delay is long
        // to make sure the previous selection is briefly is visible. When dropping iOS 14 (so first
        // responder management is no longer necessary) it would be good to swap the superclass to
        // UITableViewController because that handles deselection on appearing automatically.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        }
    }

    private static let freshData: [[String]] = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let sectionData = (0..<23).map {
            formatter.string(from: NSNumber(value: $0 + 1))!
        }
        return [sectionData, sectionData, sectionData]
    }()

    private var data: [[String]] = freshData

    func numberOfSections(in tableView: UITableView) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Section \(section + 1)"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel!.text = data[indexPath.section][indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(TableViewController(), animated: true)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    @objc private func testAction(_ sender: Any?) {
        let alert = UIAlertController(title: "This is a test", message: "You can show this alert either by tapping the bar button or by pressing command + option + T while the table view is focused.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    @objc private func showBookmarks(_ sender: Any?) {
        let bookmarksViewController = BookmarksViewController()
        let navigationController = KeyboardNavigationController(rootViewController: bookmarksViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = bookmarksBarButtonItem
        present(navigationController, animated: true)
    }

    @objc private func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.data = TableViewController.freshData
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        precondition(editingStyle == .delete)

        data[indexPath.section].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = data[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        data[destinationIndexPath.section].insert(item, at: destinationIndexPath.row)
    }
}

class BookmarksViewController: FirstResponderViewController {
    override init() {
        super.init()
        title = "Bookmarks"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = KeyboardBarButtonItem(barButtonSystemItem: .save, target: nil, action: #selector(saveBookmarks))

        view.backgroundColor = .systemBackground
    }

    @objc private func saveBookmarks(_ sender: Any?) {
        presentingViewController?.dismiss(animated: true)
    }
}
