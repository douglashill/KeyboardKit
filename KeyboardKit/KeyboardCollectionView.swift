// Douglas Hill, May 2019

import UIKit

/// A collection view that supports navigation and selection using a hardware keyboard.
open class KeyboardCollectionView: UICollectionView, ResponderChainInjection {

    private lazy var selectableCollectionKeyHandler = SelectableCollectionKeyHandler(delegate: self, owner: self)
    private lazy var scrollViewKeyHandler = ScrollViewKeyHandler(scrollView: self)

    public override var canBecomeFirstResponder: Bool {
        true
    }

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        commands += scrollViewKeyHandler.pageUpDownHomeEndScrollingCommands
        commands += scrollViewKeyHandler.refreshingCommands

        return commands
    }

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

extension UICollectionView: SelectableCollectionKeyHandlerDelegate {

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
        guard
            let oldIndexPath = indexPath,
            let attributesOfOldSelection = collectionViewLayout.layoutAttributesForItem(at: oldIndexPath)
        else {
            // TODO: Something better such as looking at all items along an edge and picking one if the index path is the first or last index path.
            return keyHandler.firstSelectableIndexPath
        }

        let rectangleOfOldSelection = attributesOfOldSelection.frame
        let centreOfOldSelection = attributesOfOldSelection.center

        // TODO: step is ignored. Just dealing with closest for now.

        // Search some small distance along.
        let rectangleToSearch: CGRect
        let distanceToSearch:  CGFloat = 500

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

        guard let attributesArray = collectionViewLayout.layoutAttributesForElements(in: rectangleToSearch), attributesArray.isEmpty == false else {
            // TODO: Search further if finding nothing.
            // TODO: Wrapping so it goes to the previous or next index path when reaching the end of a line with flow layout.
            return nil
        }

        var closestAttributes: UICollectionViewLayoutAttributes?
        var smallestDistance = CGFloat.greatestFiniteMagnitude

        for attributes in attributesArray {
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

        return closestAttributes?.indexPath
    }
}
