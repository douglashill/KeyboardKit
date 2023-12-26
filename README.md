# KeyboardKit

The easiest way to add comprehensive hardware keyboard control to an iPad, iPhone, or Mac Catalyst app.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

KeyboardKit is designed to integrate with the UIKit focus system when available (iPad with iOS 15+, macOS 11+), and it provides similar arrow and tab key navigation on OS versions where the focus system is not available (iPhone, iPad with iOS 13–14, macOS 10.15).

## Features

- [Keyboard navigation without the focus system](/Features.md#keyboard-navigation-without-the-focus-system) (navigate with arrow keys and tab key)
- [Additional navigation commands](/Features.md#additional-navigation-commands) (dismiss modals, change tabs, go back)
- [Collection view and table view commands](/Features.md#collection-view-and-table-view-commands) (reorder, delete, select all)
- [Keyboard scrolling and zooming](/Features.md#scrolling-and-zooming) (including page up, page down, home, end — and map views)
- [Key equivalents for buttons](Features.md#key-equivalents-for-buttons) (SwiftUI buttons, UIKit bar button items)
- [Advanced text navigation](Features.md#advanced-text-navigation) (find next/previous, define)
- [Keyboard window management](Features.md#window-management) (open, close, cycle)
- [Keyboard date picker](Features.md#date-picker) (change day, week, month or year)
- [Main menu and discoverability HUD](Features.md#main-menu-and-discoverability-hud) (group commands under File, Edit, View etc.)
- [Discoverability titles in 39 localisations](Features.md#localisation)

## Requirements

Xcode 14.1 or later is required. KeyboardKit supports iOS 13 onwards on iPad, iPhone and Mac Catalyst (both scaled and optimised). tvOS is not supported.

## Installation

### Swift Package Manager

Add KeyboardKit to an existing Xcode project as a package dependency:

1. Navigate to your project settings and then the Package Dependencies tab.
2. Click the + button. 
2. Enter https://github.com/douglashill/KeyboardKit into the search or package URL field.

### Direct

1. Clone this repository.
2. Drag `KeyboardKit.xcodeproj` into your Xcode project.
3. Add the KeyboardKit target as a dependency of your target.
4. Add `KeyboardKit.framework` to your target as an embedded framework.

Swift Package Manager requires the Swift and Objective-C sources to be separated into modules. The `KeyboardKitObjC` module is used internally by KeyboardKit and does not need to be imported explicitly by your app.

### CocoaPods (legacy)

Up until version 8.2.0, [KeyboardKit was available on CocoaPods](https://cocoapods.org/pods/Keyboard-Kit) as `Keyboard-Kit`. Please use Swift Package Manager or direct installation instead.

## Usage

Import the framework:

```swift
import KeyboardKit
```

### UIKit

Instead of creating or subclassing a UIKit class directly, use the subclasses from KeyboardKit instead. All KeyboardKit subclasses are named by changing `UI` to `Keyboard`. For example replace

```swift
class SettingsViewController: UICollectionViewController {
    ...
}
```

with

```swift
class SettingsViewController: KeyboardCollectionViewController {
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

You can see more in the KeyboardKitDemo app, and each class includes API documentation in their Swift source file.

### SwiftUI

When using the `.keyboardShortcut` modifier on a `Button`, access semantically defined `KeyboardShortcut`s for common actions within the `.KeyboardKit` namespace: 

```swift
Button("Save") {
    // Save something here in the button action
}
.keyboardShortcut(.KeyboardKit.save)
```

This adds the ability trigger the action of the button by pressing ⌘S.

## Learn more

- Conference talk: [*Keyboard control in UIKit apps* at iOS Conf SG 2020](https://engineers.sg/video/full-keyboard-control-in-uikit-apps-ios-conf-sg-2020--3933)
- Podcast discussion: [iPhreaks episode 297](https://devchat.tv/iphreaks/ips-297-keyboard-controls-with-douglas-hill/)
- Blog post: [What’s New in KeyboardKit for iOS 14?](https://douglashill.co/whats-new-in-keyboardkit-for-ios-14/)
- [Change log](/CHANGELOG.md)

## Credits

KeyboardKit is a project from [Douglas Hill](https://douglashill.co/) with the generous help of [contributors](https://github.com/douglashill/KeyboardKit/graphs/contributors). Some concepts were originally developed for [PSPDFKit](https://pspdfkit.com/) and reimplemented in Swift for KeyboardKit. I use KeyboardKit in my [reading app](https://douglashill.co/reading-app/).

## Contributing

I’d love to have help on this project. For small changes please [open a pull request](https://github.com/douglashill/KeyboardKit/pulls); for larger changes please [open an issue](https://github.com/douglashill/KeyboardKit/issues) first to discuss what you’d like to see.

Tests are not required for new functionality, but fixed regressions should have automated tests. Use `KeyboardKitTests` for unit tests that don’t need views or a responder chain. Use `KeyboardKitDemoUITests` for integration tests that can be reproduced in the demo app. This only works on Mac Catalyst currently because iOS does not allow simulating hardware keyboard input. Use `KeyboardKitUITests` for any test cases between, which is probably most cases.

## Licence

MIT license — see [License.txt](/License.txt)
