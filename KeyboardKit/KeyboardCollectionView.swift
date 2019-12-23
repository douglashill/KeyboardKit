// Douglas Hill, May 2019

import UIKit

/// A collection view that supports navigation and selection using a hardware keyboard.
open class KeyboardCollectionView: UICollectionView, ResponderChainInjection {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var selectableCollectionKeyHandler = SelectableCollectionKeyHandler(selectableCollection: self, owner: self)
    private lazy var scrollViewKeyHandler = ScrollViewKeyHandler(scrollView: self, owner: self)

    public override var next: UIResponder? {
        selectableCollectionKeyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        if responder === selectableCollectionKeyHandler {
            return scrollViewKeyHandler
        } else if responder == scrollViewKeyHandler {
            return super.next
        } else {
            fatalError()
        }
    }
}

/// A collection view controller that supports navigation and selection using a hardware keyboard.
open class KeyboardCollectionViewController: UICollectionViewController, ResponderChainInjection {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var selectableCollectionKeyHandler = SelectableCollectionKeyHandler(selectableCollection: collectionView, owner: self)
    private lazy var scrollViewKeyHandler = ScrollViewKeyHandler(scrollView: collectionView, owner: self)

    public override var next: UIResponder? {
        selectableCollectionKeyHandler
    }

    func nextResponderForResponder(_ responder: UIResponder) -> UIResponder? {
        if responder === selectableCollectionKeyHandler {
            return scrollViewKeyHandler
        } else if responder == scrollViewKeyHandler {
            return super.next
        } else {
            fatalError()
        }
    }
}

extension UICollectionView {
    override var kbd_isArrowKeyScrollingEnabled: Bool {
        shouldAllowSelection == false
    }

    override var kbd_isSpaceBarScrollingEnabled: Bool {
        shouldAllowSelection == false
    }
}

extension UICollectionView: SelectableCollection {

    var shouldAllowSelection: Bool {
        allowsSelection
    }

    var shouldAllowMultipleSelection: Bool {
        allowsMultipleSelection
    }

    func shouldSelectItemAtIndexPath(_ indexPath: IndexPath) -> Bool {
        delegate?.collectionView?(self, shouldHighlightItemAt: indexPath) ?? true
    }

    func activateSelection(at indexPath: IndexPath) {
        delegate?.collectionView?(self, didSelectItemAt: indexPath)
    }

    func cellVisibility(atIndexPath indexPath: IndexPath) -> CellVisibility {

        // TODO: The use of frame likely gives incorrect results if there are transforms.

        // Note the force unwrapping. Not sure why this is nullable.
        let layoutAttributes = collectionViewLayout.layoutAttributesForItem(at: indexPath)!
        if bounds.inset(by: adjustedContentInset).contains(layoutAttributes.frame) {
            return .fullyVisible
        }

        var position: UICollectionView.ScrollPosition = []
        position.insert(layoutAttributes.frame.midY < bounds.midY ? .top : .bottom)
        position.insert(layoutAttributes.frame.midX < bounds.midX ? .left : .right)

        return .notFullyVisible(position)
    }

    func indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection direction: NavigationDirection, step: NavigationStep, forKeyHandler keyHandler: SelectableCollectionKeyHandler) -> IndexPath? {
        collectionViewLayout.kbd_indexPathFromIndexPath(indexPath, inDirection: direction.rawValue, step: step.rawValue, forKeyHandler: keyHandler)
    }
}

private extension UICollectionViewLayout {

    /// Maps from an old selected index path to a new selected index path by moving by the given step in the given direction.
    ///
    /// `UICollectionViewLayout` implements this method in a spatial manner. Subclasses may override this to provide better handling. Calling super is not necessary.
    ///
    /// This needs to use Objective-C to get dynamic dispatch. However this means that Swift enums can’t be used as parameters. Therefore pass around integers. Bridging at its best!
    ///
    /// - Parameters:
    ///   - indexPath: The existing selected index path if there is one.
    ///   - rawDirection: The direction in which to move the selection. The value is the raw representation of a `NavigationDirection`.
    ///   - rawStep: The step by which to move the selection. The value is the raw representation of a `NavigationStep`.
    ///   - keyHandler: The key handler. Provided to do index path operations like finding the first selectable index path.
    ///
    /// - Returns: The adjusted index path or nil if no appropriate index path exists.
    @objc func kbd_indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection rawDirection: Int, step rawStep: Int, forKeyHandler keyHandler: SelectableCollectionKeyHandler) -> IndexPath? {
        let direction = NavigationDirection(rawValue: rawDirection)!

        guard
            let oldIndexPath = indexPath,
            let attributesOfOldSelection = layoutAttributesForItem(at: oldIndexPath)
        else {
                // It’s very layout-dependent what would make sense here. Important to return something though otherwise it would be impossible to get started with arrow key navigation.
                return keyHandler.firstSelectableIndexPath
        }

        let rectangleOfOldSelection = attributesOfOldSelection.frame
        let centreOfOldSelection = attributesOfOldSelection.center

        // TODO: step is ignored. Just dealing with closest for now.

        // Search some small distance along.
        let distanceToSearch:  CGFloat = 500
        let rectangleToSearch: CGRect
        switch direction {
        case .up:
            rectangleToSearch = CGRect(x: rectangleOfOldSelection.minX, y: rectangleOfOldSelection.midY - distanceToSearch, width: rectangleOfOldSelection.width, height: distanceToSearch)
        case .down:
            rectangleToSearch = CGRect(x: rectangleOfOldSelection.minX, y: rectangleOfOldSelection.midY, width: rectangleOfOldSelection.width, height: distanceToSearch)
        case .left:
            rectangleToSearch = CGRect(x: rectangleOfOldSelection.midX - distanceToSearch, y: rectangleOfOldSelection.minY, width: distanceToSearch, height: rectangleOfOldSelection.height)
        case .right:
            rectangleToSearch = CGRect(x: rectangleOfOldSelection.midX, y: rectangleOfOldSelection.minY, width: distanceToSearch, height: rectangleOfOldSelection.height)
        }

        let attributesArray = layoutAttributesForElements(in: rectangleToSearch) ?? []

        var closestAttributes: UICollectionViewLayoutAttributes?
        var smallestDistance = CGFloat.greatestFiniteMagnitude

        for attributes in attributesArray {
            if attributes.isHidden {
                continue
            }

            let distance: CGFloat

            switch direction {
            case .up:
                distance = centreOfOldSelection.y - attributes.center.y
            case .down:
                distance = attributes.center.y - centreOfOldSelection.y
            case .left:
                distance = centreOfOldSelection.x - attributes.center.x
            case .right:
                distance = attributes.center.x - centreOfOldSelection.x
            }

            if distance > 0 && distance < smallestDistance {
                closestAttributes = attributes
                smallestDistance = distance
            }
        }

        // TODO: Search further if finding nothing.

        return closestAttributes?.indexPath
    }
}

private extension UICollectionViewFlowLayout {

    override func kbd_indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection rawDirection: Int, step rawStep: Int, forKeyHandler keyHandler: SelectableCollectionKeyHandler) -> IndexPath? {

        // TODO: Wrapping so it goes to the previous or next index path when reaching the end of a line with flow layout.

        return super.indexPathFromIndexPath(indexPath, inDirection: rawDirection, step: rawStep, forKeyHandler: keyHandler)
    }
}
