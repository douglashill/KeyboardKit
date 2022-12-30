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

    /// A key command that sets the heading of a map so north is at the top.
    ///
    /// Title: Snap to North
    ///
    /// Input: ⇧⌘↑
    ///
    /// Recommended location in main menu: View
    public static let resetHeadingKeyCommand = DiscoverableKeyCommand(([.shift, .command], .upArrow), action: #selector(kbd_resetHeading), title: "Snap to North")

    /// A key command that shows the user’s current location on a map.
    ///
    /// Title: Go to Current Location
    ///
    /// Input: ⌘L
    ///
    /// Recommended location in main menu: View
    public static let goToUserLocationKeyCommand = DiscoverableKeyCommand((.command, "l"), action: #selector(kbd_goToUserLocation), title: "Go to Current Location")

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if Self.resetHeadingKeyCommand.shouldBeIncludedInResponderChainKeyCommands && canResetHeading {
            commands.append(Self.resetHeadingKeyCommand)
        }

        if Self.goToUserLocationKeyCommand.shouldBeIncludedInResponderChainKeyCommands && canGoToUserLocation {
            commands.append(Self.goToUserLocationKeyCommand)
        }

        return commands
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(kbd_resetHeading):
            return canResetHeading
        case #selector(kbd_goToUserLocation):
            return canGoToUserLocation
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }

    private var canResetHeading: Bool {
        isRotateEnabled
    }

    @objc private func kbd_resetHeading(_ sender: UIKeyCommand) {
        animateCamera {
            $0.heading = 0
        }
    }

    private var canGoToUserLocation: Bool {
        showsUserLocation && userLocation.location != nil
    }

    @objc func kbd_goToUserLocation(_ sender: UIKeyCommand) {
        guard let target = userLocation.location else {
            return
        }

        animateCamera {
            $0.centerCoordinate = target.coordinate
        }
    }

    /// Animates a modification to the camera specified by the given closure.
    private func animateCamera(withAdjustment adjustment: (MKMapCamera) -> Void) {
        let camera = self.camera.copy() as! MKMapCamera
        adjustment(camera)
        setCamera(camera, animated: true)
    }
}
