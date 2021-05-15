// Douglas Hill, May 2021

@testable import KeyboardKit
import XCTest

class ScrollingLimitsTests: XCTestCase {
    private let scrollView = KeyboardScrollView()

    override func setUp() {
        super.setUp()

        let viewController = (UIApplication.shared.connectedScenes.first! as! UIWindowScene).windows.first!.rootViewController!
        XCTAssertFalse(viewController.view.bounds.isEmpty)
        viewController.view.addSubview(scrollView)
        XCTAssertTrue(scrollView.becomeFirstResponder())

        scrollView.contentInsetAdjustmentBehavior = .never
    }

    func testContentLargerThanBoundsInBothDimensions() {
        scrollView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        scrollView.contentSize = CGSize(width: 400, height: 400)
        XCTAssertFalse(sendScrollAction(.upArrow))
        XCTAssertFalse(sendScrollAction(.leftArrow))

        scrollView.contentOffset = CGPoint(x: 150, y: 150)
        XCTAssertTrue(sendScrollAction(.upArrow))
        XCTAssertTrue(sendScrollAction(.downArrow))
        XCTAssertTrue(sendScrollAction(.leftArrow))
        XCTAssertTrue(sendScrollAction(.rightArrow))
    }

    // This was broken in the initial implementation.
    func testContentSmallerThanBoundsInBothDimensions() {
        scrollView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        scrollView.contentSize = CGSize(width: 10, height: 10)
        XCTAssertFalse(sendScrollAction(.upArrow))
        XCTAssertFalse(sendScrollAction(.downArrow))
        XCTAssertFalse(sendScrollAction(.leftArrow))
        XCTAssertFalse(sendScrollAction(.rightArrow))
    }

    // This was broken in the initial implementation.
    func testContentLessWideThanBounds() {
        scrollView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        scrollView.contentSize = CGSize(width: 10, height: 1000)
        XCTAssertFalse(sendScrollAction(.upArrow))
        XCTAssertTrue(sendScrollAction(.downArrow))
        XCTAssertFalse(sendScrollAction(.leftArrow))
        XCTAssertFalse(sendScrollAction(.rightArrow))

        scrollView.contentOffset = CGPoint(x: 0, y: 500)
        XCTAssertTrue(sendScrollAction(.upArrow))
        XCTAssertTrue(sendScrollAction(.downArrow))
        XCTAssertFalse(sendScrollAction(.leftArrow))
        XCTAssertFalse(sendScrollAction(.rightArrow))
    }

    // This was broken in the initial implementation.
    func testContentLessTallThanBounds() {
        scrollView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        scrollView.contentSize = CGSize(width: 500, height: 350)
        XCTAssertFalse(sendScrollAction(.upArrow))
        XCTAssertFalse(sendScrollAction(.downArrow))
        XCTAssertFalse(sendScrollAction(.leftArrow))
        XCTAssertTrue(sendScrollAction(.rightArrow))

        scrollView.contentOffset = CGPoint(x: 100, y: 0)
        XCTAssertFalse(sendScrollAction(.upArrow))
        XCTAssertFalse(sendScrollAction(.downArrow))
        XCTAssertTrue(sendScrollAction(.leftArrow))
        XCTAssertTrue(sendScrollAction(.rightArrow))
    }

    // This is a common case with a vertically scrolling list where it wouldn’t need scrolling without insets, but does need to scroll because of the insets.
    func testScrollingBecauseOfInsets() {
        scrollView.frame = CGRect(x: 0, y: 0, width: 375, height: 500)
        scrollView.contentSize = CGSize(width: 375, height: 400)
        scrollView.contentInset = UIEdgeInsets(top: 88, left: 0, bottom: 30, right: 0)
        scrollView.contentOffset = CGPoint(x: 0, y: -88)
        XCTAssertFalse(sendScrollAction(.upArrow))
        XCTAssertFalse(sendScrollAction(.leftArrow))
        XCTAssertFalse(sendScrollAction(.rightArrow))
        XCTAssertTrue(sendScrollAction(.downArrow))
    }

    // This worked in the initial implementation but regressed in 3980fb748fb71274d2f5f586477653611af4b005.
    func testInsetsFillingWidth() {
        scrollView.frame = CGRect(x: 0, y: 0, width: 1180, height: 820)
        scrollView.contentSize = CGSize(width: 616, height: 820)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 282, bottom: 0, right: 282)
        scrollView.contentOffset = CGPoint(x: -282, y: 0)
        XCTAssertFalse(sendScrollAction(.upArrow))
        XCTAssertFalse(sendScrollAction(.downArrow))
        XCTAssertFalse(sendScrollAction(.leftArrow))
        XCTAssertFalse(sendScrollAction(.rightArrow))
    }

    private func sendScrollAction(_ input: String) -> Bool {
        UIApplication.shared.sendAction(#selector(ScrollViewKeyHandler.scrollFromKeyCommand), to: nil, from: UIKeyCommand(input, action: #selector(ScrollViewKeyHandler.scrollFromKeyCommand)), for: nil)
    }
}
