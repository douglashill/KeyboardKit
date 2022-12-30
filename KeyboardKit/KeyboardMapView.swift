// Douglas Hill, March 2020

import MapKit

/// A map view that supports hardware keyboard commands to scroll and zoom.
///
/// This relies on system support that was added in iOS 15.
open class KeyboardMapView: MKMapView {

    open override var canBecomeFirstResponder: Bool {
        true
    }

    open override var canBecomeFocused: Bool {
        true
    }

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        return commands
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }

    /// Animates a modification to the camera specified by the given closure.
    private func animateCamera(withAdjustment adjustment: (MKMapCamera) -> Void) {
        let camera = self.camera.copy() as! MKMapCamera
        adjustment(camera)
        setCamera(camera, animated: true)
    }
}
