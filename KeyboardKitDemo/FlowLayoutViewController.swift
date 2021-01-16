// Douglas Hill, December 2019

import KeyboardKit

class FlowLayoutViewController: FirstResponderViewController, UICollectionViewDataSource {
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

        return KeyboardCollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.dataSource = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.accessibilityIdentifier = "flow layout collection view"
    }

    private static let freshData: [String] = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut

        var d: [String] = []
        for index in 0..<50 {
            d.append(formatter.string(from: NSNumber(value: index + 1))!)
        }
        return d
    }()

    private var data: [String] = freshData

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! Cell
        cell.label.text = data[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = data.remove(at: sourceIndexPath.item)
        data.insert(item, at: destinationIndexPath.item)
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
    }
}
