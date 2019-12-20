// Douglas Hill, May 2019

import UIKit
import KeyboardKit

class FlowLayoutViewController: FirstResponderViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    override var title: String? {
        get { "Flow Layout" }
        set {}
    }

    private let cellReuseIdentifier = "a"
    private var collectionView: KeyboardCollectionView?

    override func loadView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 150, height: 150)
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        collectionView = KeyboardCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), collectionViewLayout: flowLayout)
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.dataSource = self
        collectionView!.register(Cell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView!.backgroundColor = .systemGroupedBackground
    }

    private let numberOfItems = 47

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

        required init?(coder decoder: NSCoder) { fatalError() }

        override var isSelected: Bool {
            didSet {
                contentView.layer.borderWidth = isSelected ? 2 : 0
            }
        }
    }
}
