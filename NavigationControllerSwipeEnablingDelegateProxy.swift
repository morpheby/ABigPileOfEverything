
import UIKit

class NavigationControllerSwipeEnablingDelegateProxy: NSObject, UIGestureRecognizerDelegate {
    weak var parent: UIGestureRecognizerDelegate?

    init(parent delegate: UIGestureRecognizerDelegate?) {
        parent = delegate
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let parent = parent,
            let result = parent.gestureRecognizerShouldBegin?(gestureRecognizer) {
            return result
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let parent = parent,
            let result = parent.gestureRecognizer?(gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer) {
            return result
        }
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        if let parent = parent,
            let result = parent.gestureRecognizer?(gestureRecognizer, shouldReceive: press) {
            return result
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Overriding here to enable gesture recognizer (navigation controller returns false)
        return true
        // if let parent = parent,
        //     let result = parent.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) {
        //     return result
        // }
        // return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let parent = parent,
            let result = parent.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return result
        }
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let parent = parent,
            let result = parent.gestureRecognizer?(gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer) {
            return result
        }
        return false
    }
}
