// Douglas Hill, August 2024

import UIKit

/// Works around an issue with Swift 6 language mode where a direct subclass of `UIViewController`
/// can’t have a parameterless initialiser.
///
/// If you try to have a parameterless initialiser, you’ll get one of two warnings:
///
/// > Call to main actor-isolated initializer `init(nibName:bundle:)` in a synchronous nonisolated context
///
/// or:
///
/// > Main actor-isolated initializer `init()` has different actor isolation from nonisolated overridden declaration
///
/// Usage: Instead of subclassing `UIViewController` directly, subclass this class then in `init` call `super.init(onMainActor: ())`.
class InitialiserClearingViewController: UIViewController {
    init(onMainActor: Void) {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { preconditionFailure() }
}
