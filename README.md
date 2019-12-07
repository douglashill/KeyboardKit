# KeyboardKit

KeyboardKit is a framework to help iOS and Mac Catalyst apps support being controlled using a hardware keyboard.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

Apps created with AppKit tend to have better support for keyboard control compared to UIKit-based apps. I believe the principal reason for this is that most AppKit components respond to key input out of the box, while most UIKit components do not. KeyboardKit aims to narrow this gap by providing subclasses of UIKit components that respond to key commands.

## Status

This project is in its early stages, and is under active development. So far these components are available:

- `KeyboardTableView`: A `UITableView` subclass that supports navigation and selection using arrow keys and space or return.
- `KeyboardScrollView`: A `UIScrollView` subclass that supports scrolling using arrow keys, option + arrow keys, command + arrow keys, space, page up, page down, home and end.
- `KeyboardTextView`: A `UITextView` subclass that supports find next (cmd + G), find previous (cmd + shift + G), use selection for find (cmd + E), and jump to selection (cmd + J).
- `KeyboardTabBarController`: A `UITabBarController` subclass that supports navigating between tabs using cmd + 1, cmd + 2 etc.
- `KeyboardApplication` and `KeyboardWindowScene`: `UIApplication` and `UIWindowScene` subclasses that support making new windows (cmd + N), closing windows (cmd + W), cycling keyboard focus between visible windows (cmd + \`), and showing app settings in the Settings app (cmd + ,).

User facing text is currently only localised in English.

## Requirements

At this early stage the project has only been tested on iOS 13 and Xcode 11.2.1. Supporting back to iOS 11 is not anticipated to be a problem.

KeyboardKit is written in Swift.

## Usage

Instead of creating or subclassing a UIKit class directly, use the subclasses from KeyboardKit instead.

In order to receive key commands, an object must be on the [responder chain](https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events).

## Licence

MIT license — see License.txt
