// Douglas Hill, August 2020

import KeyboardKit

class ListViewController: FirstResponderViewController, UICollectionViewDataSource {
    override init() {
        super.init()
        title = "List"
        tabBarItem.image = UIImage(systemName: "list.dash")
    }

    private let cellReuseIdentifier = "a"
    private lazy var collectionView: UICollectionView = {

        // TODO: Section headers

        let listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return KeyboardCollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        47
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! UICollectionViewListCell

        var content = cell.defaultContentConfiguration()
        content.text = "\(indexPath.item)"
        cell.contentConfiguration = content

        return cell
    }
}
