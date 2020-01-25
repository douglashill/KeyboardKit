// Douglas Hill, May 2019

import KeyboardKit

class FlowLayoutViewController: KeyboardCollectionViewController {
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 150, height: 150)
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        super.init(collectionViewLayout: flowLayout)
        title = "Flow Layout"
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }

    private let cellReuseIdentifier = "a"

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.register(Cell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView!.backgroundColor = .systemGroupedBackground
    }

    private let numberOfItems = 47

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
    }

    class Cell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)

            contentView.layer.cornerRadius = 25
            contentView.layer.cornerCurve = .continuous
            contentView.layer.borderColor = UIColor.black.cgColor
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
