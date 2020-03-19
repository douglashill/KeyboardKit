// Douglas Hill, March 2020

// Extracts localised strings from Apple’s glossary files. See the adjacent README.md.

import Foundation

extension Collection {
    /// The only element in the collection, or nil if there are multiple or zero elements.
    var single: Element? { count == 1 ? first! : nil }
}

extension XMLElement {
    func singleChild(withName name: String) -> XMLElement? {
        elements(forName: name).single
    }
}

extension XMLNode {
    var textOfSingleChild: String? {
        guard let singleChild = children?.single, singleChild.kind == .text else {
            return nil
        }
        return singleChild.stringValue
    }
}

struct LocalisationEntry {
    /// The file where the entry was read from.
    let fileURL: URL
    /// The usage description to help with translation.
    let comment: String?
    /// The key to look up this string. This is optional because some Apple strings files use just whitespace as a key and NSXMLDocument can not read whitespace-only text elements.
    let key: String?
    /// The English text.
    let base: String
    /// The localised text.
    let translation: String
}

func readLocalisationEntriesFromFile(at fileURL: URL) -> [LocalisationEntry] {
    defer {
//        print("ℹ️ Read file at \(fileURL)")
    }

    let doc = try! XMLDocument(contentsOf: fileURL, options: [.nodePreserveWhitespace])

    return doc.rootElement()!.elements(forName: "File").flatMap { file -> [LocalisationEntry] in
        file.elements(forName: "TextItem").compactMap { textItem -> LocalisationEntry? in
            let translationSet = textItem.singleChild(withName: "TranslationSet")!

            guard let base = translationSet.singleChild(withName: "base")!.textOfSingleChild, let translation = translationSet.singleChild(withName: "tran")!.textOfSingleChild else {
                //                print("⚠️ Could not parse entry \(textItem)")
                return nil
            }

            return LocalisationEntry(
                fileURL: fileURL,
                comment: textItem.singleChild(withName: "Description")!.textOfSingleChild,
                key: textItem.singleChild(withName: "Position")!.textOfSingleChild,
                base: base,
                translation: translation
            )
        }
    }
}

// TODO: These are ambiguous because there are usually entries from many strings files in each glossary file, so there can be duplicate keys in the glossary.
// Would be better to track the file path inside each glossary too.

struct NeededLocalisation {
    let targetKey: String
    let appleKey: String
    let glossaryFilename: String
}

let neededLocalisations = [
    NeededLocalisation(targetKey: "app_newWindow",          appleKey: "fluid.switcher.plus.button.label", glossaryFilename: "AccessibilityBundles"),
    NeededLocalisation(targetKey: "app_settings",           appleKey: "Settings",                         glossaryFilename: "MobileNotes"         ),
    NeededLocalisation(targetKey: "barButton_action",       appleKey: "Action",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_add",          appleKey: "Add",                              glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_bookmarks",    appleKey: "Bookmarks",                        glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_camera",       appleKey: "Camera",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_cancel",       appleKey: "Cancel",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_close",        appleKey: "Close",                            glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_compose",      appleKey: "Compose",                          glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_done",         appleKey: "Done",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_edit",         appleKey: "Edit",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_fastForward",  appleKey: "Fast Forward",                     glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_organize",     appleKey: "Organize",                         glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_pause",        appleKey: "Pause",                            glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_play",         appleKey: "Play",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_redo",         appleKey: "Redo",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_refresh",      appleKey: "Refresh",                          glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_reply",        appleKey: "Reply",                            glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_rewind",       appleKey: "Rewind",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_save",         appleKey: "Save",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_search",       appleKey: "Search",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_stop",         appleKey: "Stop",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_trash",        appleKey: "Trash",                            glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_undo",         appleKey: "Undo",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "delete",                 appleKey: "Delete",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "find_jump",              appleKey: "315.title",                        glossaryFilename: "TextEdit"            ),
    NeededLocalisation(targetKey: "find_next",              appleKey: "312.title",                        glossaryFilename: "TextEdit"            ),
    NeededLocalisation(targetKey: "find_previous",          appleKey: "314.title",                        glossaryFilename: "TextEdit"            ),
    NeededLocalisation(targetKey: "find_useSelection",      appleKey: "316.title",                        glossaryFilename: "TextEdit"            ),
    NeededLocalisation(targetKey: "navigation_back",        appleKey: "Back",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "scrollView_refresh",     appleKey: "Refresh",                          glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "scrollView_zoomIn",      appleKey: "438.title",                        glossaryFilename: "WebBrowser"          ),
    NeededLocalisation(targetKey: "scrollView_zoomOut",     appleKey: "439.title",                        glossaryFilename: "WebBrowser"          ),
    NeededLocalisation(targetKey: "scrollView_zoomReset",   appleKey: "863.title",                        glossaryFilename: "WebBrowser"          ),
    NeededLocalisation(targetKey: "window_close",           appleKey: "Close Window",                     glossaryFilename: "AppKit"              ),
    NeededLocalisation(targetKey: "window_cycle",           appleKey: "Cycle Through Windows",            glossaryFilename: "AppKit"              ),
]

struct Language {
    let code: String
    let volumeName: String
}

let languages = [
    Language(code: "ar", volumeName: "Arabic"),
    Language(code: "ca", volumeName: "Catalan"),
    Language(code: "cs", volumeName: "Czech"),
    Language(code: "da", volumeName: "Danish"),
    Language(code: "de", volumeName: "German"),
    Language(code: "el", volumeName: "Greek"),
    Language(code: "en", volumeName: "British English"), // Apple does not provide a glossary for en so it may need updating manually after generation.
    Language(code: "en-AU", volumeName: "Australian English"),
    Language(code: "en-GB", volumeName: "British English"),
    Language(code: "es", volumeName: "Spanish"),
    Language(code: "es-419", volumeName: "Latin"),
    Language(code: "fi", volumeName: "Finnish"),
    Language(code: "fr", volumeName: "Universal French"),
    Language(code: "fr-CA", volumeName: "Canadian"),
    Language(code: "he", volumeName: "Hebrew"),
    Language(code: "hi", volumeName: "Hindi"),
    Language(code: "hr", volumeName: "Croatian"),
    Language(code: "hu", volumeName: "Hungarian"),
    Language(code: "id", volumeName: "Indonesian"),
    Language(code: "it", volumeName: "Italian"),
    Language(code: "ja", volumeName: "Japanese"),
    Language(code: "ko", volumeName: "Korean"),
    Language(code: "ms", volumeName: "Malay"),
    Language(code: "nb", volumeName: "Norwegian"),
    Language(code: "nl", volumeName: "Dutch"),
    Language(code: "pl", volumeName: "Polish"),
    Language(code: "pt-BR", volumeName: "Brazilian"),
    Language(code: "pt-PT", volumeName: "Portuguese"),
    Language(code: "ro", volumeName: "Romanian"),
    Language(code: "ru", volumeName: "Russian"),
    Language(code: "sk", volumeName: "Slovak"),
    Language(code: "sv", volumeName: "Swedish"),
    Language(code: "th", volumeName: "Thai"),
    Language(code: "tr", volumeName: "Turkish"),
    Language(code: "uk", volumeName: "Ukrainian"),
    Language(code: "vi", volumeName: "Vietnamese"),
    Language(code: "zh-Hans", volumeName: "Simplified Chinese"),
    Language(code: "zh-Hant", volumeName: "Traditional Chinese"),
    Language(code: "zh-HK", volumeName: "Hong Kong"),
]

let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [])!

for lang in languages {
    let matchingVolumes = volumes.filter { fileURL -> Bool in
        fileURL.lastPathComponent.contains(lang.volumeName)
    }

    print("ℹ️ Localising \(lang.volumeName) (\(lang.code)) from \(matchingVolumes.count) volumes.") // There should be 2 volumes.

    let lines = neededLocalisations.compactMap { neededLocalisation -> String? in
        let localisationEntries = matchingVolumes.flatMap { volumeURL -> [LocalisationEntry] in
            let glossaryFilePaths = try! FileManager.default.contentsOfDirectory(at: volumeURL, includingPropertiesForKeys: nil, options: []).filter { fileURL in
                fileURL.lastPathComponent.contains(neededLocalisation.glossaryFilename)
            }

            return glossaryFilePaths.flatMap { fileURL -> [LocalisationEntry] in
                readLocalisationEntriesFromFile(at: fileURL).filter { entry in
                    entry.key == neededLocalisation.appleKey
                }
            }
        }

        let translations: Set<String> = Set<String>(localisationEntries.map { $0.translation })

        guard let translation = translations.single else {
            print("❌ Wrong number of matches for \(neededLocalisation.appleKey) in files matching \(neededLocalisation.glossaryFilename): \(translations)")
            return nil
        }

        return """
        "\(neededLocalisation.targetKey)" = "\(translation)";
        """
    }

    // TODO: Get this path from the environment.
    let targetStringsFileURL = URL(fileURLWithPath: "/Users/Douglas/Development/KeyboardKit/KeyboardKit/Localised/\(lang.code).lproj/Localizable.strings")

    try! FileManager.default.createDirectory(at: targetStringsFileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

    try! """
        // This file was generated from Apple localisation glossaries by ExtractLocalisedStrings.

        \(lines.joined(separator: "\n"))

        """.write(to: targetStringsFileURL, atomically: false, encoding: .utf8)
}
