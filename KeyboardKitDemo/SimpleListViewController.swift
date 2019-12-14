// Douglas Hill, May 2019

import UIKit
import KeyboardKit

class SimpleListViewController: FirstResponderViewController, UITableViewDataSource, UITableViewDelegate {
    override var title: String? {
        get { "Simple List" }
        set {}
    }

    private let cellReuseIdentifier = "a"
    private let numberFormatter1: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()
    private let numberFormatter2: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    private lazy var tableView = KeyboardTableView()

    var numberFormatter: NumberFormatter!

    override func loadView() {
        view = tableView
    }

    var bookmarksBarButtonItem: KeyboardBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        numberFormatter = numberFormatter1

        bookmarksBarButtonItem = KeyboardBarButtonItem(barButtonSystemItem: .bookmarks, target: nil, action: #selector(showBookmarks))

        let testItem = KeyboardBarButtonItem(title: "Press Command + T", style: .plain, target: nil, action: #selector(testAction))
        testItem.keyEquivalent = (.command, "t")
        navigationItem.rightBarButtonItems = [testItem, bookmarksBarButtonItem!]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Section \(numberFormatter.string(from: NSNumber(value: section + 1))!)"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = numberFormatter.string(from: NSNumber(value: indexPath.row + 1))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(SimpleListViewController(), animated: true)
    }

    @objc private func testAction(_ sender: Any?) {
        let alert = UIAlertController(title: "This is a test", message: "You can show this alert either by tapping the bar button or by pressing command + T.", preferredStyle: .alert)
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
            self.numberFormatter = (self.numberFormatter === self.numberFormatter1) ? self.numberFormatter2 : self.numberFormatter1
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }
}

class BookmarksViewController: FirstResponderViewController {
    override var title: String? {
        get { "Bookmarks" }
        set {}
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
