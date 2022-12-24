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
}
