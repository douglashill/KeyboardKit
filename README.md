# KeyboardKit

KeyboardKit makes it easy to add hardware keyboard control to iOS and Mac Catalyst apps.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

Apps created with AppKit tend to have better support for keyboard control compared to UIKit-based apps. I believe the principal reason for this is that most AppKit components respond to key input out of the box, while most UIKit components do not. KeyboardKit aims to narrow this gap by providing subclasses of UIKit components that respond to key commands.

## Status

This project is relatively new and is under active development. So far these components are available:

- `KeyboardTableView`(`Controller`): A `UITableView`(`Controller`) subclass that supports navigation and selection using arrow keys and space or return, including wrapping back to the top/bottom and selecting the top/bottom item by holding option. It also supports deleting when using `UITableViewCellEditingStyleDelete` (delete key), refreshing (⌘R) and scrolling with page up, page down, home and end. Does not support multiple selection except for selecting all rows (⌘A). 
- `KeyboardCollectionView`(`Controller`): A `UICollectionView`(`Controller`) subclass that supports navigation and selection using arrow keys and space or return. It supports refreshing (⌘R) and scrolling with page up, page down, home and end. Does not support multiple selection except for selecting all rows (⌘A). Does not support wrapping or selecting to the end by holding option.
- `KeyboardScrollView`: A `UIScrollView` subclass that supports scrolling using arrow keys, space, page up, page down, home and end. It also supports zooming (⌘0, ⌘−, ⌘+).
- `KeyboardTextView`: A `UITextView` subclass that supports find next (⌘G), find previous (⇧⌘G), use selection for find (⌘E), and jump to selection (⌘J).
- `KeyboardNavigationController`: a `UINavigationController` subclass that supports going back (⌘←) and triggering the actions of the bar button items in the navigation bar and toolbar if they are instances of `KeyboardBarButtonItem`. Default key equivalents are provided for most system bar button items.
- `KeyboardTabBarController`: A `UITabBarController` subclass that supports navigating between tabs using ⌘1, ⌘2 etc.
- `KeyboardWindow`: A `UIWindow` subclass that supports using escape on a hardware keyboard to dismiss any topmost modal sheet or popover. Escape is available as ⌘. on Apple Smart Keyboards.
- `KeyboardApplication` and `KeyboardWindowScene`: `UIApplication` and `UIWindowScene` subclasses that support making new windows (⌥⌘N), closing windows (⇧⌘W), cycling keyboard focus between visible windows (⌘\`), and showing app settings in the Settings app (⌘,).

User-facing text is currently only localised in English.

The public API is currently kept minimal. Exposing more API without first understanding use-cases would increase the chances of having to make breaking API changes. If there is something you’d like to be able to customise in KeyboardKit, please [open an issue](https://github.com/douglashill/KeyboardKit/issues) to discuss.

## Requirements

The framework deployment target is iOS 11.0. However at this early stage the project has only been tested on iOS 13. The latest Xcode 11.x is required.

KeyboardKit is written in Swift with a very small amount of Objective-C.

## Installation

### Recommended

1. Clone this repository.
2. Drag `KeyboardKit.xcodeproj` into your Xcode project.
3. Add the KeyboardKit target as a dependency of your target.
4. Add `KeyboardKit.framework` as an embedded framework.

### CocoaPods

CocoaPods requires some manual work to keep it up-to-date, and it may not be as well tested as the recommended steps above. Please [open a pull request](https://github.com/douglashill/KeyboardKit/pulls) if you notice any problems.

1. Add the following to your `Podfile`:
    
    ```ruby
    pod 'Keyboard-Kit'
    ```
    
2. Run the following command:
    
    ```
    pod install
    ```

## Usage

Import the framework:

```swift
import KeyboardKit
```

Instead of creating or subclassing a UIKit class directly, use the subclasses from KeyboardKit instead. All KeyboardKit subclasses are named by changing `UI` to `Keyboard`. For example replace

```swift
class SettingsViewController: UITableViewController {
    ...
}
```

with

```swift
class SettingsViewController: KeyboardTableViewController {
    ...
}
```

Or create KeyboardKit subclasses directly:

```swift
let tabBarController = KeyboardTabBarController()
tabBarController.viewControllers = [
    KeyboardNavigationController(rootViewController: SettingsViewController()),
]
```

In order to receive key commands, an object must be on the [responder chain](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events).

You can see more in the KeyboardKitDemo app.

## Contributing

I’d love to have help on this project. For small changes please [open a pull request](https://github.com/douglashill/KeyboardKit/pulls), for larger changes please [open an issue](https://github.com/douglashill/KeyboardKit/issues) first to discuss what you’d like to see.

## Private API use

KeyboardKit uses the undocumented strings `UIKeyInputPageUp`, `UIKeyInputPageDown`, `UIKeyInputHome` and `UIKeyInputEnd`. This should be very safe: they’re just strings. Please get in touch if you know any other way to support scrolling with the Page Up, Page Down, Home and End keys.

`KeyboardBarButtonItem` safely calls the private `view` property on `UIBarButtonItem` to obtain the accessibility label of system bar button items, so that associated key equivalents can be shown to the user in the discoverability overlay on iPad. This could be removed if KeyboardKit provided its own localised text for system bar button items, but that’s not ideal given the system already has this text in a large number of languages.

## Licence

MIT license — see License.txt
