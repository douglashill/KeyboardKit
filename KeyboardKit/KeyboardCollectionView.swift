// Douglas Hill, May 2019

import UIKit

/// A collection view that supports navigation and selection using a hardware keyboard.
/// Wrapping the selection on reaching the end of a row or column is only supported with `UICollectionViewFlowLayout`.
/// `UICollectionViewCompositionalLayout`’s `orthogonalScrollingBehavior` is not supported.
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
            preconditionFailure()
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
            preconditionFailure()
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

    func indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection direction: NavigationDirection, step: NavigationStep) -> IndexPath? {
        collectionViewLayout.kbd_indexPathFromIndexPath(indexPath, inDirection: direction.rawValue, step: step.rawValue)
    }
}

private extension UICollectionViewLayout {

    /// Maps from an old selected index path to a new selected index path by moving by the given step in the given direction.
    ///
    /// `UICollectionViewLayout` implements this method in a spatial manner. Subclasses may override this to provide better handling. Calling super is not necessary.
    ///
    /// This needs to use `@objc` so it can be overridden by subclasses. This means that Swift enums can’t be used as parameters, so pass around integers. Bridging at its best!
    ///
    /// - Parameters:
    ///   - indexPath: The existing selected index path if there is one.
    ///   - rawDirection: The direction in which to move the selection. The value is the raw representation of a `NavigationDirection`.
    ///   - rawStep: The step by which to move the selection. The value is the raw representation of a `NavigationStep`.
    ///   - keyHandler: The key handler. Provided to do index path operations like finding the first selectable index path.
    ///
    /// - Returns: The adjusted index path or nil if no appropriate index path exists.
    @objc func kbd_indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection rawDirection: Int, step rawStep: Int) -> IndexPath? {
        let direction = NavigationDirection(rawValue: rawDirection)!
        let step = NavigationStep(rawValue: rawStep)!

        guard
            let oldIndexPath = indexPath,
            let attributesOfOldSelection = layoutAttributesForItem(at: oldIndexPath)
        else {
            // It’s very layout-dependent what would make sense here. Important to return something though otherwise it would be impossible to get started with arrow key navigation.
            return collectionView!.firstSelectableIndexPath
        }

        let rectangleOfOldSelection = attributesOfOldSelection.frame
        let centreOfOldSelection = attributesOfOldSelection.center
        let contentSize = collectionViewContentSize

        func indexPathBySearchingWithOffset(_ offset: CGFloat, distance distanceToSearch: CGFloat) -> IndexPath? {
            let rectangleToSearch: CGRect
            switch (direction, step) {

            case (.up, .closest):
                rectangleToSearch = CGRect(x: rectangleOfOldSelection.minX, y: rectangleOfOldSelection.midY - offset - distanceToSearch, width: rectangleOfOldSelection.width, height: distanceToSearch)
            case (.down, .end):
                rectangleToSearch = CGRect(x: rectangleOfOldSelection.minX, y: contentSize.height - offset - distanceToSearch, width: rectangleOfOldSelection.width, height: distanceToSearch)

            case (.down, .closest):
                rectangleToSearch = CGRect(x: rectangleOfOldSelection.minX, y: rectangleOfOldSelection.midY + offset, width: rectangleOfOldSelection.width, height: distanceToSearch)
            case (.up, .end):
                rectangleToSearch = CGRect(x: rectangleOfOldSelection.minX, y: 0 + offset, width: rectangleOfOldSelection.width, height: distanceToSearch)

            case (.left, .closest):
                rectangleToSearch = CGRect(x: rectangleOfOldSelection.midX - offset - distanceToSearch, y: rectangleOfOldSelection.minY, width: distanceToSearch, height: rectangleOfOldSelection.height)
            case (.right, .end):
                rectangleToSearch = CGRect(x: contentSize.width - offset - distanceToSearch, y: rectangleOfOldSelection.minY, width: distanceToSearch, height: rectangleOfOldSelection.height)

            case (.right, .closest):
                rectangleToSearch = CGRect(x: rectangleOfOldSelection.midX + offset, y: rectangleOfOldSelection.minY, width: distanceToSearch, height: rectangleOfOldSelection.height)
            case (.left, .end):
                rectangleToSearch = CGRect(x: 0 + offset, y: rectangleOfOldSelection.minY, width: distanceToSearch, height: rectangleOfOldSelection.height)
            }

            let attributesArray = layoutAttributesForElements(in: rectangleToSearch) ?? []

            var closestAttributes: UICollectionViewLayoutAttributes?
            var smallestDistance = CGFloat.greatestFiniteMagnitude

            for attributes in attributesArray {
                guard attributes.isHidden == false
                        && attributes.alpha > 0
                        && attributes.representedElementCategory == .cell
                        && collectionView!.shouldSelectItemAtIndexPath(attributes.indexPath)
                else {
                    continue
                }

                let distance: CGFloat

                switch (direction, step) {
                case (.up, .closest):
                    distance = centreOfOldSelection.y - attributes.center.y
                case (.down , .end):
                    distance = contentSize.height - attributes.center.y

                case (.down, .closest):
                    distance = attributes.center.y - centreOfOldSelection.y
                case (.up , .end):
                    distance = attributes.center.y - 0

                case (.left, .closest):
                    distance = centreOfOldSelection.x - attributes.center.x
                case (.right , .end):
                    distance = contentSize.width - attributes.center.x

                case (.right, .closest):
                    distance = attributes.center.x - centreOfOldSelection.x
                case (.left , .end):
                    distance = attributes.center.x
                }

                // The index path is a deterministic tie-breaker.
                if distance > 0 && (distance < smallestDistance || distance == smallestDistance && attributes.indexPath < closestAttributes!.indexPath) {
                    closestAttributes = attributes
                    smallestDistance = distance
                }
            }

            return closestAttributes?.indexPath
        }

        // First search some small distance along. Likely to find something. Feels like it might be faster than searching a long way from the start. Haven’t tested the performance; it depends so much on the layout anyway.
        if let newIndexPath = indexPathBySearchingWithOffset(0, distance: 500) {
            return newIndexPath
        }

        // Search further if finding nothing. Give up if the next item is further than 3000 points away.
        return indexPathBySearchingWithOffset(500, distance: 2500)
    }
}

private extension UICollectionViewFlowLayout {

    override func kbd_indexPathFromIndexPath(_ indexPath: IndexPath?, inDirection rawDirection: Int, step rawStep: Int) -> IndexPath? {
        let direction = NavigationDirection(rawValue: rawDirection)!

        enum UpdateBehaviour {
            case spatial
            case forwards
            case backwards
        }

        var updateBehaviour: UpdateBehaviour {
            switch (scrollDirection, direction) {
            case (.horizontal, .up):
                return .backwards
            case (.horizontal, .down):
                return .forwards
            case (.vertical, .left):
                return collectionView!.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .forwards : .backwards
            case (.vertical, .right):
                return collectionView!.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .backwards : .forwards
            case (.vertical, .up), (.vertical, .down), (.horizontal, .left), (.horizontal, .right):
                return .spatial
            case (_, _):
                // This is the unknown default if a new scroll direction is added!? Whatever. Let’s go with spatial.
                return .spatial
            }
        }

        switch (updateBehaviour, NavigationStep(rawValue: rawStep)!) {

        case (.spatial, _), (_, .end):
            return super.kbd_indexPathFromIndexPath(indexPath, inDirection: rawDirection, step: rawStep)

        case (.backwards, .closest):
            // Select the first highlightable item before the current selection, or select the last highlightable
            // item if there is no current selection or if the current selection is the first highlightable item.
            if let indexPath = indexPath, let target = collectionView!.selectableIndexPathBeforeIndexPath(indexPath) {
                return target
            } else {
                return collectionView!.lastSelectableIndexPath
            }

        case (.forwards, .closest):
            // Select the first highlightable item after the current selection, or select the first highlightable
            // item if there is no current selection or if the current selection is the last highlightable item.
            if let oldSelection = indexPath, let target = collectionView!.selectableIndexPathAfterIndexPath(oldSelection) {
                return target
            } else {
                return collectionView!.firstSelectableIndexPath
            }
        }
    }
}
