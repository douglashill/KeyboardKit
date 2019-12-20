// Douglas Hill, November 2019

import UIKit
import KeyboardKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: KeyboardWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let windowScene = scene as! UIWindowScene

        let tabBarController = KeyboardTabBarController()
        tabBarController.viewControllers = [
            KeyboardNavigationController(rootViewController: SimpleListViewController()),
            KeyboardNavigationController(rootViewController: FlowLayoutViewController()),
            KeyboardNavigationController(rootViewController: CirclesScrollViewController()),
            KeyboardNavigationController(rootViewController: PagingScrollViewController()),
            KeyboardNavigationController(rootViewController: TextViewController()),
        ]

        let window = KeyboardWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
