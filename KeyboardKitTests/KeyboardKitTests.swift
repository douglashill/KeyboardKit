// Douglas Hill, January 2020

@testable import KeyboardKit
import XCTest

private extension UIKeyCommand {
    convenience init(_ modifierFlags: UIKeyModifierFlags = [], _ input: String) {
        self.init((modifierFlags, input), action: #selector(NSObject.accessibilityActivate))
    }
}

class KeyboardKitTests: XCTestCase {

    func testTextInputConflicts() {

        // Letters, numbers, punctuation and symbols. These are the same (or close enough) for all input strings.

        XCTAssertTrue(UIKeyCommand([], "a").doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand(.shift, "a").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.alternate, "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.command, "a").doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand([.shift, .alternate], "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .command], "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate], "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .command], "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.alternate, .command], "a").doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate], "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control, .command], "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate, .command], "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate, .command], "a").doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate, .command], "a").doesConflictWithTextInput)

        // Control and shift control with letters, numbers, punctuation and symbols. These differ with the input string.

        // Technically these do all insert the number so conflict, but they don’t seem useful.
        XCTAssertFalse(UIKeyCommand(.control, "1").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "1").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "2").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "2").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "3").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "3").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "4").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "4").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "5").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "5").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "6").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "6").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "7").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "7").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "8").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "8").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "9").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "9").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "0").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "0").doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand([.shift, .alternate], "a").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .command], "7").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate], "7").doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand(.control, "a").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "a").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "b").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "b").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "c").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "c").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "d").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "d").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "e").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "e").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "f").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "f").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "g").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "g").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "h").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "h").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "i").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "i").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "j").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "j").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "k").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "k").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "l").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "l").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "m").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "m").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "n").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "n").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "o").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "o").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "p").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "p").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "q").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "q").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "r").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "r").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "s").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "s").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, "t").doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .control], "t").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "u").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "u").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "v").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "v").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "w").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "w").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "x").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "x").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "y").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "y").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "z").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "z").doesConflictWithTextInput)

        // These type a backtick (`) for some reason so technically do conflict but this doesn’t seem useful.
        XCTAssertFalse(UIKeyCommand(.control, "§").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "§").doesConflictWithTextInput)

        // These all type nothing.
        XCTAssertFalse(UIKeyCommand(.control, "-").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "-").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "[").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "[").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "]").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "]").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "\\").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "\\").doesConflictWithTextInput)

        // These act the same as if shift was the only modifier, so technically these conflict but they don’t seem useful.
        XCTAssertFalse(UIKeyCommand(.control, ";").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], ";").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "'").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "'").doesConflictWithTextInput)

        // These act the same as if no modifiers were pressed, so technically these conflict but they don’t seem useful.
        XCTAssertFalse(UIKeyCommand(.control, "=").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "=").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "`").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "`").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, ",").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], ",").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, ".").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], ".").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, "/").doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control], "/").doesConflictWithTextInput)

        // Delete

        XCTAssertTrue(UIKeyCommand([], .delete).doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand(.shift, .delete).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, .delete).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.alternate, .delete).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.command, .delete).doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand([.shift, .control], .delete).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .alternate], .delete).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .command], .delete).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate], .delete).doesConflictWithTextInput) // Does something but duplicate.
        XCTAssertFalse(UIKeyCommand([.control, .command], .delete).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.alternate, .command], .delete).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate], .delete).doesConflictWithTextInput) // Does something but duplicate.
        XCTAssertFalse(UIKeyCommand([.shift, .control, .command], .delete).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate, .command], .delete).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate, .command], .delete).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate, .command], .delete).doesConflictWithTextInput)

        // Return

        XCTAssertTrue(UIKeyCommand([], .return).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand(.shift, .return).doesConflictWithTextInput) // Types a newline. Not useful.
        XCTAssertFalse(UIKeyCommand(.control, .return).doesConflictWithTextInput) // Types a newline. Not useful. Differs from the Mac where this types a paragraph break.
        XCTAssertFalse(UIKeyCommand(.alternate, .return).doesConflictWithTextInput) // Types a newline. Not useful.
        XCTAssertFalse(UIKeyCommand(.command, .return).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control], .return).doesConflictWithTextInput) // Types a newline. Not useful.
        XCTAssertFalse(UIKeyCommand([.shift, .alternate], .return).doesConflictWithTextInput) // Types a newline. Not useful.
        XCTAssertFalse(UIKeyCommand([.shift, .command], .return).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate], .return).doesConflictWithTextInput) // Types a newline. Not useful.
        XCTAssertFalse(UIKeyCommand([.control, .command], .return).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.alternate, .command], .return).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate], .return).doesConflictWithTextInput) // Types a newline. Not useful.
        XCTAssertFalse(UIKeyCommand([.shift, .control, .command], .return).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate, .command], .return).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate, .command], .return).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate, .command], .return).doesConflictWithTextInput)

        // Arrow keys

        XCTAssertTrue(UIKeyCommand([], .leftArrow).doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand(.shift, .leftArrow).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.control, .leftArrow).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.alternate, .leftArrow).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand(.command, .leftArrow).doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand([.shift, .control], .leftArrow).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .alternate], .leftArrow).doesConflictWithTextInput)
        XCTAssertTrue(UIKeyCommand([.shift, .command], .leftArrow).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate], .leftArrow).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .command], .leftArrow).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.alternate, .command], .leftArrow).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate], .leftArrow).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control, .command], .leftArrow).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate, .command], .leftArrow).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate, .command], .leftArrow).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate, .command], .leftArrow).doesConflictWithTextInput)

        // Page Down

        XCTAssertFalse(UIKeyCommand([], .pageDown).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand(.shift, .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.alternate, .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.command, .pageDown).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control], .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate], .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .command], .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate], .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .command], .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.alternate, .command], .pageDown).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate], .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control, .command], .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate, .command], .pageDown).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate, .command], .pageDown).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate, .command], .pageDown).doesConflictWithTextInput)

        // Space

        XCTAssertTrue(UIKeyCommand([], .space).doesConflictWithTextInput)

        XCTAssertTrue(UIKeyCommand(.shift, .space).doesConflictWithTextInput) // Same as space with no modifiers. Could be useful if holding shift to type in all caps.
        XCTAssertFalse(UIKeyCommand(.control, .space).doesConflictWithTextInput) // System reserved.
        XCTAssertTrue(UIKeyCommand(.alternate, .space).doesConflictWithTextInput) // Non-breaking space.
        XCTAssertFalse(UIKeyCommand(.command, .space).doesConflictWithTextInput) // System reserved.

        XCTAssertFalse(UIKeyCommand([.shift, .control], .space).doesConflictWithTextInput) // System reserved.
        XCTAssertTrue(UIKeyCommand([.shift, .alternate], .space).doesConflictWithTextInput) // Same as option space (non-breaking space). Don’t allow this to be overridden (as with shift space).
        XCTAssertFalse(UIKeyCommand([.shift, .command], .space).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate], .space).doesConflictWithTextInput) // Same as space with no modifiers, so technically this conflicts. Not considered useful.
        XCTAssertFalse(UIKeyCommand([.control, .command], .space).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.alternate, .command], .space).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate], .space).doesConflictWithTextInput) // Same as space with no modifiers, so technically this conflicts. Not considered useful.
        XCTAssertFalse(UIKeyCommand([.shift, .control, .command], .space).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate, .command], .space).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate, .command], .space).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate, .command], .space).doesConflictWithTextInput)

        // Tab

        XCTAssertTrue(UIKeyCommand([], .tab).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand(.shift, .tab).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.control, .tab).doesConflictWithTextInput) // Same as tab with no modifiers, so technically this conflicts. Not considered useful.
        XCTAssertFalse(UIKeyCommand(.alternate, .tab).doesConflictWithTextInput) // Same as tab with no modifiers, so technically this conflicts. Not considered useful.
        XCTAssertFalse(UIKeyCommand(.command, .tab).doesConflictWithTextInput) // System reserved.

        XCTAssertFalse(UIKeyCommand([.shift, .control], .tab).doesConflictWithTextInput) // Same as tab with no modifiers, so technically this conflicts. Not considered useful.
        XCTAssertFalse(UIKeyCommand([.shift, .alternate], .tab).doesConflictWithTextInput) // Same as tab with no modifiers, so technically this conflicts. Not considered useful.
        XCTAssertFalse(UIKeyCommand([.shift, .command], .tab).doesConflictWithTextInput) // System reserved.
        XCTAssertFalse(UIKeyCommand([.control, .alternate], .tab).doesConflictWithTextInput) // Same as tab with no modifiers, so technically this conflicts. Not considered useful.
        XCTAssertFalse(UIKeyCommand([.control, .command], .tab).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.alternate, .command], .tab).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate], .tab).doesConflictWithTextInput) // Same as tab with no modifiers, so technically this conflicts. Not considered useful.
        XCTAssertFalse(UIKeyCommand([.shift, .control, .command], .tab).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate, .command], .tab).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate, .command], .tab).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate, .command], .tab).doesConflictWithTextInput) // System reserved.

        // Escape

        XCTAssertTrue(UIKeyCommand([], .escape).doesConflictWithTextInput) // Cancels auto-correction suggestion.

        XCTAssertFalse(UIKeyCommand(.shift, .escape).doesConflictWithTextInput) // Same as escape with no modifiers. Not considered useful.
        XCTAssertFalse(UIKeyCommand(.control, .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.alternate, .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand(.command, .escape).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control], .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate], .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .command], .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate], .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .command], .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.alternate, .command], .escape).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate], .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .control, .command], .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.shift, .alternate, .command], .escape).doesConflictWithTextInput)
        XCTAssertFalse(UIKeyCommand([.control, .alternate, .command], .escape).doesConflictWithTextInput)

        XCTAssertFalse(UIKeyCommand([.shift, .control, .alternate, .command], .escape).doesConflictWithTextInput)
    }
}
