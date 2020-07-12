# KeyboardKit

KeyboardKit makes it easy to add hardware keyboard control to iOS and Mac Catalyst apps.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

Apps created with AppKit tend to have better support for keyboard control compared to UIKit-based apps. I believe the principal reason for this is that most AppKit components respond to key input out of the box, while most UIKit components do not. KeyboardKit aims to narrow this gap by providing subclasses of UIKit components that respond to key commands.

## Features

| Feature                                            | Key input                   | Available with                                                                                                                                                                                                                                  | Notes                                                                                                                                                                                              |
| -------------------------------------------------- | --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Select item above, below, left or right            | arrow                       | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                                                                                                                | Wraps in table views or collection views with `UICollectionViewFlowLayout`. Does not support multiple selection.                                                                                   |
| Select item at top, bottom, far left, or far right | ⌥ arrow                     | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                                                                                                                | Modifier key chosen to be consistent with `NSTableView`.                                                                                                                                           |
| Activate selection                                 | return, space               | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                                                                                                                | This will notify the delegate with `didSelectRowAtIndexPath:`.                                                                                                                                     |
| Delete selection                                   | delete                      | `KeyboardTableView`, `KeyboardTableViewController`                                                                                                                                                                                              | Table view delegate must implement `tableView:commitEditingStyle:forRowAtIndexPath:`.                                                                                                              |
| Delete                                             | ⌘ delete                    | `KeyboardBarButtonItem` with `SystemItem.trash` in `KeyboardNavigationController`                                                                                                                                                               |                                                                                                                                                                                                    |
| Select all                                         | ⌘A                          | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                                                                                                                |                                                                                                                                                                                                    |
| Clear selection                                    | esc                         | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                                                                                                                |                                                                                                                                                                                                    |
| Scroll by small step                               | arrow                       | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView`                                                                                      | Only available in table and collection views when selection is disabled. Only available in text views when editing is disabled. This will scroll by page if `isPagingEnabled` is set.              |
| Scroll by page                                     | ⌥ arrow, page up, page down | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView`                                                                                      | Using arrows keys is only available in table and collection views when selection is disabled and in text views when editing is disabled. Same as without the modifier if `isPagingEnabled` is set. |
| Scroll to top, bottom, far left, or far right      | ⌘ arrow, home, end          | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView`                                                                                      | Using arrows keys is only available in table and collection views when selection is disabled and in text views when editing is disabled.                                                           |
| Zoom in                                            | ⌘+                          | `KeyboardScrollView`                                                                                                                                                                                                                            | Actual input is ⌘= but this shows as ⌘+ to match expectations.                                                                                                                                     |
| Zoom out                                           | ⌘−                          | `KeyboardScrollView`                                                                                                                                                                                                                            |                                                                                                                                                                                                    |
| Zoom to actual size                                | ⌘0                          | `KeyboardScrollView`                                                                                                                                                                                                                            |                                                                                                                                                                                                    |
| Refresh                                            | ⌘R                          | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView`, `KeyboardBarButtonItem` with `SystemItem.refresh` in `KeyboardNavigationController` | Available either with a scroll view with a `refreshControl` or with a bar button item.                                                                                                             |
| Reply                                              | ⌘R                          | `KeyboardBarButtonItem` with `SystemItem.reply` in `KeyboardNavigationController`                                                                                                                                                               |                                                                                                                                                                                                    |
| Find next                                          | ⌘G                          | `KeyboardTextView`                                                                                                                                                                                                                              |                                                                                                                                                                                                    |
| Find previous                                      | ⇧⌘G                         | `KeyboardTextView`                                                                                                                                                                                                                              |                                                                                                                                                                                                    |
| Jump to selection                                  | ⌘J                          | `KeyboardTextView`                                                                                                                                                                                                                              |                                                                                                                                                                                                    |
| Use selection for find                             | ⌘E                          | `KeyboardTextView`                                                                                                                                                                                                                              |                                                                                                                                                                                                    |
| Edit                                               | ⌘E                          | `KeyboardBarButtonItem` with `SystemItem.edit` in `KeyboardNavigationController`                                                                                                                                                                |                                                                                                                                                                                                    |
| Go back                                            | ⌘←, ⌘[                      | `KeyboardNavigationController`                                                                                                                                                                                                                  | Inputs are reversed for right-to-left layout.                                                                                                                                                      |
| Select tab                                         | ⌘ number                    | `KeyboardTabBarController`                                                                                                                                                                                                                      |                                                                                                                                                                                                    |
| Dismiss any sheet or popover                       | esc, ⌘W                     | `KeyboardWindow`                                                                                                                                                                                                                                | This respects `isModalInPresentation`.                                                                                                                                                             |
| Cancel                                             | esc                         | `KeyboardBarButtonItem` with `SystemItem.cancel` in `KeyboardNavigationController`                                                                                                                                                              |                                                                                                                                                                                                    |
| Done                                               | ⌘ return                    | `KeyboardBarButtonItem` with `SystemItem.done` in `KeyboardNavigationController`                                                                                                                                                                |                                                                                                                                                                                                    |
| Close                                              | ⌘W                          | `KeyboardBarButtonItem` with `SystemItem.close` in `KeyboardNavigationController`                                                                                                                                                               |                                                                                                                                                                                                    |
| Close window                                       | ⇧⌘W                         | `KeyboardWindowScene`                                                                                                                                                                                                                           | Keys chosen to leave ⌘W for closing a tab or modal within a window. This matches the Mac when a window has tabs.                                                                                   |
| Cycle focused window                               | ⌘\`                         | `KeyboardWindowScene`                                                                                                                                                                                                                           | Changes the key window. Only works with visible windows. There does not seem to be any API to activate a non-visible window scene without breaking the user’s spaces.                              |
| Add                                                | ⌘N                          | `KeyboardBarButtonItem` with `SystemItem.add` in `KeyboardNavigationController`                                                                                                                                                                 |                                                                                                                                                                                                    |
| Compose                                            | ⌘N                          | `KeyboardBarButtonItem` with `SystemItem.compose` in `KeyboardNavigationController`                                                                                                                                                             |                                                                                                                                                                                                    |
| New window                                         | ⌥⌘N                         | `KeyboardApplication`                                                                                                                                                                                                                           | Keys chosen to leave ⌘N for compose or making new documents. This matches New Viewer Window in Mail on Mac.                                                                                        |
| Open Settings                                      | ⌘,                          | `KeyboardApplication`                                                                                                                                                                                                                           | Opens the Settings app using `UIApplicationOpenSettingsURLString`. This is disabled by default because there is no automatic way to know if the app will show any settings.                        |
| Save                                               | ⌘S                          | `KeyboardBarButtonItem` with `SystemItem.save` in `KeyboardNavigationController`                                                                                                                                                                |                                                                                                                                                                                                    |
| Share                                              | ⌘I                          | `KeyboardBarButtonItem` with `SystemItem.action` in `KeyboardNavigationController`                                                                                                                                                              |                                                                                                                                                                                                    |
| Bookmarks                                          | ⌘B                          | `KeyboardBarButtonItem` with `SystemItem.bookmarks` in `KeyboardNavigationController`                                                                                                                                                           |                                                                                                                                                                                                    |
| Search                                             | ⌘F                          | `KeyboardBarButtonItem` with `SystemItem.search` in `KeyboardNavigationController`                                                                                                                                                              |                                                                                                                                                                                                    |
| Rewind                                             | ⌘←                          | `KeyboardBarButtonItem` with `SystemItem.rewind` in `KeyboardNavigationController`                                                                                                                                                              |                                                                                                                                                                                                    |
| Fast forward                                       | ⌘→                          | `KeyboardBarButtonItem` with `SystemItem.fastForward` in `KeyboardNavigationController`                                                                                                                                                         |                                                                                                                                                                                                    |

**39 localisations**: KeyboardKit’s key command titles (for the discoverability panel on iPad or the menu bar on Mac) are localised into the main languages supported by iOS and macOS. The translations are based on localisation glossaries provided by Apple, and they were refined by referencing text used in similar contexts in Apple’s software. Full list of localisations: Arabic, Catalan, Chinese (Hong Kong), Chinese (Simplified), Chinese (Traditional), Croatian, Czech, Danish, Dutch, English (Australia), English (United Kingdom), English (United States), Finnish, French (Canada), French (France), German, Greek, Hebrew, Hindi, Hungarian, Indonesian, Italian, Japanese, Korean, Malay, Norwegian Bokmål, Polish, Portuguese (Brazil), Portuguese (Portugal), Romanian, Russian, Slovak, Spanish (Latin America), Spanish (Spain), Swedish, Thai, Turkish, Ukrainian, Vietnamese.

- No use of private API
- No swizzling
- App Store approved

## Status

The public API is currently kept minimal. Exposing more API without first understanding use-cases would increase the chances of having to make breaking API changes. If there is something you’d like to be able to customise in KeyboardKit, please [open an issue](https://github.com/douglashill/KeyboardKit/issues) to discuss.

## Requirements

KeyboardKit supports from iOS 11.0 onwards. The latest Xcode 11.x is required.

KeyboardKit is written in Swift with a very small amount of Objective-C.

Both Swift and Objective-C apps are supported. Since KeyboardKit uses Swift, it’s not possible subclass KeyboardKit classes from Objective-C. However all other features of KeyboardKit are available to Objective-C apps.

## Installation

### Recommended

1. Clone this repository.
2. Drag `KeyboardKit.xcodeproj` into your Xcode project.
3. Add the KeyboardKit target as a dependency of your target.
4. Add `KeyboardKit.framework` as an embedded framework.

### Swift Package Manager

Add KeyboardKit to an existing Xcode project as a package dependency:

1. From the File menu, select Swift Packages › Add Package Dependency…
2. Enter "https://github.com/douglashill/KeyboardKit" into the package repository URL text field.

This Swift package contains localised resources, so Swift 5.3 (Xcode 12) or later is required.

Swift Package Manager requires the Swift and Objective-C sources to be separated into modules. The `KeyboardKitObjC` module is used internally by KeyboardKit and does not need to be imported explicit by your app.

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

## Credits

KeyboardKit is a project from [Douglas Hill](https://douglashill.co/). Some concepts were originally developed for [PSPDFKit](https://pspdfkit.com/) and reimplemented in Swift for KeyboardKit. I use KeyboardKit in my [reading app](https://douglashill.co/reading-app/).

## Learn more

- Conference talk: [*Keyboard control in UIKit apps* at iOS Conf SG 2020](https://engineers.sg/video/full-keyboard-control-in-uikit-apps-ios-conf-sg-2020--3933) 
- Podcast discussion: [iPhreaks episode 297](https://devchat.tv/iphreaks/ips-297-keyboard-controls-with-douglas-hill/)

## Contributing

I’d love to have help on this project. For small changes please [open a pull request](https://github.com/douglashill/KeyboardKit/pulls), for larger changes please [open an issue](https://github.com/douglashill/KeyboardKit/issues) first to discuss what you’d like to see.

## Licence

MIT license — see License.txt
