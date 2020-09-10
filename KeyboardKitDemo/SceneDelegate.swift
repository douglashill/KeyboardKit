// Douglas Hill, November 2019

import UIKit
import KeyboardKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: KeyboardWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let windowScene = scene as! UIWindowScene

        let rootViewController = SplitContainer(viewControllers: [
            TableViewController(),
            ListViewController(),
            CompositionalLayoutViewController(),
            FlowLayoutViewController(),
            CirclesScrollViewController(),
            PagingScrollViewController(),
            TextViewController(),
        ])

        rootViewController.title = "KeyboardKit"

        let window = KeyboardWindow(windowScene: windowScene)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window

        NotificationCenter.default.addObserver(self, selector: #selector(updateSafeAreaForKeyboardFromNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSafeAreaForKeyboardFromNotification), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

    /// Deals with avoiding the software keyboard globally (or more likely the bar that’s shown when a hardware keyboard is connected).
    /// This is needed for TextViewController, and also if another app in Split View is showing the keyboard.
    /// Taken from https://gist.github.com/douglashill/41ea84f0ba59feecd3be51f21f73d501
    @objc private func updateSafeAreaForKeyboardFromNotification(_ notification: Notification) {
        guard
            let endFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let window = window,
            let viewController = window.rootViewController
        else {
            return
        }

        let view = viewController.view!
        let endFrameInSelfCoords = view.convert(endFrameInScreenCoords, from: window.screen.coordinateSpace)

        // Need to clear the additionalSafeAreaInsets in order to be able to read the unaltered safeAreaInsets. We’ll set it again just below.
        viewController.additionalSafeAreaInsets = .zero
        let safeBounds = view.bounds.inset(by: view.safeAreaInsets)

        let isDocked = endFrameInSelfCoords.maxY >= safeBounds.maxY
        let keyboardOverlapWithViewFromBottom = isDocked ? max(0, safeBounds.maxY - endFrameInSelfCoords.minY) : 0

        viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardOverlapWithViewFromBottom, right: 0)
    }
}
