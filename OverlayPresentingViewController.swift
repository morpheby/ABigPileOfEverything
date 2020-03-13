
import UIKit

class OverlayPresentingViewController: UIViewController {

    fileprivate var performingInteractiveAnimation: Bool = false
    fileprivate let interactiveAnimationController = UIPercentDrivenInteractiveTransition()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc
    private func _overlayPresentingViewController_outsideOverlayTap(_ sender: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @objc
    private func _overlayPresentingViewController_overlaySwipeDown(_ sender: UIPanGestureRecognizer) {
        let distance = sender.translation(in: view)
        let currentPoint = sender.location(in: view)
        let velocity = sender.velocity(in: view)
        let totalDistance = Double(view.frame.height / 2.0)
        let centralPoint = Double(view.frame.height / 2.0)
        let weightedMaxPoint = Double(centralPoint + totalDistance / 2.0)

        let currentY = currentPoint.y
        let initialY = Double(currentY - distance.y)

        let pvalueFunction: (Double) -> Double = { x in
            // Defines a dynamic factor such that:
            // p_q(t) == 0, p_l(w) == p_q(w), p_l'(w) == p_q'(w),
            // where p_l(x) is a factor from 0.0 to 1.0 showing relative progression of the view when
            // dragged from its initial position to the end,
            // p_q is a quadratic function to smooth out the drag when initial position is above the target,
            // t is a drag starting point,
            // w is a position where the transition should become equal
            // Script to generate (MATLAB):
            // syms x0 d a b c t x
            // y0(x)=(x-d)/d
            // y1(x)=a*x^2+b*x+c
            // y1p=diff(y1)
            // y0p=diff(y0)
            // A=solve(y1(t)==0,y0(x0)==y1(x0),y0p(x0)==y1p(x0),a,b,c)
            // y2=subs(y1, [a, b, c], [A.a, A.b, A.c])
            // simplify(y2)

            if x <= initialY {
                return 0.0
            } else if initialY >= centralPoint {
                return (x - initialY)/totalDistance
            } else if x >= weightedMaxPoint {
                return (x - totalDistance)/totalDistance
            } else {
                let fact1 = totalDistance*pow(initialY - weightedMaxPoint, 2)
                let fact2 = pow(weightedMaxPoint, 2) - 2*totalDistance*weightedMaxPoint + totalDistance*initialY + totalDistance*x - initialY*x
                return (x - initialY)*fact2/fact1
            }
        }

        let progressValue = pvalueFunction(Double(currentY))

        switch sender.state {
        case .began:
            performingInteractiveAnimation = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactiveAnimationController.update(CGFloat(progressValue))
        case .ended:
            if pvalueFunction(Double(velocity.y*2 + currentY)) > 0.5 {
                interactiveAnimationController.finish()
            } else {
                interactiveAnimationController.cancel()
            }
        case .cancelled:
            interactiveAnimationController.cancel()
        default:
            break
        }
    }

    class OverlaySwipeInteractionController: UIPercentDrivenInteractiveTransition {
    }

    class OverlayPresentationController: UIPresentationController {

        var transparentBackgroundView = UIView(frame: .zero)
        let tapGestureRecognizer: UITapGestureRecognizer
        let swipeGestureRecognizer: UIPanGestureRecognizer
        let swipeGestureRecognizer2: UIPanGestureRecognizer
        let parentViewController: UIViewController

        required init(presented presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, parent parentViewController: UIViewController) {
            self.parentViewController = parentViewController
            tapGestureRecognizer = UITapGestureRecognizer(target: parentViewController, action: #selector(_overlayPresentingViewController_outsideOverlayTap(_:)))
            swipeGestureRecognizer = UIPanGestureRecognizer(target: parentViewController, action: #selector(_overlayPresentingViewController_overlaySwipeDown(_:)))
            swipeGestureRecognizer2 = UIPanGestureRecognizer(target: parentViewController, action: #selector(_overlayPresentingViewController_overlaySwipeDown(_:)))

            super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

            configure()
        }

        private func configure() {
            swipeGestureRecognizer.maximumNumberOfTouches = 1
            swipeGestureRecognizer2.maximumNumberOfTouches = 1

            transparentBackgroundView.backgroundColor = .black
            transparentBackgroundView.alpha = 0.5
            transparentBackgroundView.addGestureRecognizer(tapGestureRecognizer)

            // Disabled swipe gesture (interactive)
            // transparentBackgroundView.addGestureRecognizer(swipeGestureRecognizer)
        }

        override func presentationTransitionWillBegin() {
            guard let containerView = containerView,
                let presentedView = presentedViewController.view else {
                return
            }

            transparentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(transparentBackgroundView)

            if let headerProviding = presentedViewController as? HeaderBarViewProviding {
                // Disabled swipe gesture (interactive)
                // headerProviding.headerBarView.addGestureRecognizer(swipeGestureRecognizer2)
            }

            transparentBackgroundView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            transparentBackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            transparentBackgroundView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            transparentBackgroundView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true

            guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
                return
            }

            transparentBackgroundView.alpha = 0.0

            transitionCoordinator.animateAlongsideTransition(in: containerView, animation: { (_) in
                self.transparentBackgroundView.alpha = 0.7
            }) { (_) in
            }
        }

        override func presentationTransitionDidEnd(_ completed: Bool) {
            if !completed {
                transparentBackgroundView.removeFromSuperview()
            }
        }

        override func dismissalTransitionWillBegin() {
            guard let containerView = containerView,
                let presentedView = presentedViewController.view else {
                    return
            }

            guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
                return
            }

            transitionCoordinator.animateAlongsideTransition(in: containerView, animation: { (_) in
                self.transparentBackgroundView.alpha = 0.0
            }) { (_) in
            }
        }

        override func dismissalTransitionDidEnd(_ completed: Bool) {
            if completed {
                transparentBackgroundView.removeFromSuperview()
            }
        }

        override var shouldPresentInFullscreen: Bool {
            return false
        }

        override var frameOfPresentedViewInContainerView: CGRect {
            guard let containerView = containerView else {
                return super.frameOfPresentedViewInContainerView
            }
            return CGRect(x: containerView.frame.x, y: containerView.frame.y + containerView.frame.height / 2.0,
                          width: containerView.frame.width, height: containerView.frame.height / 2.0)
        }
    }

    class OverlayAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

        let interactive: Bool
        var savedInitialFrame: CGRect = .zero
        var savedView: UIView?

        init(interactive: Bool) {
            self.interactive = interactive
            super.init()
        }

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.3
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView
            let presentedView = transitionContext.view(forKey: .from)!

            let initialFrame = transitionContext.initialFrame(for: transitionContext.viewController(forKey: .from)!)
            var targetFrame = initialFrame
            targetFrame.y = containerView.frame.height

            savedInitialFrame = initialFrame
            savedView = presentedView

            containerView.addSubview(presentedView)

            UIView.animate(withDuration: 0.3, delay: 0.0,
                           options: interactive ? .curveLinear : .curveEaseInOut,
                           animations: {
                presentedView.frame = targetFrame
                presentedView.layoutIfNeeded()
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }

        func animationEnded(_ transitionCompleted: Bool) {
        }
    }
}

extension OverlayPresentingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension OverlayPresentingViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return OverlayPresentationController(presented: presented, presenting: presenting, parent: self)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayAnimationController(interactive: performingInteractiveAnimation)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if performingInteractiveAnimation {
            return interactiveAnimationController
        } else {
            return nil
        }
    }
}
