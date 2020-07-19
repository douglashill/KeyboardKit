// Douglas Hill, May 2019

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
    }

    private let numberOfItems = 47

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
    }

    class Cell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)

            contentView.layer.cornerRadius = 25
            contentView.layer.cornerCurve = .continuous
            contentView.layer.borderColor = UIColor.label.cgColor
            contentView.backgroundColor = .secondarySystemGroupedBackground
        }

        required init?(coder decoder: NSCoder) { preconditionFailure() }

        override var isSelected: Bool {
            didSet {
                contentView.layer.borderWidth = isSelected ? 2 : 0
            }
        }
    }
}
