# KeyboardKit

KeyboardKit makes it easy to add hardware keyboard control to iOS and Mac Catalyst apps.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

Apps created with AppKit tend to have better support for keyboard control compared to UIKit-based apps because most AppKit components respond to key input out of the box, while most UIKit components do not. KeyboardKit narrows this gap by providing subclasses of UIKit components that respond to key commands.

## Features

- [Keyboard cell selection](/Features.md#cell-selection) (collection views, table views)
- [Keyboard navigation](/Features.md#navigation) (split views, navigation controllers, tab bars, modals)
- [Keyboard scrolling and zooming](/Features.md#scrolling-and-zooming) (including page up, page down, home, end)
- [Key equivalents for bar buttons](Features.md#key-equivalents-for-buttons) (navigation bars, toolbars)
- [Advanced text navigation](Features.md#advanced-text-navigation) (find next/previous, define)
- [Keyboard window management](Features.md#window-management) (open, close, cycle)
- [Keyboard date picker](Features.md#date-picker) (change day, week, month or year)
- [Discoverability titles in 39 localisations](Features.md#localisation)

## Requirements

KeyboardKit supports iOS 12.0 onwards on iPad, iPhone and Mac Catalyst (both scaled and optimised). tvOS is not supported. The latest Xcode 12.x is required.

⚠️ Xcode 13 (iOS 15 SDK) should not be used yet because the new UIKit focus system takes precedence over key commands, which means arrow keys will not work with KeyboardKit. Work is in progress integrating with the focus system. If you want a quick fix for arrow keys not working in table views and collection views when using the iOS 15 SDK, please use the `xcode13` branch.

Both Swift and Objective-C apps are supported. Since KeyboardKit is implemented in Swift, it’s not possible subclass KeyboardKit classes from Objective-C. However all other features of KeyboardKit are available to Objective-C apps.

## Installation

### Swift Package Manager

Add KeyboardKit to an existing Xcode project as a package dependency:

1. From the File menu, select Swift Packages › Add Package Dependency…
2. Enter "https://github.com/douglashill/KeyboardKit" into the package repository URL text field.

### Direct

1. Clone this repository.
2. Drag `KeyboardKit.xcodeproj` into your Xcode project.
3. Add the KeyboardKit target as a dependency of your target.
4. Add `KeyboardKit.framework` as an embedded framework.

This Swift package contains localised resources, so Swift 5.3 (Xcode 12) or later is required.

Swift Package Manager requires the Swift and Objective-C sources to be separated into modules. The `KeyboardKitObjC` module is used internally by KeyboardKit and does not need to be imported explicitly by your app.

### CocoaPods

[KeyboardKit is available on CocoaPods](https://cocoapods.org/pods/Keyboard-Kit) as `Keyboard-Kit`.

Please [open a pull request](https://github.com/douglashill/KeyboardKit/pulls) if you notice any integration problems.

## Usage

Import the framework:

```swift
import KeyboardKit
```

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

## Customisation

The public API is currently kept minimal so components are easy to drop in. If there is something you’d like to be able to customise in KeyboardKit, please [open an issue](https://github.com/douglashill/KeyboardKit/issues) to discuss. You could also consider directly integrating the source code and modify it as needed.

## Learn more

- Conference talk: [*Keyboard control in UIKit apps* at iOS Conf SG 2020](https://engineers.sg/video/full-keyboard-control-in-uikit-apps-ios-conf-sg-2020--3933)
- Podcast discussion: [iPhreaks episode 297](https://devchat.tv/iphreaks/ips-297-keyboard-controls-with-douglas-hill/)
- Blog post: [What’s New in KeyboardKit for iOS 14?](https://douglashill.co/whats-new-in-keyboardkit-for-ios-14/)
- [Change log](/CHANGELOG.md)

## Credits

KeyboardKit is a project from [Douglas Hill](https://douglashill.co/) with the kind help of [contributors](https://github.com/douglashill/KeyboardKit/graphs/contributors). Some concepts were originally developed for [PSPDFKit](https://pspdfkit.com/) and reimplemented in Swift for KeyboardKit. I use KeyboardKit in my [reading app](https://douglashill.co/reading-app/).

## Contributing

I’d love to have help on this project. For small changes please [open a pull request](https://github.com/douglashill/KeyboardKit/pulls), for larger changes please [open an issue](https://github.com/douglashill/KeyboardKit/issues) first to discuss what you’d like to see.

Tests are not required for new functionality, but fixed regressions should have automated tests. Use `KeyboardKitTests` for unit tests that don’t need views or a responder chain. Use `KeyboardKitDemoUITests` for integration tests that can be reproduced in the demo app. This only works on Mac Catalyst currently because iOS does not allow simulating hardware keyboard input. Use `KeyboardKitUITests` for any test cases between, which is probably most cases.

## Licence

MIT license — see [License.txt](/License.txt)
