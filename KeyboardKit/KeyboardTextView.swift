// Douglas Hill, December 2019

import UIKit

/// A text view that supports hardware keyboard commands to use the selection for find, find previous/next, and jump to the selection.
open class KeyboardTextView: UITextView, ResponderChainInjection {

    private lazy var selectionActionKeyCommands: [UIKeyCommand] = {
        var commands: [UIKeyCommand]
        // The system provides Look Up on Catalyst so we don’t need to provide our own command.
        #if targetEnvironment(macCatalyst)
        commands = []
        #else
        commands = [UIKeyCommand(([.command, .control], "d"), action: #selector(kbd_define), title: localisedString(.text_define))]
        #endif
        commands += [
            UIKeyCommand((.command, "g"), action: #selector(kbd_findNext), title: localisedString(.find_next)),
            UIKeyCommand(([.command, .shift], "g"), action: #selector(kbd_findPrevious), title: localisedString(.find_previous)),
            UIKeyCommand((.command, "e"), action: #selector(kbd_useSelectionForFind), title: localisedString(.find_useSelection)),
            UIKeyCommand((.command, "j"), action: #selector(kbd_jumpToSelection), title: localisedString(.find_jump)),
        ]
        return commands
    }()

    private lazy var scrollViewKeyHandler = ScrollViewKeyHandler(scrollView: self, owner: self)

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if isSelectable {
            commands += selectionActionKeyCommands
        }

        return commands
    }

    public override var next: UIResponder? {
        scrollViewKeyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        super.next
    }

    @objc func kbd_define(_ sender: UIKeyCommand) {
        // An attempt was made to use UIKit’s private showServiceForText API to get the superior Look Up UI that they don’t expose publicly but I couldn’t make it work.

        guard
            let selectedTextRange = selectedTextRange,
            let selectedText = text(in: selectedTextRange),
            selectedText.isEmpty == false,
            let selectionRect = selectionRects(for: selectedTextRange).reduce(nil, { unionRect, textSelectionRect -> CGRect? in
                unionRect == nil ? textSelectionRect.rect : unionRect!.union(textSelectionRect.rect)
            }),
            let topmostViewController = window?.topmostViewController,
            // Consistency check that we get the same results searching upwards and downwards in the hierarchy.
            isInHierarchyOfView(topmostViewController.view)
        else {
            return
        }

        let referenceLibrary = UIReferenceLibraryViewController(term: selectedText)
        referenceLibrary.modalPresentationStyle = .popover
        referenceLibrary.popoverPresentationController?.sourceView = self
        referenceLibrary.popoverPresentationController?.sourceRect = selectionRect

        topmostViewController.present(referenceLibrary, animated: true)
    }

    /// Selects the next instance of the text that was previously searched for, starting from the current selection
    /// or insertion point. Wraps to search from the start if needed. Scrolls to make the selection visible.
    @objc func kbd_findNext(_ sender: UIKeyCommand) {
        findNext(isBackwards: false)
    }

    /// Selects the previous instance of the text that was previously searched for, starting from the current
    /// selection or insertion point. Wraps to search from the end if needed. Scrolls to make the selection visible.
    @objc func kbd_findPrevious(_ sender: UIKeyCommand) {
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
    @objc func kbd_useSelectionForFind(_ sender: UIKeyCommand) {
        guard let selectedTextRange = selectedTextRange, let selectedText = text(in: selectedTextRange), selectedText.isEmpty == false else {
            return
        }

        findPasteboard.string = selectedText
    }

    /// Scrolls so the current selected text or the insertion point is visible.
    @objc func kbd_jumpToSelection(_ sender: UIKeyCommand) {
        jumpToSelection()
    }

    /// Scrolls so the current selected text or the insertion point is visible.
    /// Does not scroll with animation to keep the interaction fast and match AppKit.
    private func jumpToSelection() {
        // scrollRangeToVisible(selectedRange) does not consider insets so use different API.
        
        guard let selectedTextRange = selectedTextRange else {
            return
        }

        // Add a bit of padding on the top and bottom so the text doesn’t appear right at the top/bottom edge.
        let targetRectangle = firstRect(for: selectedTextRange).inset(by: UIEdgeInsets(top: -8, left: 0, bottom: -10, right: 0))
        scrollRectToVisible(targetRectangle, animated: false)
    }
}

extension UITextView {
    override var kbd_isArrowKeyScrollingEnabled: Bool {
        isEditable == false
    }

    override var kbd_isSpaceBarScrollingEnabled: Bool {
        isEditable == false
    }
}

private extension UIWindow {
    /// Returns the root view controller, or its presented view controller, or its presented view controller etc.
    var topmostViewController: UIViewController? {
        guard var viewController = rootViewController else {
            return nil
        }
        while let presentedViewController = viewController.presentedViewController {
            viewController = presentedViewController
        }
        return viewController
    }
}

private extension UIView {
    /// Whether the receiver is `parentView` or is a descendant (recursive child) of `parentView`.
    /// In other words, whether `parentView` is an ancestor (recursive parent) of the receiver or is the receiver.
    func isInHierarchyOfView(_ parentView: UIView) -> Bool {
        var maybeView: UIView? = self
        while let view = maybeView {
            if view === parentView {
                return true
            }
            maybeView = view.superview
        }
        return false
    }
}

/// A pasteboard that stores the most recently searched for text.
/// It’s a shame this can’t be shared across apps because that’s a very useful timesaver on the Mac.
private let findPasteboard = UIPasteboard.withUniqueName()
