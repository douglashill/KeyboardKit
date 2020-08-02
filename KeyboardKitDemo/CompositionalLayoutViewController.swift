// Douglas Hill, August 2020

import KeyboardKit

class CompositionalLayoutViewController: FirstResponderViewController, UICollectionViewDataSource {
    override init() {
        super.init()
        title = "Compositional Layout"
        tabBarItem.image = UIImage(systemName: "rectangle.3.offgrid")
    }

    private let cellReuseIdentifier = "a"
    private lazy var collectionView: UICollectionView = {
        let ignored = NSCollectionLayoutDimension.absolute(9999)

        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: ignored, heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), subitem: item, count: 3)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return KeyboardCollectionView(frame: .zero, collectionViewLayout: layout)
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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        47
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
