# ExtractLocalisedStrings

All KeyboardKit’s user-facing text (for the discoverability panel shown when holding the command key) is used in a similar context to text used in Apple’s software. Therefore localisation is achieved by leveraging Apple’s existing translations.

This script extracts localised strings from the glossary files that Apple provides.

## Updating

1. Download all macOS and iOS glossary DMGs from the [Apple Developer website](https://developer.apple.com/download/more) (sign in required). 
2. Mount all of these DMGs on your Mac. There should be about 80. DiskImageMounter may get stuck if you try mounting ~20 or more at once, so opening in batches of ~15 is recommended.
3. Run this target, ExtractLocalisedStrings. Look out for any errors in the console. That may indicate some DMGs failed to mount, or Apple removed a localisation key or added one so the lookup is ambiguous.
4. Manually edit the American English `.strings` file in `en.lproj`. It’s generated from Australian English because Apple does not provide `en` glossaries. Organise must be changed back to Organize. 
5. Manually check the diff of all `.strings`  files.

## Adding new localised strings

1. Locate the same text used in Apple software and identify the glossary where this can be found and the key used.
2. Add this as a `NeededLocalisation` in the `neededLocalisations` array in the script `main.swift`. This order of this array is matches the final order in the `.strings` files. It should be sorted alphabetically by key.
3. Follow the steps for updating above.

## Adding localisations

Apple must provide glossaries for the new localisation.

1. Add the localisation from the Xcode project Info tab.
2. Add the `Language` to the `languages` array in the script `main.swift`. The `volumeName` should be contained in only the volume names of both glossary DMGs.
3. Add the localisation to the list below for documentation.

## Full list of localisations 

- Arabic
- Catalan
- Chinese, Simplified
- Chinese, Traditional
- Chinese (Hong Kong)
- Croatian
- Czech
- Danish
- Dutch
- English
- English (Australia)
- English (United Kingdom)
- Finnish
- French
- French (Canada)
- German
- Greek
- Hebrew
- Hindi
- Hungarian
- Indonesian
- Italian
- Japanese
- Korean
- Malay
- Norwegian Bokmål
- Polish
- Portuguese (Brazil)
- Portuguese (Portugal)
- Romanian
- Russian
- Slovak
- Spanish
- Spanish (Latin America)
- Swedish
- Thai
- Turkish
- Ukrainian
- Vietnamese

ExtractLocalisedStrings is part of [KeyboardKit](https://github.com/douglashill/KeyboardKit).
