#  Using KeyboardSplitViewController

`KeyboardSplitViewController` can’t implement split view keyboard control entirely on its own. Your app’s support for full keyboard control is only as good as your first responder management, and first responder management is very specific to each app. Therefore `KeyboardSplitViewController` takes a very hands-off approach. It does the reusable part of tracking which of its columns is focused in the `focusedColumn` property. The value of this property will be updated in response to keyboard input and any events that change the visible columns.

Your app must update the first responder in response to changes to this property by providing a `delegate` for the split view controller that conforms to the `KeyboardSplitViewControllerDelegate` protocol. This might be a parent view controller or perhaps your scene delegate. A simple setup might be done like this:

```swift
let splitViewController = KeyboardSplitViewController(style: .doubleColumn)
splitViewController.delegate = self
splitView.setViewController(KeyboardNavigationController(rootViewController: self.sidebarViewController), for: .primary)
splitView.setViewController(KeyboardNavigationController(rootViewController: self.contentViewController), for: .secondary)
```

Using `KeyboardNavigationController` for your columns is not required but is recommended to benefit from automatic support for key commands to go back and activate bar button items.

In the delegate’s implementation of `didChangeFocusedColumn`, update the first responder in a way appropriate to your app. For example a simple implementation would be:

```swift
func didChangeFocusedColumn(inSplitViewController splitViewController: KeyboardSplitViewController) {
    if splitViewController.isCollapsed {
        // Maybe handle the collapsed case. See below.
    } else if splitViewController.focusedColumn == .primary {
        self.sidebarViewController.becomeFirstResponder()
    } else {
        self.contentViewController.becomeFirstResponder()
    }
}
```

The `focusedColumn` is always considered to be `nil` when the split view is collapsed. You may need to handle collapsed case depending on your app. In this simple example nothing needs to be done because KeyboardSplitViewController already makes sure the focused column stays visible when collapsing and since the view controller in that column was first responder before it will remain first responder after collapsing.

To see fully functional examples, check out `DoubleColumnSplitViewController` and `TripleColumnListViewController` in the KeyboardKit demo app. 
