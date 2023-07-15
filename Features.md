# KeyboardKit features

KeyboardKit allows your users to use a hardware keyboard to perform the many actions listed below on iPad, iPhone or Mac.

## Keyboard navigation without the focus system

KeyboardKit is designed to be used alongside the UIKit focus system when it’s available, which is on iPad on iOS 15 and later, and on Mac on macOS 11 Big Sur and later.

For iPhone and iOS 13–14 on iPad, KeyboardKit helps replicate much of what the focus system offers with arrow key selection in table views and collection views and tab navigation across columns in split view controllers. KeyboardKit’s implementation of keyboard navigation has a few advantages over the focus system:

- Jumping to the end is possible in collection views and table views by holding the option key. This is a powerful productivity accelerator.
- Wrapping is possible in collection views and table views. The user can press up when at the top to jump to the bottom etc.
- Split views can be navigated regardless of their display mode. If the user tries to move focus to a column that isn’t visible, that column will be shown automatically.
- Arrow keys can be used to navigate across split view columns if these inputs aren’t consumed by the column content view. Using arrow keys feels more fluid.

However the UIKit focus system has the major advantages of better system integration, removing the need for first responder management, and providing clear visual indication which element is focused. That’s why the focus system is used if its available.  

To know whether the focus system is available, check for a `UIFocusSystem` like this:

```swift
if UIFocusSystem(for: viewOrViewController) != nil {
    // The UIKit focus system is available, which provides tab key navigation between
    // focus groups and arrow key navigation between items within each focus group.
} else {
    // KeyboardKit will provide tab key navigation between columns in split views
    // and arrow key navigation in table and collection views.
}
```

The following keyboard features are available only when the `UIFocusSystem` is not available.

| Feature                                            | Key input        | Available with                                                                                                   | Notes                                                                                                                                                                                                                                                                                             |
| -------------------------------------------------- | ---------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Select item above, below, left or right            | arrow            | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` | Unlike with the UIKit focus system, selection wraps around. Does not support multiple selection.                                                                                                                                                                                                  |
| Select item at top, bottom, far left, or far right | ⌥ arrow          | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` | Modifier key chosen to be consistent with `NSTableView` from AppKit. These accelerators aren’t possible with the UIKit focus system.                                                                                                                                                              |
| Clear selection                                    | esc              | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` |                                                                                                                                                                                                                                                                                                   |
| Activate selection                                 | return, space    | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` | This will notify the delegate with `didSelectRowAtIndexPath:`. While the UIKit focus system requires users to use return on iPad and space on Mac, KeyboardKit alllows either on either.                                                                                                          |
| Move focus between columns (e.g. sidebar)          | ←, →, tab, ⇧ tab | `KeyboardSplitViewController`                                                                                    | Requires cooperation from a provided `KeyboardSplitViewControllerDelegate`. Requires a split view created with a style on iOS 14 or later. Unlike the UIKit focus system, these inputs work regardless of whether columns are currently visible or not and arrow keys may be used instead of tab. |

## Additional navigation commands

KeyboardKit provides support for navigating in navigation controllers and more.

| Feature                                       | Key input | Available with                 | Notes                                                                                              |
| --------------------------------------------- | --------- | ------------------------------ | -------------------------------------------------------------------------------------------------- |
| Dismiss any sheet or popover                  | esc, ⌘W   | `KeyboardWindow`               | This respects `isModalInPresentation`.                                                             |
| Select tab                                    | ⌘ number  | `KeyboardTabBarController`     | The delegate will receive `shouldSelect` and `didSelect` callbacks. The More tab is not supported. |
| Go back                                       | ⌘`[`, ⌘←  | `KeyboardNavigationController` | Mirrored for right-to-left. UIKit has this on iOS 15, but KeyboardKit does this back to iOS 13.    |
| Hide overlaid column or show displaced column | esc       | `KeyboardSplitViewController`  | Requires a split view created with a style on iOS 14 or later.                                     |

## Collection view and table view commands

Items can be reordered with the keyboard in collection views and table views. Deletion is supported only in table views.

| Feature                                                      | Key input | Available with                                                                                                   | Notes                                                                                                                                                                              |
| ------------------------------------------------------------ | --------- | ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Move focused/selected item up, down, left or right (reorder) | ⌥⌘ arrow  | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` | Data source must implement move callbacks. Not supported with a diffable data source. Acts on the focused item when `UIFocusSystem` is available or on the selected row otherwise. |
| Delete focused or selected rows                              | delete    | `KeyboardTableView`, `KeyboardTableViewController`                                                               | Table view delegate must implement `tableView:commitEditingStyle:forRowAtIndexPath:`. Acts on the focused rows when `UIFocusSystem` is available or on selected rows otherwise.    |
| Select all                                                   | ⌘A        | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` |                                                                                                                                                                                    |

## Scrolling and zooming

Scrolling and zooming commands provide feature parity with `NSScrollView` from AppKit, including [Page Up, Page Down, Home and End](https://daringfireball.net/linked/2019/12/20/hill-keyboardkit). The scrolling animation has been finely tuned to feel responsive.

From iOS 17, `UIScrollView` has partial built-in support for keyboard scrolling. This is disabled in KeyboardKit classes because KeyboardKit’s support is more comprehensive. Unlike the built-in scrolling, KeyboardKit’s scrolling is not continuous where a user can hold down a key to keep scrolling.

| Feature                                       | Key input                   | Available with                                                                                                                                             | Notes                                                                                                                                                                                              |
| --------------------------------------------- | --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Scroll by small step                          | arrow                       | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Only available in table and collection views when selection is disabled. Only available in text views when editing is disabled. This will scroll by page if `isPagingEnabled` is set.              |
| Scroll by page                                | ⌥ arrow, page up, page down | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Using arrows keys is only available in table and collection views when selection is disabled and in text views when editing is disabled. Same as without the modifier if `isPagingEnabled` is set. |
| Scroll to top, bottom, far left, or far right | ⌘ arrow, home, end          | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Using arrows keys is only available in table and collection views when selection is disabled and in text views when editing is disabled.                                                           |
| Zoom in                                       | ⌘+                          | `KeyboardScrollView`                                                                                                                                       | Actual input is ⌘= but this shows as ⌘+ to match expectations.                                                                                                                                     |
| Zoom out                                      | ⌘−                          | `KeyboardScrollView`                                                                                                                                       |                                                                                                                                                                                                    |
| Zoom to actual size                           | ⌘0                          | `KeyboardScrollView`                                                                                                                                       |                                                                                                                                                                                                    |

### Map view

`MKMapView` has had built-in support for scrolling, zooming and rotating the map using a keyboard since iOS 15. However this functionality is unavailable unless you subclass `MKMapView` and override `canBecomeFirstResponder` and `canBecomeFocused` to return true. `KeyboardMapView` unlocks this functionality and adds two other useful commands.

| Feature                       | Key input    | Notes                                             |
| ----------------------------- | ------------ | ------------------------------------------------- |
| Scroll map                    | arrow        | Unlocked from `MKMapView`.                        |
| Zoom map                      | +, -, ⌥↑, ⌥↓ | Unlocked from `MKMapView`.                        |
| Rotate map (change heading)   | ⌥←, ⌥→       | Unlocked from `MKMapView`.                        |
| Snap to north (reset heading) | ⇧⌘↑          | Available if `isRotateEnabled` is true.           |
| Go to current location        | ⌘L           | Available if `showsUserLocation` is true.         |

## Key equivalents for buttons (SwiftUI and UIKit)

SwiftUI provides the `.keyboardShortcut` modifier to trigger the action of a `Button` from a keyboard. KeyboardKit extends this by providing semantically defined `KeyboardShortcut`s for common actions, which can be used with this modifier.

In UIKit, the actions of bar button items can be activated from a keyboard by using `KeyboardNavigationController` and `KeyboardBarButtonItem` instead of `UINavigationController` and `UIBarButtonItem`. Most system items have key inputs set by default. Custom inputs can be set using the `keyEquivalent` property of `KeyboardBarButtonItem`.

The refresh command (⌘R) is also available by setting up pull to refresh in the usual way with the `refreshControl` of a `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` or `KeyboardTextView`.

| Feature         | Key input | `KeyboardShortcut`              | `UIBarButtonItem.SystemItem` |
| --------------- | --------- | ------------------------------- | ---------------------------- |
| Delete          | ⌘ delete  | `.KeyboardKit.delete`           | `.trash`                     |
| Refresh         | ⌘R        | `.KeyboardKit.refresh`          | `.refresh`                   |
| Reply           | ⌘R        | `.KeyboardKit.reply`            | `.reply`                     |
| Edit            | ⌘E        | `.KeyboardKit.edit`             | `.edit`                      |
| Cancel          | esc       | `.cancelAction` (SwiftUI)       | `.cancel`                    |
| Done            | ⌘ return  | `.KeyboardKit.done`             | `.done`                      |
| Close           | ⌘W        | `.KeyboardKit.close`            | `.close`                     |
| Add/Compose/New | ⌘N        | `.KeyboardKit.new`              | `.add`, `.compose`           |
| Save            | ⌘S        | `.KeyboardKit.save`             | `.save`                      |
| Share           | ⌘I        | `.KeyboardKit.share`            | `.action`                    |
| Bookmarks       | ⌘B        | `.KeyboardKit.bookmarks`        | `.bookmarks`                 |
| Search          | ⌘F        | `.KeyboardKit.search`           | `.search`                    |
| Rewind          | ⌘←        | `.KeyboardKit.rewind`           | `.rewind`                    |
| Fast forward    | ⌘→        | `.KeyboardKit.fastForward`      | `.fastForward`               |
| Today           | ⌘T        | `.KeyboardKit.today`            | -                            |
| Zoom In         | ⌘=        | `.KeyboardKit.zoomIn`           | -                            |
| Zoom Out        | ⌘-        | `.KeyboardKit.zoomOut`          | -                            |
| Actual Size     | ⌘0        | `.KeyboardKit.zoomToActualSize` | -                            |

## Advanced text navigation

`KeyboardTextView` provides keyboard access to quick navigation based on searching for text. These are all standard features of `NSTextView` from AppKit, and some Mac users find these commands are a huge productivity boost. On iOS 16 and later, `UITextView` provides a built-in UIFindInteraction that provides this functionality together with UI for entering a search term, so it’s recommended to use that instead. KeyboardKit’s find commands will be disabled if the text view’s `isFindInteractionEnabled` property is true.

Showing a definition of the selected word is also possible. There is no public API to access the functionality of the Look Up menu item, so this command uses the more limited `UIReferenceLibraryViewController`.

| Feature                | Key input | Notes                                          |
| ---------------------- | --------- | ---------------------------------------------- |
| Define                 | ⌃⌘D       |                                                |
| Find next              | ⌘G        | Only when `isFindInteractionEnabled` is false. |
| Find previous          | ⇧⌘G       | Only when `isFindInteractionEnabled` is false. |
| Jump to selection      | ⌘J        |                                                |
| Use selection for find | ⌘E        | Only when `isFindInteractionEnabled` is false. |

## Window management

Key commands for working with windows are provided for iPad. These are not needed with Mac Catalyst because the system provides this functionality by default on Mac.

| Feature              | Key input | Available with        | Notes                                                                                                                                                                       |
| -------------------- | --------- | --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| New window           | ⌥⌘N       | `KeyboardApplication` | Keys chosen to leave ⌘N for compose or making new documents. This matches New Viewer Window in Mail on Mac.                                                                 |
| Close window         | ⇧⌘W       | `KeyboardWindowScene` | Keys chosen to leave ⌘W for closing a tab or modal within a window. This matches the Mac when a window has tabs.                                                            |
| Cycle focused window | ⌘\`       | `KeyboardWindowScene` | Changes the key window. The system provides this on iOS 15 and later.                                                                                                       |
| Open Settings        | ⌘,        | `KeyboardApplication` | Opens the Settings app using `UIApplicationOpenSettingsURLString`. This is disabled by default because there is no automatic way to know if the app will show any settings. |

## Date picker

`KeyboardDatePicker` lets users use arrow keys to spatially change the selected day. It supports the `.inline` style with the mode set to either `.date` or  `.dateAndTime`. This class requires iOS 14 or later.

| Feature      | Key input | Notes                                          |
| ------------ | --------- | ---------------------------------------------- |
| Change day   | ←, →      | Inputs are mirrored for right-to-left layouts. |
| Change week  | ↑, ↓      |                                                |
| Change month | ⌥←, ⌥→    | Inputs are mirrored for right-to-left layouts. |
| Change year  | ⌥↑, ⌥↓    |                                                |
| Go to today  | ⌘T        |                                                |

## Main menu and discoverability HUD

Key commands from KeyboardKit can be shown grouped under File, Edit, View etc. in the keyboard discoverability HUD on iPad or in the menu bar on Mac. Since the main menu is global state shared across the whole app, KeyboardKit takes a mostly hands off approach and lets your app set up the menu how you like. By default, all key commands will be provided by KeyboardKit through overrides of the `keyCommands` property of `UIResponder`. This means these commands will be shown in the discoverability HUD on iPad in the application section and will not be shown at all in the menu bar on Mac.

Commands from KeyboardKit with titles shown to the user (discoverable commands) are available as static properties on various KeyboardKit classes so that these commands can be added to the main menu using `UIMenuBuilder` For example, `KeyboardScrollView` has a static `zoomInKeyCommand` property. To add this command to the main menu, override `buildMenu(with:)` in your app or app delegate and add this key command using the usual `UIMenuBuilder` API.

Since key commands should be exposed to the system either using an override of `keyCommands` or with `UIMenuBuilder`, the commands from KeyboardKit have a `shouldBeIncludedInResponderChainKeyCommands` property that should be set to false on each command you add to the main menu.

For more details, see `DiscoverableKeyCommand`. For an example, see the implementation of `buildMenu(with:)` in `AppDelegate` in the KeyboardKit demo app.

## Localisation

**39 localisations**: KeyboardKit’s key command titles (for the discoverability panel on iPad or the menu bar on Mac) are localised into the main languages supported by iOS and macOS. The translations are [based on localisation glossaries provided by Apple](https://douglashill.co/localisation-using-apples-glossaries/), and they were refined by referencing text used in similar contexts in Apple’s software.

Where appropriate, key command inputs are flipped for right-to-left layouts.

Full list of localisations: Arabic, Catalan, Chinese (Hong Kong), Chinese (Simplified), Chinese (Traditional), Croatian, Czech, Danish, Dutch, English (Australia), English (United Kingdom), English (United States), Finnish, French (Canada), French (France), German, Greek, Hebrew, Hindi, Hungarian, Indonesian, Italian, Japanese, Korean, Malay, Norwegian Bokmål, Polish, Portuguese (Brazil), Portuguese (Portugal), Romanian, Russian, Slovak, Spanish (Latin America), Spanish (Spain), Swedish, Thai, Turkish, Ukrainian, Vietnamese.

## Clean implementation

- App Store approved
- No data collection
- No use of private API, swizzling or associated objects
