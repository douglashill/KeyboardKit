// Douglas Hill, December 2020

import XCTest

class KeyboardKitDemoUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testUpAndDownArrowsDoNotGoToPrimaryWhenSecondaryIsFirstResponder() throws {
        let app = XCUIApplication()
        app.launch()

        // `typeText` only works on Catalyst. On iPad calling this fails with “Neither element nor any descendant has keyboard focus”
        // even if you call it on the element that is first responder. I guess only software keyboard typing is supported on iOS.
        // Reported as FB8936487 - Should be possible to test hardware keyboard input on iOS/iPadOS.
        // On Mac it doesn’t seem to matter which element you call typeText on so I’m just using the app element.

        XCTAssertTrue(app.tables.element.exists)
        app.typeText(.downArrow)
        XCTAssertTrue(app.collectionViews["list collection view"].exists)
        app.typeText(.downArrow)
        XCTAssertTrue(app.collectionViews["compositional layout collection view"].exists)
        app.typeText(.downArrow)
        XCTAssertTrue(app.collectionViews["flow layout collection view"].exists)
        app.typeText(.downArrow)
        XCTAssertTrue(app.scrollViews["circles scroll view"].exists)
        app.typeText(.downArrow)
        XCTAssertTrue(app.scrollViews["paging scroll view"].exists)
        app.typeText(.rightArrow)
        app.typeText(.upArrow)
        XCTAssertTrue(app.scrollViews["paging scroll view"].exists, "Up arrow should have done nothing. It should not have been handled by the sidebar.")
    }
}

// MARK: - Helpers

// typeText and typeKey expect a String rather than a XCUIKeyboardKey so
// use this extension to reduce Swift boilerplate at the point of use.
private extension String {
    static let delete = XCUIKeyboardKey.delete.rawValue
    static let `return` = XCUIKeyboardKey.`return`.rawValue
    static let enter = XCUIKeyboardKey.enter.rawValue
    static let tab = XCUIKeyboardKey.tab.rawValue
    static let space = XCUIKeyboardKey.space.rawValue
    static let escape = XCUIKeyboardKey.escape.rawValue
    static let upArrow = XCUIKeyboardKey.upArrow.rawValue
    static let downArrow = XCUIKeyboardKey.downArrow.rawValue
    static let leftArrow = XCUIKeyboardKey.leftArrow.rawValue
    static let rightArrow = XCUIKeyboardKey.rightArrow.rawValue
    static let F1 = XCUIKeyboardKey.F1.rawValue
    static let F2 = XCUIKeyboardKey.F2.rawValue
    static let F3 = XCUIKeyboardKey.F3.rawValue
    static let F4 = XCUIKeyboardKey.F4.rawValue
    static let F5 = XCUIKeyboardKey.F5.rawValue
    static let F6 = XCUIKeyboardKey.F6.rawValue
    static let F7 = XCUIKeyboardKey.F7.rawValue
    static let F8 = XCUIKeyboardKey.F8.rawValue
    static let F9 = XCUIKeyboardKey.F9.rawValue
    static let F10 = XCUIKeyboardKey.F10.rawValue
    static let F11 = XCUIKeyboardKey.F11.rawValue
    static let F12 = XCUIKeyboardKey.F12.rawValue
    static let F13 = XCUIKeyboardKey.F13.rawValue
    static let F14 = XCUIKeyboardKey.F14.rawValue
    static let F15 = XCUIKeyboardKey.F15.rawValue
    static let F16 = XCUIKeyboardKey.F16.rawValue
    static let F17 = XCUIKeyboardKey.F17.rawValue
    static let F18 = XCUIKeyboardKey.F18.rawValue
    static let F19 = XCUIKeyboardKey.F19.rawValue
    static let forwardDelete = XCUIKeyboardKey.forwardDelete.rawValue
    static let home = XCUIKeyboardKey.home.rawValue
    static let end = XCUIKeyboardKey.end.rawValue
    static let pageUp = XCUIKeyboardKey.pageUp.rawValue
    static let pageDown = XCUIKeyboardKey.pageDown.rawValue
    static let clear = XCUIKeyboardKey.clear.rawValue
    static let help = XCUIKeyboardKey.help.rawValue
    static let capsLock = XCUIKeyboardKey.capsLock.rawValue
    static let shift = XCUIKeyboardKey.shift.rawValue
    static let control = XCUIKeyboardKey.control.rawValue
    static let option = XCUIKeyboardKey.option.rawValue
    static let command = XCUIKeyboardKey.command.rawValue
    static let rightShift = XCUIKeyboardKey.rightShift.rawValue
    static let rightControl = XCUIKeyboardKey.rightControl.rawValue
    static let rightOption = XCUIKeyboardKey.rightOption.rawValue
    static let rightCommand = XCUIKeyboardKey.rightCommand.rawValue
    static let secondaryFn = XCUIKeyboardKey.secondaryFn.rawValue
}
