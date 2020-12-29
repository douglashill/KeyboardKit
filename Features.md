# KeyboardKit features

KeyboardKit allows your users to use a hardware keyboard to perform the many actions listed below.

## Navigation and selection

KeyboardKit provides support for navigating in split views, collection views, table views, other scroll views, and more.  This is not based on the UIKit focus engine available on tvOS and Mac Catalyst — instead it uses the cell selection state of collection views and table views.

| Feature                                            | Key input                   | Available with                                                                                                                                             | Notes                                                                                                                                                                                              |
| -------------------------------------------------- | --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Select item above, below, left or right            | arrow                       | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                           | Selection wraps around. Does not support multiple selection.                                                                                                                                       |
| Select item at top, bottom, far left, or far right | ⌥ arrow                     | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                           | Modifier key chosen to be consistent with `NSTableView`.                                                                                                                                           |
| Select all                                         | ⌘A                          | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                           |                                                                                                                                                                                                    |
| Clear selection                                    | esc                         | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                           |                                                                                                                                                                                                    |
| Activate selection                                 | return, space               | `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`                                           | This will notify the delegate with `didSelectRowAtIndexPath:`.                                                                                                                                     |
| Delete selection                                   | delete                      | `KeyboardTableView`, `KeyboardTableViewController`                                                                                                         | Table view delegate must implement `tableView:commitEditingStyle:forRowAtIndexPath:`.                                                                                                              |
| Move focus between columns (e.g. sidebar)          | ←, →, tab, ⇧ tab            | `KeyboardSplitViewController`                                                                                                                              | Requires cooperation from a provided `KeyboardSplitViewControllerDelegate`. Requires a split view created with a style on iOS 14 or later.                                                         |
| Go back                                            | ⌘←, ⌘[                      | `KeyboardNavigationController`                                                                                                                             | Inputs are reversed for right-to-left layouts.                                                                                                                                                     |
| Select tab                                         | ⌘ number                    | `KeyboardTabBarController`                                                                                                                                 |                                                                                                                                                                                                    |
| Dismiss any sheet or popover                       | esc, ⌘W                     | `KeyboardWindow`                                                                                                                                           | This respects `isModalInPresentation`.                                                                                                                                                             |
| Hide overlaid column or show displaced column      | esc                         | `KeyboardSplitViewController`                                                                                                                              | Requires a split view created with a style on iOS 14 or later.                                                                                                                                     |
| Scroll by small step                               | arrow                       | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Only available in table and collection views when selection is disabled. Only available in text views when editing is disabled. This will scroll by page if `isPagingEnabled` is set.              |
| Scroll by page                                     | ⌥ arrow, page up, page down | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Using arrows keys is only available in table and collection views when selection is disabled and in text views when editing is disabled. Same as without the modifier if `isPagingEnabled` is set. |
| Scroll to top, bottom, far left, or far right      | ⌘ arrow, home, end          | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView` | Using arrows keys is only available in table and collection views when selection is disabled and in text views when editing is disabled.                                                           |
| Zoom in                                            | ⌘+                          | `KeyboardScrollView`                                                                                                                                       | Actual input is ⌘= but this shows as ⌘+ to match expectations.                                                                                                                                     |
| Zoom out                                           | ⌘−                          | `KeyboardScrollView`                                                                                                                                       |                                                                                                                                                                                                    |
| Zoom to actual size                                | ⌘0                          | `KeyboardScrollView`                                                                                                                                       |                                                                                                                                                                                                    |

## Key equivalents for buttons

The actions of bar button items can be activated from a keyboard simply by using `KeyboardNavigationController` and `KeyboardBarButtonItem` instead of `UINavigationController` and `UIBarButtonItem`. Most system items have key inputs set by default. Custom inputs can be set using the `keyEquivalent` property of `KeyboardBarButtonItem`.

| Feature      | Key input | Available with                                                                                                                                                                                                                                  | Notes                                                                                  |
| ------------ | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Delete       | ⌘ delete  | `KeyboardBarButtonItem` with `SystemItem.trash` in `KeyboardNavigationController`                                                                                                                                                               |                                                                                        |
| Refresh      | ⌘R        | `KeyboardScrollView`, `KeyboardTableView`, `KeyboardTableViewController`, `KeyboardCollectionView`, `KeyboardCollectionViewController`, `KeyboardTextView`, `KeyboardBarButtonItem` with `SystemItem.refresh` in `KeyboardNavigationController` | Available either with a scroll view with a `refreshControl` or with a bar button item. |
| Reply        | ⌘R        | `KeyboardBarButtonItem` with `SystemItem.reply` in `KeyboardNavigationController`                                                                                                                                                               |                                                                                        |
| Edit         | ⌘E        | `KeyboardBarButtonItem` with `SystemItem.edit` in `KeyboardNavigationController`                                                                                                                                                                |                                                                                        |
| Cancel       | esc       | `KeyboardBarButtonItem` with `SystemItem.cancel` in `KeyboardNavigationController`                                                                                                                                                              |                                                                                        |
| Done         | ⌘ return  | `KeyboardBarButtonItem` with `SystemItem.done` in `KeyboardNavigationController`                                                                                                                                                                |                                                                                        |
| Close        | ⌘W        | `KeyboardBarButtonItem` with `SystemItem.close` in `KeyboardNavigationController`                                                                                                                                                               |                                                                                        |
| Add          | ⌘N        | `KeyboardBarButtonItem` with `SystemItem.add` in `KeyboardNavigationController`                                                                                                                                                                 |                                                                                        |
| Compose      | ⌘N        | `KeyboardBarButtonItem` with `SystemItem.compose` in `KeyboardNavigationController`                                                                                                                                                             |                                                                                        |
| Save         | ⌘S        | `KeyboardBarButtonItem` with `SystemItem.save` in `KeyboardNavigationController`                                                                                                                                                                |                                                                                        |
| Share        | ⌘I        | `KeyboardBarButtonItem` with `SystemItem.action` in `KeyboardNavigationController`                                                                                                                                                              |                                                                                        |
| Bookmarks    | ⌘B        | `KeyboardBarButtonItem` with `SystemItem.bookmarks` in `KeyboardNavigationController`                                                                                                                                                           |                                                                                        |
| Search       | ⌘F        | `KeyboardBarButtonItem` with `SystemItem.search` in `KeyboardNavigationController`                                                                                                                                                              |                                                                                        |
| Rewind       | ⌘←        | `KeyboardBarButtonItem` with `SystemItem.rewind` in `KeyboardNavigationController`                                                                                                                                                              |                                                                                        |
| Fast forward | ⌘→        | `KeyboardBarButtonItem` with `SystemItem.fastForward` in `KeyboardNavigationController`                                                                                                                                                         |                                                                                        |

## Advanced text navigation

`KeyboardTextView` provides keyboard access to quick navigation based on searching for text. These are all standard features of `NSTextView` in AppKit, and some Mac users find these commands are a huge productivity boost.

| Feature                | Key input |
| ---------------------- | --------- |
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

- No use of private API
- No swizzling or use of associated objects
- App Store approved
