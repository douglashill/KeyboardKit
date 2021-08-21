# KeyboardKit features

KeyboardKit allows your users to use a hardware keyboard to perform the many actions listed below on iPad, iPhone or Mac.

## Keyboard navigation

KeyboardKit is designed to be used alongside the UIKit focus system when it’s available, which is on iPad on iOS 15 and later, and on Mac on Big Sur and later.

For iOS 15 on iPhone, iOS 12–14 on iPad, and macOS Catalina, KeyboardKit helps replicate much of what the focus system offers with arrow key selection in table views and collection views and tab navigation across columns in split view controllers.

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

## More collection stuff

Items can be reordered.

| Feature                                                        | Key input | Available with                                                                                                   | Notes                                                                                                                                                                             |
| -------------------------------------------------------------- | --------- | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Select all                                                     | ⌘A        | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` |                                                                                                                                                                                   |
| Delete focused or selected rows                                | delete    | `KeyboardTableView`, `KeyboardTableViewController`                                                               | Table view delegate must implement `tableView:commitEditingStyle:forRowAtIndexPath:`. Acts on the focused rows when `UIFocusSystem` is available or on selected rows otherwise.   |
| Move focused or selected row up, down, left or right (reorder) | ⌥⌘ arrow  | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` | Data source must implement move callbacks. Not supported with a diffable data source. Acts on the focused row when `UIFocusSystem` is available or on the selected row otherwise. |

## More navigation stuff

KeyboardKit provides support for navigating in navigation controllers and more.

| Feature                                       | Key input | Available with                 | Notes                                                                                              |
| --------------------------------------------- | --------- | ------------------------------ | -------------------------------------------------------------------------------------------------- |
| Go back                                       | ⌘←, ⌘[    | `KeyboardNavigationController` | Inputs are reversed for right-to-left layouts.                                                     |
| Select tab                                    | ⌘ number  | `KeyboardTabBarController`     | The delegate will receive `shouldSelect` and `didSelect` callbacks. The More tab is not supported. |
| Dismiss any sheet or popover                  | esc, ⌘W   | `KeyboardWindow`               | This respects `isModalInPresentation`.                                                             |
| Hide overlaid column or show displaced column | esc       | `KeyboardSplitViewController`  | Requires a split view created with a style on iOS 14 or later.                                     |

## Scrolling and zooming

Scrolling and zooming commands provide feature parity with `NSScrollView` from AppKit, including [Page Up, Page Down, Home and End](https://daringfireball.net/linked/2019/12/20/hill-keyboardkit). The scrolling animation has been finely tuned to feel responsive.

| Feature                                       | Key input                   | Available with                                                                                                                                             | Notes                                                                                                                                                                                              |
| --------------------------------------------- | --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Scroll by small step                          | arrow                       | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Only available in table and collection views when selection is disabled. Only available in text views when editing is disabled. This will scroll by page if `isPagingEnabled` is set.              |
| Scroll by page                                | ⌥ arrow, page up, page down | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Using arrows keys is only available in table and collection views when selection is disabled and in text views when editing is disabled. Same as without the modifier if `isPagingEnabled` is set. |
| Scroll to top, bottom, far left, or far right | ⌘ arrow, home, end          | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Using arrows keys is only available in table and collection views when selection is disabled and in text views when editing is disabled.                                                           |
| Zoom in                                       | ⌘+                          | `KeyboardScrollView`                                                                                                                                       | Actual input is ⌘= but this shows as ⌘+ to match expectations.                                                                                                                                     |
| Zoom out                                      | ⌘−                          | `KeyboardScrollView`                                                                                                                                       |                                                                                                                                                                                                    |
| Zoom to actual size                           | ⌘0                          | `KeyboardScrollView`                                                                                                                                       |                                                                                                                                                                                                    |

## Key equivalents for buttons

The actions of bar button items can be activated from a keyboard by using `KeyboardNavigationController` and `KeyboardBarButtonItem` instead of `UINavigationController` and `UIBarButtonItem`. Most system items have key inputs set by default. Custom inputs can be set using the `keyEquivalent` property of `KeyboardBarButtonItem`.

The refresh command (⌘R) is also available by setting up pull to refresh in the usual way with the `refreshControl` of a `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController` or `KeyboardTextView`.

| Feature      | Key input | `UIBarButtonItem.SystemItem` |
| ------------ | --------- | ---------------------------- |
| Delete       | ⌘ delete  | `.trash`                     |
| Refresh      | ⌘R        | `.refresh`                   |
| Reply        | ⌘R        | `.reply`                     |
| Edit         | ⌘E        | `.edit`                      |
| Cancel       | esc       | `.cancel`                    |
| Done         | ⌘ return  | `.done`                      |
| Close        | ⌘W        | `.close`                     |
| Add          | ⌘N        | `.add`                       |
| Compose      | ⌘N        | `.compose`                   |
| Save         | ⌘S        | `.save`                      |
| Share        | ⌘I        | `.action`                    |
| Bookmarks    | ⌘B        | `.bookmarks`                 |
| Search       | ⌘F        | `.search`                    |
| Rewind       | ⌘←        | `.rewind`                    |
| Fast forward | ⌘→        | `.fastForward`               |

## Advanced text navigation

`KeyboardTextView` provides keyboard access to quick navigation based on searching for text. These are all standard features of `NSTextView` from AppKit, and some Mac users find these commands are a huge productivity boost.

Showing a definition of the selected word is also possible. There is no public API to access the functionality of the Look Up menu item, so this command uses the more limited `UIReferenceLibraryViewController`.

| Feature                | Key input |
| ---------------------- | --------- |
| Define                 | ⌃⌘D       |
| Find next              | ⌘G        |
| Find previous          | ⇧⌘G       |
| Jump to selection      | ⌘J        |
| Use selection for find | ⌘E        |

## Window management

Key commands for working with windows are provided for iPad. These are not needed with Mac Catalyst because the system provides this functionality by default on Mac.

| Feature              | Key input | Available with        | Notes                                                                                                                                                                       |
| -------------------- | --------- | --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| New window           | ⌥⌘N       | `KeyboardApplication` | Keys chosen to leave ⌘N for compose or making new documents. This matches New Viewer Window in Mail on Mac.                                                                 |
| Close window         | ⇧⌘W       | `KeyboardWindowScene` | Keys chosen to leave ⌘W for closing a tab or modal within a window. This matches the Mac when a window has tabs.                                                            |
| Cycle focused window | ⌘\`       | `KeyboardWindowScene` | Changes the key window. Only works with visible windows. There does not seem to be any API to activate a non-visible window scene without breaking the user’s spaces.       |
| Open Settings        | ⌘,        | `KeyboardApplication` | Opens the Settings app using `UIApplicationOpenSettingsURLString`. This is disabled by default because there is no automatic way to know if the app will show any settings. |

## Date picker

`KeyboardDatePicker` lets users use arrow keys to spatially change the selected day. It supports the `.inline` style with the mode set to either `.date` or  `.dateAndTime`. This class requires iOS 14 or later.

| Feature      | Key input | Notes                                          |
| ------------ | --------- | ---------------------------------------------- |
| Change day   | ←, →      | Inputs are reversed for right-to-left layouts. |
| Change week  | ↑, ↓      |                                                |
| Change month | ⌥←, ⌥→    | Inputs are reversed for right-to-left layouts. |
| Change year  | ⌥↑, ⌥↓    |                                                |
| Go to today  | ⌘T        |                                                |

## Localisation

**39 localisations**: KeyboardKit’s key command titles (for the discoverability panel on iPad or the menu bar on Mac) are localised into the main languages supported by iOS and macOS. The translations are [based on localisation glossaries provided by Apple](https://douglashill.co/localisation-using-apples-glossaries/), and they were refined by referencing text used in similar contexts in Apple’s software.

Where appropriate, key command inputs are flipped for right-to-left layouts.

Full list of localisations: Arabic, Catalan, Chinese (Hong Kong), Chinese (Simplified), Chinese (Traditional), Croatian, Czech, Danish, Dutch, English (Australia), English (United Kingdom), English (United States), Finnish, French (Canada), French (France), German, Greek, Hebrew, Hindi, Hungarian, Indonesian, Italian, Japanese, Korean, Malay, Norwegian Bokmål, Polish, Portuguese (Brazil), Portuguese (Portugal), Romanian, Russian, Slovak, Spanish (Latin America), Spanish (Spain), Swedish, Thai, Turkish, Ukrainian, Vietnamese.

## Clean implementation

- App Store approved
- No data collection
- No use of private API, swizzling or associated objects
