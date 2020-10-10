# KeyboardKit

KeyboardKit makes it easy to add hardware keyboard control to iOS and Mac Catalyst apps.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

Apps created with AppKit tend to have better support for keyboard control compared to UIKit-based apps. I believe the principal reason for this is that most AppKit components respond to key input out of the box, while most UIKit components do not. KeyboardKit aims to narrow this gap by providing subclasses of UIKit components that respond to key commands.

## Features

- [Keyboard navigation and selection](/Features.md#navigation-and-selection)
- [Key equivalents for buttons](Features.md#key-equivalents-for-buttons)
- [Advanced text navigation](Features.md#advanced-text-navigation)
- [Keyboard window management](Features.md#window-management)
- [39 localisations](Features.md#localisation)
- [Clean implementation](Features.md#clean-implementation)

## Requirements

KeyboardKit supports from iOS 12.0 onwards. The latest Xcode 12.x is required.

Both Swift and Objective-C apps are supported. Since KeyboardKit is implemented in Swift, it’s not possible subclass KeyboardKit classes from Objective-C. However all other features of KeyboardKit are available to Objective-C apps.

## Installation

### Direct

1. Clone this repository.
2. Drag `KeyboardKit.xcodeproj` into your Xcode project.
3. Add the KeyboardKit target as a dependency of your target.
4. Add `KeyboardKit.framework` as an embedded framework.

### Swift Package Manager

Add KeyboardKit to an existing Xcode project as a package dependency:

1. From the File menu, select Swift Packages › Add Package Dependency…
2. Enter "https://github.com/douglashill/KeyboardKit" into the package repository URL text field.

This Swift package contains localised resources, so Swift 5.3 (Xcode 12) or later is required.

Swift Package Manager requires the Swift and Objective-C sources to be separated into modules. The `KeyboardKitObjC` module is used internally by KeyboardKit and does not need to be imported explicitly by your app.

### CocoaPods

1. Add the following to your `Podfile`:
    
    ```ruby
    pod 'Keyboard-Kit'
    ```
    
2. Run the following command:
    
    ```
    pod install
    ```

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

## Approach to API and testing

The public API is currently kept minimal. Exposing more API without first understanding use-cases would increase the chances of having to make breaking API changes. If there is something you’d like to be able to customise in KeyboardKit, please [open an issue](https://github.com/douglashill/KeyboardKit/issues) to discuss.

KeyboardKit does not have many automated tests. This is a deliberate choice coming from considering where time spent on the project is most valuable. If functionality starts breaking then automated tests must be added, but until that point is hit I think time is better invested elsewhere.

## Credits

KeyboardKit is a project from [Douglas Hill](https://douglashill.co/) with the kind help of [contributors](https://github.com/douglashill/KeyboardKit/graphs/contributors). Some concepts were originally developed for [PSPDFKit](https://pspdfkit.com/) and reimplemented in Swift for KeyboardKit. I use KeyboardKit in my [reading app](https://douglashill.co/reading-app/).

## Learn more

- Conference talk: [*Keyboard control in UIKit apps* at iOS Conf SG 2020](https://engineers.sg/video/full-keyboard-control-in-uikit-apps-ios-conf-sg-2020--3933) 
- Podcast discussion: [iPhreaks episode 297](https://devchat.tv/iphreaks/ips-297-keyboard-controls-with-douglas-hill/)

## Contributing

I’d love to have help on this project. For small changes please [open a pull request](https://github.com/douglashill/KeyboardKit/pulls), for larger changes please [open an issue](https://github.com/douglashill/KeyboardKit/issues) first to discuss what you’d like to see.

## Licence

MIT license — see License.txt
