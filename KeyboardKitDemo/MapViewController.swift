// Douglas Hill, March 2020

import KeyboardKit

class MapViewController: FirstResponderViewController {
    override init() {
        super.init()
        title = "Map"
        tabBarItem.image = UIImage(systemName: "map")
    }

    private lazy var mapView = KeyboardMapView()

    override func loadView() {
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Without this, we end up with a transparent navigation bar background with the map content underneath.
        navigationItem.scrollEdgeAppearance = navigationController!.navigationBar.standardAppearance
    }
}
