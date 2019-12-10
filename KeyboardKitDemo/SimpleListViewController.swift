// Douglas Hill, May 2019

import UIKit
import KeyboardKit

class SimpleListViewController: FirstResponderViewController, UITableViewDataSource, UITableViewDelegate {
    override var title: String? {
        get { "Simple List" }
        set {}
    }

    private let cellReuseIdentifier = "a"
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()
    lazy private var tableView = KeyboardTableView()

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let testItem = KeyboardBarButtonItem(title: "Press Command + T", style: .plain, target: nil, action: #selector(testAction))
        testItem.keyEquivalent = (.command, "t")
        navigationItem.rightBarButtonItem = testItem

        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = KeyboardBarButtonItem(barButtonSystemItem: .reply, target: nil, action: #selector(reply))

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
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

    @objc private func reply(_ sender: Any?) {
        let alert = UIAlertController(title: "Reply", message: "You can show this alert either by tapping the bar button or by pressing command + R. KeyboardKit provides default key equivalents for most system bar button items.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
