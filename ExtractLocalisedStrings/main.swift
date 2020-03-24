// Douglas Hill, March 2020

// Extracts localised strings from Apple’s glossary files. See the adjacent README.md.

import Foundation

// MARK: Input data

// Possible improvement:
// We identify using glossary > key, which could be ambiguous because there are entries from
// many .strings files in each glossary file, so there can be duplicate keys in the glossary.
// This is handled by finding all matches and printing an error if there are multiple matches.
// It would be better to identify each needed localisation by glossary > filename > key.

/// A localised strings entry that we want to extract from Apple’s glossary files.
struct NeededLocalisation {
    /// The key to use in the generated KeyboardKit .strings file.
    let targetKey: String
    /// The key (AKA Position) that Apple uses in their glossary.
    let appleKey: String
    /// The file base name of the glossary file in which this localisation can be found. I.e. the filename is glossaryFilename.lg.
    let glossaryFilename: String
}

let neededLocalisations = [
    NeededLocalisation(targetKey: "app_newWindow",          appleKey: "fluid.switcher.plus.button.label", glossaryFilename: "AccessibilityBundles"),
    NeededLocalisation(targetKey: "app_settings",           appleKey: "Settings",                         glossaryFilename: "MobileNotes"         ),
    // UIKit is inconsistent here. It uses "Share" for the accessibility label, but "Action" for the large content viewer.
    NeededLocalisation(targetKey: "barButton_action",       appleKey: "Share",                            glossaryFilename: "UIKitCore"           ),
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
    NeededLocalisation(targetKey: "barButton_reply",        appleKey: "Reply",                            glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_rewind",       appleKey: "Rewind",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_save",         appleKey: "Save",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_search",       appleKey: "Search",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_stop",         appleKey: "Stop",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "barButton_undo",         appleKey: "Undo",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "delete",                 appleKey: "Delete",                           glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "find_jump",              appleKey: "315.title",                        glossaryFilename: "TextEdit"            ),
    NeededLocalisation(targetKey: "find_next",              appleKey: "312.title",                        glossaryFilename: "TextEdit"            ),
    NeededLocalisation(targetKey: "find_previous",          appleKey: "314.title",                        glossaryFilename: "TextEdit"            ),
    NeededLocalisation(targetKey: "find_useSelection",      appleKey: "316.title",                        glossaryFilename: "TextEdit"            ),
    NeededLocalisation(targetKey: "navigation_back",        appleKey: "Back",                             glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "refresh",                appleKey: "Refresh",                          glossaryFilename: "UIKitCore"           ),
    NeededLocalisation(targetKey: "scrollView_zoomIn",      appleKey: "438.title",                        glossaryFilename: "WebBrowser"          ),
    NeededLocalisation(targetKey: "scrollView_zoomOut",     appleKey: "439.title",                        glossaryFilename: "WebBrowser"          ),
    NeededLocalisation(targetKey: "scrollView_zoomReset",   appleKey: "863.title",                        glossaryFilename: "WebBrowser"          ),
    NeededLocalisation(targetKey: "window_close",           appleKey: "Close Window",                     glossaryFilename: "AppKit"              ),
    NeededLocalisation(targetKey: "window_cycle",           appleKey: "Cycle Through Windows",            glossaryFilename: "AppKit"              ),
]

struct Localisation {
    let code: String
    let volumeName: String
}

let localisations = [
    Localisation(code: "ar", volumeName: "Arabic"),
    Localisation(code: "ca", volumeName: "Catalan"),
    Localisation(code: "cs", volumeName: "Czech"),
    Localisation(code: "da", volumeName: "Danish"),
    Localisation(code: "de", volumeName: "German"),
    Localisation(code: "el", volumeName: "Greek"),
    Localisation(code: "en", volumeName: "Australian English"), // Apple does not provide a glossary for en so it will need updating manually after generation (organise/organize).
    Localisation(code: "en-AU", volumeName: "Australian English"),
    Localisation(code: "en-GB", volumeName: "British English"),
    Localisation(code: "es", volumeName: "Spanish"),
    Localisation(code: "es-419", volumeName: "Latin"),
    Localisation(code: "fi", volumeName: "Finnish"),
    Localisation(code: "fr", volumeName: "Universal French"),
    Localisation(code: "fr-CA", volumeName: "Canadian"),
    Localisation(code: "he", volumeName: "Hebrew"),
    Localisation(code: "hi", volumeName: "Hindi"),
    Localisation(code: "hr", volumeName: "Croatian"),
    Localisation(code: "hu", volumeName: "Hungarian"),
    Localisation(code: "id", volumeName: "Indonesian"),
    Localisation(code: "it", volumeName: "Italian"),
    Localisation(code: "ja", volumeName: "Japanese"),
    Localisation(code: "ko", volumeName: "Korean"),
    Localisation(code: "ms", volumeName: "Malay"),
    Localisation(code: "nb", volumeName: "Norwegian"),
    Localisation(code: "nl", volumeName: "Dutch"),
    Localisation(code: "pl", volumeName: "Polish"),
    Localisation(code: "pt-BR", volumeName: "Brazilian"),
    Localisation(code: "pt-PT", volumeName: "Portuguese"),
    Localisation(code: "ro", volumeName: "Romanian"),
    Localisation(code: "ru", volumeName: "Russian"),
    Localisation(code: "sk", volumeName: "Slovak"),
    Localisation(code: "sv", volumeName: "Swedish"),
    Localisation(code: "th", volumeName: "Thai"),
    Localisation(code: "tr", volumeName: "Turkish"),
    Localisation(code: "uk", volumeName: "Ukrainian"),
    Localisation(code: "vi", volumeName: "Vietnamese"),
    Localisation(code: "zh-Hans", volumeName: "Simplified Chinese"),
    Localisation(code: "zh-Hant", volumeName: "Traditional Chinese"),
    Localisation(code: "zh-HK", volumeName: "Hong Kong"),
]

/// The directory containing the .lproj directories where the .strings files will be written.
/// The `OUTPUT_DIR` environment variable should be set by the scheme.
let outputDirectory = URL(fileURLWithPath: ProcessInfo.processInfo.environment["OUTPUT_DIR"]!)

// MARK: - Support

extension Collection {
    /// The only element in the collection, or nil if there are multiple or zero elements.
    var single: Element? { count == 1 ? first! : nil }
}

extension URL {
    public func appendingPathComponents(_ pathComponents: [String]) -> URL {
        return pathComponents.enumerated().reduce(self) { url, pair in
            return url.appendingPathComponent(pair.element, isDirectory: pair.offset + 1 < pathComponents.count)
        }
    }
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

/// A localisation entry parsed from a glossary.
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
    let doc = try! XMLDocument(contentsOf: fileURL, options: [.nodePreserveWhitespace])

    return doc.rootElement()!.elements(forName: "File").flatMap { file -> [LocalisationEntry] in
        file.elements(forName: "TextItem").compactMap { textItem -> LocalisationEntry? in
            let translationSet = textItem.singleChild(withName: "TranslationSet")!

            guard let base = translationSet.singleChild(withName: "base")!.textOfSingleChild, let translation = translationSet.singleChild(withName: "tran")!.textOfSingleChild else {
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

func memoisedReadLocalisationEntriesFromFile(at fileURL: URL) -> [LocalisationEntry] {
    enum __ { static var results: [URL: [LocalisationEntry]] = [:] }

    if let existingResult = __.results[fileURL] {
        return existingResult
    }

    let newResult = readLocalisationEntriesFromFile(at: fileURL)
    __.results[fileURL] = newResult
    return newResult
}

// MARK: - The script itself

let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [])!

for localisation in localisations {
    // This reduces peak memory usage from ~2GB to ~200MB.
    autoreleasepool { () -> Void in

        let matchingVolumes = volumes.filter { fileURL -> Bool in
            fileURL.lastPathComponent.contains(localisation.volumeName)
        }

        print("ℹ️ Localising \(localisation.volumeName) (\(localisation.code)) from \(matchingVolumes.count) volumes.") // There should be 2 volumes.

        let lines = neededLocalisations.compactMap { neededLocalisation -> String? in
            let localisationEntries = matchingVolumes.flatMap { volumeURL -> [LocalisationEntry] in
                let glossaryFilePaths = try! FileManager.default.contentsOfDirectory(at: volumeURL, includingPropertiesForKeys: nil, options: []).filter { fileURL in
                    fileURL.lastPathComponent.contains(neededLocalisation.glossaryFilename)
                }

                return glossaryFilePaths.flatMap { fileURL -> [LocalisationEntry] in
                    memoisedReadLocalisationEntriesFromFile(at: fileURL).filter { entry in
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

        let targetStringsFileURL = outputDirectory.appendingPathComponents(["\(localisation.code).lproj", "Localizable.strings"])

        try! FileManager.default.createDirectory(at: targetStringsFileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

        try! """
            // This file was generated from Apple localisation glossaries by ExtractLocalisedStrings.

            \(lines.joined(separator: "\n"))

            """.write(to: targetStringsFileURL, atomically: false, encoding: .utf8)
    }
}
