// Douglas Hill, November 2019

import UIKit
import KeyboardKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let windowScene = scene as! UIWindowScene

        let tabBarController = KeyboardTabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: SimpleListViewController()),
            UINavigationController(rootViewController: CirclesScrollViewController()),
        ]

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
