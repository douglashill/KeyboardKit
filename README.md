# KeyboardKit

KeyboardKit is a framework to help iOS and Mac Catalyst apps support being controlled using a hardware keyboard.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

Apps created with AppKit tend to have better support for keyboard control compared to UIKit-based apps. I believe the principal reason for this is that most AppKit components respond to key input out of the box, while most UIKit components do not. KeyboardKit aims to narrow this gap by providing subclasses of UIKit components that respond to key commands.

## Status

This project is in its early stages, and is under active development. So far these components are available:

- `KeyboardTableView`: A `UITableView` subclass that supports navigation and selection using arrow keys and space or return.
- `KeyboardScrollView`: A `UIScrollView` subclass that supports scrolling using arrow keys, opt + arrow keys, cmd + arrow keys, space, page up, page down, home and end. It also supports zooming using cmd + 0/−/+.
- `KeyboardTextView`: A `UITextView` subclass that supports find next (cmd + G), find previous (cmd + shift + G), use selection for find (cmd + E), and jump to selection (cmd + J).
- `KeyboardNavigationController`: a `UINavigationController` subclass that supports going back (cmd + left) and triggering the actions of the bar button items in the navigation bar and toolbar if they are instances of `KeyboardBarButtonItem`. Default key equivalents are provided for most system bar button items.
- `KeyboardTabBarController`: A `UITabBarController` subclass that supports navigating between tabs using cmd + 1, cmd + 2 etc.
- `KeyboardWindow`: A `UIWindow` subclass that supports using escape on a hardware keyboard to dismiss any topmost modal sheet or popover. Escape is available as cmd + . on Apple Smart Keyboards.
- `KeyboardApplication` and `KeyboardWindowScene`: `UIApplication` and `UIWindowScene` subclasses that support making new windows (cmd + N), closing windows (cmd + W), cycling keyboard focus between visible windows (cmd + \`), and showing app settings in the Settings app (cmd + ,).

User facing text is currently only localised in English.

## Requirements

At this early stage the project has only been tested on iOS 13 and Xcode 11.2.1. Supporting back to iOS 11 is not anticipated to be a problem.

KeyboardKit is written in Swift.

## Installation

### CocoaPods

1. Add the following line to your `podfile`:

```swift
pod 'Keyboard-Kit'
```
2. Run the following command in terminal:

```swift
pod install
```
3. Import the framework

```swift
import KeyboardKit
```


## Usage

Instead of creating or subclassing a UIKit class directly, use the subclasses from KeyboardKit instead.

In order to receive key commands, an object must be on the [responder chain](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events).

## Licence

MIT license — see License.txt
