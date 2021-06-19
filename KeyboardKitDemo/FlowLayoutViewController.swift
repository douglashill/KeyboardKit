// Douglas Hill, December 2019

import KeyboardKit
import UIKit

class FlowLayoutViewController: FirstResponderViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    override init() {
        super.init()
        title = "Flow Layout"
        tabBarItem.image = UIImage(systemName: "square.grid.2x2")
    }

    private let cellReuseIdentifier = "a"
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 150, height: 150)
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        return KeyboardCollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.accessibilityIdentifier = "flow layout collection view"

        // UIRefreshControl is not available when optimised for Mac. Crashes at runtime.
        // https://steipete.com/posts/forbidden-controls-in-catalyst-mac-idiom/
        if traitCollection.userInterfaceIdiom != .mac {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            collectionView.refreshControl = refreshControl
        }
    }

    private static let freshData: [[String]] = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        let sectionData = (0..<28).map {
            formatter.string(from: NSNumber(value: $0 + 1))!
        }
        return [sectionData, sectionData, sectionData]
    }()

    private var data: [[String]] = freshData

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! Cell
        cell.label.text = data[indexPath.section][indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = data[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        data[destinationIndexPath.section].insert(item, at: destinationIndexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    @objc private func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.data = FlowLayoutViewController.freshData
            self.collectionView.reloadData()
            sender.endRefreshing()
        }
    }

    private class Cell: UICollectionViewCell {
        let label = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)

            contentView.layer.cornerRadius = 25
            contentView.layer.cornerCurve = .continuous
            contentView.backgroundColor = .secondarySystemGroupedBackground

            contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])

            updateColours()
        }

        required init?(coder decoder: NSCoder) { preconditionFailure() }

        override var isSelected: Bool {
            didSet {
                contentView.layer.borderWidth = isSelected ? 2 : 0
            }
        }

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)

            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateColours()
            }
        }

        private func updateColours() {
            contentView.layer.borderColor = UIColor.label.cgColor
        }

        @available(iOS 15.0, *)
        override var focusEffect: UIFocusEffect? {
            get {
                UIFocusHaloEffect(roundedRect: contentView.frame, cornerRadius: contentView.layer.cornerRadius, curve: contentView.layer.cornerCurve)
            }
            set {}
        }
    }
}
