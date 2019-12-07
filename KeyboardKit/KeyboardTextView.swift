// Douglas Hill, December 2019

import UIKit

/// A text view that supports hardware keyboard commands to use the selection for find, find previous/next, and jump to the selection.
public class KeyboardTextView: UITextView {

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        guard isSelectable else {
            return commands
        }

        commands += [
            UIKeyCommand(title: localisedString(.find_next), action: #selector(findNext(_:)), input: "g", modifierFlags: .command),
            UIKeyCommand(title: localisedString(.find_previous), action: #selector(findPrevious(_:)), input: "g", modifierFlags: [.command, .shift]),
            UIKeyCommand(title: localisedString(.find_useSelection), action: #selector(useSelectionForFind(_:)), input: "e", modifierFlags: .command),
            UIKeyCommand(title: localisedString(.find_jump), action: #selector(jumpToSelection(_:)), input: "j", modifierFlags: .command),
        ]

        return commands
    }

    /// Selects the next instance of the text that was previously searched for, starting from the current selection
    /// or insertion point. Wraps to search from the start if needed. Scrolls to make the selection visible.
    @objc private func findNext(_ sender: UIKeyCommand) {
        findNext(isBackwards: false)
    }

    /// Selects the previous instance of the text that was previously searched for, starting from the current
    /// selection or insertion point. Wraps to search from the end if needed. Scrolls to make the selection visible.
    @objc private func findPrevious(_ sender: UIKeyCommand) {
        findNext(isBackwards: true)
    }

    /// Selects the next (or previous if isBackwards is true) instance of the text that was previously searched for,
    /// starting from the current selection or insertion point. Wraps around if needed. Scrolls to make the selection visible.
    private func findNext(isBackwards: Bool) {
        // Possible improved implementation: use a substring and localizedStandardRange.

        guard let textToFind = findPasteboard.string, let selectedTextRange = selectedTextRange else {
            return
        }

        let searchStartOffset = isBackwards ? 0 : offset(from: beginningOfDocument, to: selectedTextRange.end)
        let searchLength = isBackwards ? offset(from: beginningOfDocument, to: selectedTextRange.start) : offset(from: selectedTextRange.end, to: endOfDocument)

        let rangeToSearch = Range(NSRange(location: searchStartOffset, length: searchLength), in: text)

        var options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        if isBackwards { options.insert(.backwards) }

        // Try rangeToSearch first and then wrap around to the start/end if the text isn’t found in that range.
        guard let targetRange = text.range(of: textToFind, options: options, range: rangeToSearch) ?? text.range(of: textToFind, options: options) else {
            return
        }

        selectedRange = NSRange(targetRange, in: text)
        jumpToSelection()
    }

    /// If there is selected text, it is marked as being used for find/search.
    @objc private func useSelectionForFind(_ sender: UIKeyCommand) {
        guard let selectedTextRange = selectedTextRange, let selectedText = text(in: selectedTextRange), selectedText.isEmpty == false else {
            return
        }

        findPasteboard.string = selectedText
    }

    /// Scrolls so the current selected text or the insertion point is visible.
    @objc private func jumpToSelection(_ sender: UIKeyCommand) {
        jumpToSelection()
    }

    /// Scrolls so the current selected text or the insertion point is visible.
    private func jumpToSelection() {
        // scrollRangeToVisible(selectedRange) does not consider insets so use different API.
        
        guard let selectedTextRange = selectedTextRange else {
            return
        }

        scrollRectToVisible(firstRect(for: selectedTextRange), animated: true)
    }
}

/// A pasteboard that stores the most recently searched for text.
/// It’s a shame this can’t be shared across apps because that’s a very useful timesaver on the Mac.
private let findPasteboard = UIPasteboard.withUniqueName()
