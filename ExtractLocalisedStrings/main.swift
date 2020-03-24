// Douglas Hill, March 2020

// Extracts localised strings from Apple’s glossary files. See the adjacent README.md.

import Foundation

/*

 Status:

 I’m dubious of this ‘most popular’ approach because I think it’s biased by
 old or Mac translations.

 */

// MARK: Input data

/// A localised strings entry that we want to extract from Apple’s glossary files.
struct NeededLocalisation {
    /// The key to use in the generated KeyboardKit .strings file.
    let targetKey: String
    /// The English text.
    let english: String
}

let neededLocalisations = [
    NeededLocalisation(targetKey: "app_newWindow",         english: "New Window"),
    NeededLocalisation(targetKey: "app_settings",          english: "Settings"),
    NeededLocalisation(targetKey: "barButton_action",      english: "Share"),
    NeededLocalisation(targetKey: "barButton_add",         english: "Add"),
    NeededLocalisation(targetKey: "barButton_bookmarks",   english: "Bookmarks"),
    NeededLocalisation(targetKey: "barButton_camera",      english: "Camera"),
    NeededLocalisation(targetKey: "barButton_cancel",      english: "Cancel"),
    NeededLocalisation(targetKey: "barButton_close",       english: "Close"),
    NeededLocalisation(targetKey: "barButton_compose",     english: "Compose"),
    NeededLocalisation(targetKey: "barButton_done",        english: "Done"),
    NeededLocalisation(targetKey: "barButton_edit",        english: "Edit"),
    NeededLocalisation(targetKey: "barButton_fastForward", english: "Fast Forward"),
    NeededLocalisation(targetKey: "barButton_organize",    english: "Organize"),
    NeededLocalisation(targetKey: "barButton_pause",       english: "Pause"),
    NeededLocalisation(targetKey: "barButton_play",        english: "Play"),
    NeededLocalisation(targetKey: "barButton_redo",        english: "Redo"),
    NeededLocalisation(targetKey: "barButton_reply",       english: "Reply"),
    NeededLocalisation(targetKey: "barButton_rewind",      english: "Rewind"),
    NeededLocalisation(targetKey: "barButton_save",        english: "Save"),
    NeededLocalisation(targetKey: "barButton_search",      english: "Search"),
    NeededLocalisation(targetKey: "barButton_stop",        english: "Stop"),
    NeededLocalisation(targetKey: "barButton_undo",        english: "Undo"),
    NeededLocalisation(targetKey: "delete",                english: "Delete"),
    NeededLocalisation(targetKey: "find_jump",             english: "Jump to Selection"),
    NeededLocalisation(targetKey: "find_next",             english: "Find Next"),
    NeededLocalisation(targetKey: "find_previous",         english: "Find Previous"),
    NeededLocalisation(targetKey: "find_useSelection",     english: "Use Selection for Find"),
    NeededLocalisation(targetKey: "navigation_back",       english: "Back"),
    NeededLocalisation(targetKey: "refresh",               english: "Refresh"),
    NeededLocalisation(targetKey: "scrollView_zoomIn",     english: "Zoom In"),
    NeededLocalisation(targetKey: "scrollView_zoomOut",    english: "Zoom Out"),
    NeededLocalisation(targetKey: "scrollView_zoomReset",  english: "Actual Size"),
    NeededLocalisation(targetKey: "window_close",          english: "Close Window"),
    NeededLocalisation(targetKey: "window_cycle",          english: "Cycle Through Windows"),
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
    Localisation(code: "en", volumeName: "???"),
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
    /// The English text.
    let base: String
    /// The localised text.
    let translation: String
}

func readLocalisationEntriesFromFile(at fileURL: URL, allowedBases: Set<String>) -> [LocalisationEntry] {
    autoreleasepool {
        let doc = try! XMLDocument(contentsOf: fileURL, options: [.nodePreserveWhitespace])

        return doc.rootElement()!.elements(forName: "File").flatMap { file -> [LocalisationEntry] in
            file.elements(forName: "TextItem").compactMap { textItem -> LocalisationEntry? in
                let translationSet = textItem.singleChild(withName: "TranslationSet")!

                guard
                    let base = translationSet.singleChild(withName: "base")!.textOfSingleChild,
                    allowedBases.contains(base),
                    let translation = translationSet.singleChild(withName: "tran")!.textOfSingleChild
                    else {
                        return nil
                }

                return LocalisationEntry(base: base, translation: translation)
            }
        }
    }
}

// MARK: - The script itself

let allowedBases = Set<String>(neededLocalisations.map{ $0.english })

let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [])!

for localisation in localisations {
    autoreleasepool {
        let lines: [String]
        if localisation.code == "en" {
            lines = neededLocalisations.compactMap { neededLocalisation -> String? in
                return """
                "\(neededLocalisation.targetKey)" = "\(neededLocalisation.english)";
                """
            }
        } else {
            let matchingVolumes = volumes.filter { fileURL -> Bool in
                fileURL.lastPathComponent.contains(localisation.volumeName)
            }

            print("ℹ️ Localising \(localisation.volumeName) (\(localisation.code)) from \(matchingVolumes.count) volumes.") // There should be 2 volumes.
            precondition(matchingVolumes.count == 2)

            let localisationEntries = matchingVolumes.flatMap { volumeURL -> [LocalisationEntry] in
                let glossaryFilePaths = try! FileManager.default.contentsOfDirectory(at: volumeURL, includingPropertiesForKeys: nil, options: [])
                return glossaryFilePaths.flatMap { fileURL -> [LocalisationEntry] in
                    readLocalisationEntriesFromFile(at: fileURL, allowedBases: allowedBases)
                }
            }
            print("✅ Read \(localisationEntries.count) localisation entries.")

            var translationsByEnglishText: [String: [String: Int]] = [:]
            for entry in localisationEntries {
                var translationsForThisEnglishText = translationsByEnglishText[entry.base] ?? [:]
                var countsForThisTranslation = translationsForThisEnglishText[entry.translation] ?? 0
                countsForThisTranslation += 1
                translationsForThisEnglishText[entry.translation] = countsForThisTranslation
                translationsByEnglishText[entry.base] = translationsForThisEnglishText
            }
            print("✅ There are \(translationsByEnglishText.count) unique English strings.")

            lines = neededLocalisations.compactMap { neededLocalisation -> String? in
                let translations = translationsByEnglishText[neededLocalisation.english]!

                let mostCommonTranslation = (translations.max {
                    $0.value < $1.value
                    }!).key

                return """
                "\(neededLocalisation.targetKey)" = "\(mostCommonTranslation)";
                """
            }
        }

        let targetStringsFileURL = outputDirectory.appendingPathComponents(["\(localisation.code).lproj", "Localizable.strings"])

        try! FileManager.default.createDirectory(at: targetStringsFileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

        try! """
            // This file was generated from Apple localisation glossaries by ExtractLocalisedStrings.

            \(lines.joined(separator: "\n"))

            """.write(to: targetStringsFileURL, atomically: false, encoding: .utf8)
    }
}
