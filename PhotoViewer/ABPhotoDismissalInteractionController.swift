//
//  ABPhotoDismissalInteractionController.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 30.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit

let ABPhotoDismissalInteractionControllerPanDismissDistanceRatio: CGFloat = 50.0 / 667.0 // distance over iPhone 6 height.
let ABPhotoDismissalInteractionControllerPanDismissMaximumDuration: CGFloat = 0.45;
let ABPhotoDismissalInteractionControllerReturnToCenterVelocityAnimationRatio: CGFloat = 0.00007 // Arbitrary value that looked decent.

class ABPhotoDismissalInteractionController: NSObject, UIViewControllerInteractiveTransitioning {
    
    /**
    *  The animator object associated with the interactive transition.
    */
    var animator: UIViewControllerAnimatedTransitioning?
    
    /**
    *  If set, this view will be hidden as soon as the interactive transition starts, and shown after it ends.
    */
    var viewToHideWhenBeginningTransition: UIView?
    
    /**
    *  A `BOOL` determining whether, after reaching a certain panning threshold that constitutes a dismissal, the animator object should be used to finish the transition.
    */
    var shouldAnimateUsingAnimator = false
    
    var transitionContext: UIViewControllerContextTransitioning?
    
    // MARK: - ABPhotoDismissalInteractionController
    
    func didPanWithPanGestureRecognizer(panGestureRecognizer: UIPanGestureRecognizer, viewToPan: UIView, anchorPoint: CGPoint) {
        let fromView: UIView? = self.transitionContext!.viewForKey(UITransitionContextFromViewKey)
        let translatedPanGesturePoint: CGPoint = panGestureRecognizer.translationInView(fromView)
        let newCenterPoint: CGPoint = CGPointMake(anchorPoint.x, anchorPoint.y + translatedPanGesturePoint.y)
    
        // Pan the view on pace with the pan gesture.
        viewToPan.center = newCenterPoint
    
        let verticalDelta: CGFloat = newCenterPoint.y - anchorPoint.y
    
        let backgroundAlpha: CGFloat = self.backgroundAlphaForPanningWithVerticalDelta(verticalDelta)
        fromView!.backgroundColor = fromView!.backgroundColor!.colorWithAlphaComponent(backgroundAlpha)
    
        if (panGestureRecognizer.state == .Ended) {
            self.finishPanWithPanGestureRecognizer(panGestureRecognizer, verticalDelta: verticalDelta, viewToPan: viewToPan, anchorPoint: anchorPoint)
        }
    }
    
    func finishPanWithPanGestureRecognizer(panGestureRecognizer: UIPanGestureRecognizer, verticalDelta: CGFloat, viewToPan: UIView, anchorPoint:CGPoint) {
        let fromView: UIView? = self.transitionContext!.viewForKey(UITransitionContextFromViewKey)
    
        // Return to center case.
        let velocityY: CGFloat = panGestureRecognizer.velocityInView(panGestureRecognizer.view).y
    
        var animationDuration: CGFloat = (abs(velocityY) * ABPhotoDismissalInteractionControllerReturnToCenterVelocityAnimationRatio) + 0.2
        var animationCurve: UIViewAnimationOptions = .CurveEaseOut
        var finalPageViewCenterPoint: CGPoint = anchorPoint
        var finalBackgroundAlpha: CGFloat = 1.0
    
        let dismissDistance: CGFloat = ABPhotoDismissalInteractionControllerPanDismissDistanceRatio * CGRectGetHeight(fromView!.bounds)
        let isDismissing = abs(verticalDelta) > dismissDistance
    
        var didAnimateUsingAnimator = false
    
        if (isDismissing) {
            if (self.shouldAnimateUsingAnimator) {
                self.animator!.animateTransition(self.transitionContext!)
                didAnimateUsingAnimator = true
            }
            else {
                let isPositiveDelta = verticalDelta >= 0
    
                let modifier: CGFloat = isPositiveDelta ? 1 : -1
                let finalCenterY: CGFloat = CGRectGetMidY(fromView!.bounds) + modifier * CGRectGetHeight(fromView!.bounds)
                finalPageViewCenterPoint = CGPointMake(fromView!.center.x, finalCenterY)
    
                // Maintain the velocity of the pan, while easing out.
                animationDuration = abs(finalPageViewCenterPoint.y - viewToPan.center.y) / abs(velocityY)
                animationDuration = min(animationDuration, ABPhotoDismissalInteractionControllerPanDismissMaximumDuration)
    
                animationCurve = .CurveEaseOut
                finalBackgroundAlpha = 0.0
            }
        }
    
        if (!didAnimateUsingAnimator) {
            
            UIView.animateWithDuration(Double(animationDuration), delay: 0, options: animationCurve, animations: { () -> Void in
                    viewToPan.center = finalPageViewCenterPoint
                
                    fromView!.backgroundColor = fromView!.backgroundColor!.colorWithAlphaComponent(finalBackgroundAlpha)
                }, completion: { (finished) -> Void in
                    if (isDismissing) {
                        self.transitionContext!.finishInteractiveTransition()
                    }
                    else {
                        self.transitionContext!.cancelInteractiveTransition()
                        
                        if (!ABPhotoDismissalInteractionController.isRadar20070670Fixed()) {
                            self.fixCancellationStatusBarAppearanceBug()
                        }
                    }
                    
                    self.viewToHideWhenBeginningTransition!.hidden = false
                    
                    self.transitionContext!.completeTransition(isDismissing && !self.transitionContext!.transitionWasCancelled())
                    
                    self.transitionContext = nil
            })
        }
        else {
            self.transitionContext = nil
        }
    }
    
    func backgroundAlphaForPanningWithVerticalDelta(verticalDelta: CGFloat) -> CGFloat {
        let startingAlpha: CGFloat = 1.0
        let finalAlpha: CGFloat = 0.1
        let totalAvailableAlpha: CGFloat = startingAlpha - finalAlpha
    
        let maximumDelta: CGFloat = CGRectGetHeight(self.transitionContext!.viewForKey(UITransitionContextFromViewKey)!.bounds) / 2.0; // Arbitrary value.
        let deltaAsPercentageOfMaximum: CGFloat = min(abs(verticalDelta) / maximumDelta, 1.0)
    
        return startingAlpha - (deltaAsPercentageOfMaximum * totalAvailableAlpha);
    }
    
    // MARK: - Bug Fix
    
    func fixCancellationStatusBarAppearanceBug() {
        let toViewController: UIViewController? = self.transitionContext!.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController: UIViewController? = self.transitionContext!.viewControllerForKey(UITransitionContextFromViewControllerKey)
    
        let statusBarViewControllerSelectorPart1 = "_setPresentedSta"
        let statusBarViewControllerSelectorPart2 = "tusBarViewController:"
        
        let setStatusBarViewControllerSelector = NSSelectorFromString(statusBarViewControllerSelectorPart1.stringByAppendingString(statusBarViewControllerSelectorPart2))
        
        if toViewController!.respondsToSelector(setStatusBarViewControllerSelector) && fromViewController!.modalPresentationCapturesStatusBarAppearance {
            toViewController?.performSelector(setStatusBarViewControllerSelector, withObject: fromViewController)
        }
    }
    
    class func isRadar20070670Fixed() -> Bool {
        return false
    }
    
    // MARK: - UIViewControllerInteractiveTransitioning
    
    @objc func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.viewToHideWhenBeginningTransition!.hidden = true
        self.transitionContext = transitionContext;
    }
}




















