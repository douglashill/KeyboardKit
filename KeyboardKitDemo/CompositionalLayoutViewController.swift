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
        let nestedGroupsSection = { () -> NSCollectionLayoutSection in
            let standardInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            
            let horizontalStackingSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
            let verticalStackingSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))

            let horizontallyStackingItem = NSCollectionLayoutItem(layoutSize: horizontalStackingSize)
            horizontallyStackingItem.contentInsets = standardInsets
            let verticallyStackingItem = NSCollectionLayoutItem(layoutSize: verticalStackingSize)
            verticallyStackingItem.contentInsets = standardInsets

            let group5 = NSCollectionLayoutGroup.horizontal(layoutSize: verticalStackingSize, subitems: [horizontallyStackingItem, horizontallyStackingItem])
            let group4 = NSCollectionLayoutGroup.vertical(layoutSize: horizontalStackingSize, subitems: [verticallyStackingItem, group5])
            let group3 = NSCollectionLayoutGroup.horizontal(layoutSize: verticalStackingSize, subitems: [horizontallyStackingItem, group4])
            let group2 = NSCollectionLayoutGroup.vertical(layoutSize: horizontalStackingSize, subitems: [verticallyStackingItem, group3])
            let group1 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200)), subitems: [horizontallyStackingItem, group2])

            let section = NSCollectionLayoutSection(group: group1)
            section.contentInsets = standardInsets
            return section
        }()

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 12

        let layout = UICollectionViewCompositionalLayout(section: nestedGroupsSection, configuration: config)

        return KeyboardCollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.dataSource = self
        collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.accessibilityIdentifier = "compositional layout collection view"

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
        let sectionData = (0..<50).map {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! UICollectionViewListCell

        var content = cell.defaultContentConfiguration()
        content.text = data[indexPath.section][indexPath.item]
        content.textProperties.alignment = .center
        cell.contentConfiguration = content

        var background = UIBackgroundConfiguration.listGroupedCell()
        background.cornerRadius = 8
        cell.backgroundConfiguration = background

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = data[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        data[destinationIndexPath.section].insert(item, at: destinationIndexPath.item)
    }

    @objc private func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.data = CompositionalLayoutViewController.freshData
            self.collectionView.reloadData()
            sender.endRefreshing()
        }
    }
}
