// Douglas Hill, December 2019

import QuartzCore

/// Animates a `CGPoint` value over time. The animation can be redirected while active,
/// and this will be smooth by ensuring the position and velocity do not change suddenly.
///
/// Animations takes place in three phases:
///
/// 1. Linear change in velocity from any initial velocity from previous animations to a certain ‘middle’ velocity.
///    (Constant acceleration, although it might be deceleration if the initial velocity was already in the target direction.)
/// 2. Constant velocity. (The middle velocity.)
/// 3. Linear decay in velocity from the middle velocity to zero velocity. (Constant deceleration.)
///
/// Calling `startAnimation` while an existing animation is supported and encouraged. Don’t call `cancelAnimation`
/// before starting the new animation because that will mean the velocity transition won’t be smooth.
class PointAnimator {
    /// The display link for callbacks at the screen refresh interval.
    private let displayLink: CADisplayLink

    /// Break the retain cycle due to `CADisplayLink` retaining its target.
    private let retainCycleBreaker: RetainCycleBreaker

    private class RetainCycleBreaker {
        unowned var owner: PointAnimator?

        @objc func updateFromDisplayLink(_ displayLink: CADisplayLink) {
            owner?.updateFromDisplayLink(displayLink)
        }
    }

    init() {
        retainCycleBreaker = RetainCycleBreaker()
        displayLink = CADisplayLink(target: retainCycleBreaker, selector: #selector(RetainCycleBreaker.updateFromDisplayLink(_:)))

        retainCycleBreaker.owner = self
        displayLink.isPaused = true
        displayLink.add(to: .main, forMode: .default)
    }

    deinit {
        displayLink.invalidate()
    }

    private func updateFromDisplayLink(_ displayLink: CADisplayLink) {
        let (currentPoint, isComplete) = pointForTime(CGFloat(displayLink.targetTimestamp))

        stepCallback?(currentPoint)

        if isComplete {
            stopAnimation(isFinished: true)
        }
    }

    private func pointForTime(_ absoluteTime: CGFloat) -> (CGPoint, isComplete: Bool) {
        let parameters = currentAnimationParameters!

        // t is sometimes slightly negative when doing lots of short finger scrolling while also tapping arrow keys fast, so apply a limit of zero.
        let t = max(absoluteTime - parameters.startTime, 0)

        guard t < parameters.duration else {
            return (currentAnimationParameters!.endPoint, true)
        }

        let t1 = parameters.offsetToEndOfPhase1
        let t2 = parameters.offsetToEndOfPhase2
        let tf = parameters.duration
        let v0 = parameters.startVelocity
        let vm = parameters.middleVelocity

        // These three functions expect time relative to the start.
        /// The phase where the animation transitions linearly from `startVelocity` to `middleVelocity`.
        func displacementInFirstPhaseForTime(_ t: CGFloat) -> CGPoint {
            precondition(t <= t1)
            return v0 * t + 0.5 * (vm - v0) * t * t / t1
        }
        /// The phase where the animation has a constant velocity of `middleVelocity`.
        func displacementInSecondPhaseForTime(_ t: CGFloat) -> CGPoint {
            precondition(t >= t1)
            precondition(t <= t2)
            return displacementInFirstPhaseForTime(t1) + vm * (t - t1)
        }
        /// The phase where the animation transitions linearly from `middleVelocity` to zero velocity.
        func displacementInThirdPhaseForTime(_ t: CGFloat) -> CGPoint {
            precondition(t >= t2)
            return displacementInSecondPhaseForTime(t2) + 0.5 * vm * (1 + (tf - t) / (tf - t2)) * (t - t2)
        }

        if t <= t1 {
            return (parameters.startPoint + displacementInFirstPhaseForTime(t), false)
        } else if t <= t2 {
            return (parameters.startPoint + displacementInSecondPhaseForTime(t), false)
        } else {
            return (parameters.startPoint + displacementInThirdPhaseForTime(t), false)
        }
    }

    private func velocityForTime(_ absoluteTime: CGFloat) -> CGPoint {
        guard let parameters = currentAnimationParameters else {
            return .zero
        }

        let t = max(absoluteTime - parameters.startTime, 0)

        let t1 = parameters.offsetToEndOfPhase1
        let t2 = parameters.offsetToEndOfPhase2
        let tf = parameters.duration
        let v0 = parameters.startVelocity
        let vm = parameters.middleVelocity

        if t <= t1 {
            return v0 + (vm - v0) * t / t1
        } else if t <= t2 {
            return vm
        } else if t <= tf {
            return vm * (1 - (t - t2) / (tf - t2))
        } else {
            return .zero
        }
    }

    func startAnimation(fromPoint startPoint: CGPoint, toPoint targetPoint: CGPoint) {
        // Could be tweaked. Maybe look at the duration UIScrollView uses and try to match that.
        // Perhaps go a bit faster for short distances and a bit slower for longer distances.
        let distance = sqrt(pow(targetPoint.x - startPoint.x, 2) + pow(targetPoint.y - startPoint.y, 2))
        let durationLimitForInfiniteDistance: CGFloat = 0.4
        let duration = durationLimitForInfiniteDistance * (1 - 1 / (log(distance + 2.8)))

        let now = CGFloat(CACurrentMediaTime())

        currentAnimationParameters = AnimationParameters(
            startTime: now,
            offsetToEndOfPhase1: 0.2 * duration,
            offsetToEndOfPhase2: 0.6 * duration,
            duration: duration,
            startPoint: startPoint,
            endPoint: targetPoint,
            startVelocity: velocityForTime(now)
        )

        if displayLink.isPaused {
            displayLink.isPaused = false
        } else {
            // Previous animation has ended because we are starting a new animation.
            endCallback?(false)
        }
    }

    /// Stops the current animation early and calls the `endCallback`.
    /// Does nothing if no animation is active.
    func cancelAnimation() {
        // Important to not call the endCallback if no animation is active.
        if displayLink.isPaused {
            return
        }

        stopAnimation(isFinished: false)
    }

    /// Stops the current animation and calls the `endCallback`.
    /// Does nothing if no animation is active.
    /// - Parameter isFinished: true if the animation reached its target or false if the animation was cancelled.
    private func stopAnimation(isFinished: Bool) {
        if displayLink.isPaused {
            // Must have just been cancelled externally. Ignore this then.
            return
        }

        displayLink.isPaused = true
        currentAnimationParameters = nil

        endCallback?(isFinished)
    }

    /// The point the animator is heading towards. Nil when no animation is taking place.
    var targetPoint: CGPoint? {
        return currentAnimationParameters?.endPoint
    }

    /// Called on each step of the animation (every frame) with the current point.
    var stepCallback: ((CGPoint) -> Void)?

    /// Called when animation ends or is redirected. Balances calls to `startAnimation`.
    /// This is also called when calling `stopAnimation` externally.
    /// The parameter is whether the animation reached its target or was cancelled early.
    var endCallback: ((Bool) -> Void)?

    private var currentAnimationParameters: AnimationParameters?

    private struct AnimationParameters {
        /// The start time of the animation. This is an absolute time. The other times are relative to this.
        let startTime: CGFloat
        /// The time from when the animation starts to when it reaches the stable velocity used in the middle of the animation.
        let offsetToEndOfPhase1: CGFloat
        /// The time from when the animation starts to when it starts decelerating to come to rest. (End of having a stable velocity.)
        let offsetToEndOfPhase2: CGFloat
        /// The time from when the animation starts to when it comes to rest.
        let duration: CGFloat

        /// The point at which the animation starts from.
        let startPoint: CGPoint
        /// The target point at which the animation aims to end (unless interrupted).
        let endPoint: CGPoint

        /// The velocity in points per second when the animation started.
        let startVelocity: CGPoint

        /// Absolute time at which the animation aims to end (unless interrupted).
        var endTime: CGFloat {
            startTime + duration
        }

        // The change in displacement of the point over the course of the animation.
        var positionChange: CGPoint {
            endPoint - startPoint
        }

        // The velocity of the animation in the middle, after it ramps up and before it ramps down.
        // This is calculated so that the animation reaches at `endPoint` with zero velocity at `endTime`.
        var middleVelocity: CGPoint {
            let top = 2 * positionChange - startVelocity * offsetToEndOfPhase1
            let bottom = duration + offsetToEndOfPhase2 - offsetToEndOfPhase1
            return top / bottom
        }
    }
}

// MARK: - Point operations

private func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

private func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

private func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

private func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
}

private func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}
