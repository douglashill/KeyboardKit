// Douglas Hill, May 2021

import UIKit

// This is a blank application in which KeyboardKitUITests can add views for testing.

@main class AppDelegate: UIResponder, UIApplicationDelegate {}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private var _window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        _window = window
    }
}
