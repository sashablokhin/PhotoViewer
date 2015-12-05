//
//  ABPhotoTransitionAnimator.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 30.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit


let ABPhotoTransitionAnimatorDurationWithZooming: CGFloat = 0.5
let ABPhotoTransitionAnimatorDurationWithoutZooming: CGFloat = 0.3
let ABPhotoTransitionAnimatorBackgroundFadeDurationRatio: CGFloat = 4.0 / 9.0
let ABPhotoTransitionAnimatorEndingViewFadeInDurationRatio: CGFloat = 0.1
let ABPhotoTransitionAnimatorStartingViewFadeOutDurationRatio: CGFloat = 0.05
let ABPhotoTransitionAnimatorSpringDamping: CGFloat = 0.9


class ABPhotoTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
 
    var startingView: UIView?
    
    /**
    *  The view from which to end an image zooming transition. This view may be hidden or shown in the transition, but will never be removed or changed in its view hierarchy.
    */
    var endingView: UIView?
    
    /**
    *  The view that is used for animating the starting view. If no view is set, the starting view is screenshotted and the relevant properties are copied to the new view.
    */
    var startingViewForAnimation: UIView?
    
    /**
    *  The view that is used for animating the ending view. If no view is set, the ending view is screenshotted and relevant properties copied to the new view.
    */
    var endingViewForAnimation: UIView?
    
    /**
    *  Whether this transition is a dismissal. If `NO`, presentation is assumed.
    */
    
    var dismissing = false
    
    var isDismissing: Bool {
        return dismissing
    }
    
    /**
    *  The duration of the animation when zooming is performed.
    */
    var animationDurationWithZooming: CGFloat
    
    /**
    *  The duration of the animation when only fading and not zooming is performed.
    */
    var animationDurationWithoutZooming: CGFloat
    
    /**
    *  The ratio (from 0.0 to 1.0) of the total animation duration that the background fade duration takes.
    */
    var animationDurationFadeRatio: CGFloat {
        didSet {
            self.animationDurationFadeRatio = min(animationDurationFadeRatio, 1.0)
        }
    }
    
    /**
    *  The ratio (from 0.0 to 1.0) of the total animation duration that the ending view fade in duration takes.
    */
    var animationDurationEndingViewFadeInRatio: CGFloat {
        didSet {
            self.animationDurationEndingViewFadeInRatio = min(animationDurationEndingViewFadeInRatio, 1.0)
        }
    }
    
    /**
    *  The ratio (from 0.0 to 1.0) of the total animation duration that the starting view fade out duration takes after the ending view fade in completes.
    */
    var animationDurationStartingViewFadeOutRatio: CGFloat {
        didSet {
            self.animationDurationStartingViewFadeOutRatio = min(animationDurationStartingViewFadeOutRatio, 1.0)
        }
    }
    
    /**
    *  The value passed as the spring damping argument to `animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:` for the zooming animation.
    */
    var zoomingAnimationSpringDamping: CGFloat
    
    /**
    *  Convenience method for creating a view for animation from another arbitrary view. Attempts to create an identical view in the most efficient way possible. Returns `nil` if the passed-in view is `nil`.
    *
    *  @param view The view from which to create the animation.
    *
    *  @return A new view identical in appearance to the passed-in view, with relevant properties transferred. Not a member of any view hierarchy. Return `nil` if the passed-in view is `nil`.
    */
    
    // MARK: - NSObject
    
    override init() {
        self.animationDurationWithZooming = ABPhotoTransitionAnimatorDurationWithZooming
        self.animationDurationWithoutZooming = ABPhotoTransitionAnimatorDurationWithoutZooming
        self.animationDurationFadeRatio = ABPhotoTransitionAnimatorBackgroundFadeDurationRatio
        self.animationDurationEndingViewFadeInRatio = ABPhotoTransitionAnimatorEndingViewFadeInDurationRatio
        self.animationDurationStartingViewFadeOutRatio = ABPhotoTransitionAnimatorStartingViewFadeOutDurationRatio
        self.zoomingAnimationSpringDamping = ABPhotoTransitionAnimatorSpringDamping
    }
    
    // MARK - ABPhotoTransitionAnimator
    
    func setupTransitionContainerHierarchyWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        let fromView: UIView? = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let toView: UIView? = transitionContext.viewForKey(UITransitionContextToViewKey)
    
        let toViewController: UIViewController? = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        toView!.frame = transitionContext.finalFrameForViewController(toViewController!)
    
        if !(toView!.isDescendantOfView(transitionContext.containerView()!)) {
            transitionContext.containerView()?.addSubview(toView!)
        }
    
        if (self.isDismissing) {
            transitionContext.containerView()?.bringSubviewToFront(fromView!)
        }
    }
    
    // MARK: - Fading
    
    func performFadeAnimationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        let fromView: UIView? = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let toView: UIView? = transitionContext.viewForKey(UITransitionContextToViewKey)
    
        var viewToFade: UIView? = toView
        var beginningAlpha: CGFloat = 0.0
        var endingAlpha: CGFloat = 1.0
    
        if (self.isDismissing) {
            viewToFade = fromView
            beginningAlpha = 1.0
            endingAlpha = 0.0
        }
    
        viewToFade!.alpha = beginningAlpha
        
        UIView.animateWithDuration(Double(self.fadeDurationForTransitionContext(transitionContext)), animations: { () -> Void in
            viewToFade!.alpha = endingAlpha
            }) { (finished) -> Void in
                if (!self.shouldPerformZoomingAnimation()) {
                    self.completeTransitionWithTransitionContext(transitionContext)
                }
        }
    }
    
    func fadeDurationForTransitionContext(transitionContext: UIViewControllerContextTransitioning) -> CGFloat {
        if (self.shouldPerformZoomingAnimation()) {
            return CGFloat(CGFloat(self.transitionDuration(transitionContext)) * self.animationDurationFadeRatio)
        }
    
        return CGFloat(self.transitionDuration(transitionContext))
    }
    
    // MARK: - Zooming
    
    func performZoomingAnimationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        let containerView: UIView? = transitionContext.containerView()
    
        // Create a brand new view with the same contents for the purposes of animating this new view and leaving the old one alone.
        
        var startingViewForAnimation: UIView? = self.startingViewForAnimation
        if (startingViewForAnimation == nil) {
            startingViewForAnimation = ABPhotoTransitionAnimator.newAnimationViewFromView(self.startingView!)
        }
    
        var endingViewForAnimation: UIView? = self.endingViewForAnimation
        if (endingViewForAnimation == nil) {
            endingViewForAnimation = ABPhotoTransitionAnimator.newAnimationViewFromView(self.endingView!)
        }
    
        let finalEndingViewTransform: CGAffineTransform = self.endingView!.transform
    
        let endingViewInitialTransform: CGFloat  = CGRectGetHeight(startingViewForAnimation!.frame) / CGRectGetHeight(endingViewForAnimation!.frame)
        let translatedStartingViewCenter: CGPoint  = ABPhotoTransitionAnimator.centerPointForView(self.startingView!, translatedToContainerView: containerView!)
        
    
        startingViewForAnimation!.center = translatedStartingViewCenter
    
        endingViewForAnimation!.transform = CGAffineTransformScale(endingViewForAnimation!.transform, endingViewInitialTransform, endingViewInitialTransform)
        endingViewForAnimation!.center = translatedStartingViewCenter
        endingViewForAnimation!.alpha = 0.0
    
        transitionContext.containerView()?.addSubview(startingViewForAnimation!)
        transitionContext.containerView()?.addSubview(endingViewForAnimation!)
    
        // Hide the original ending view and starting view until the completion of the animation.
        
        self.endingView!.hidden = true
        self.startingView!.hidden = true
    
        let fadeInDuration: Double = self.transitionDuration(transitionContext) * Double(self.animationDurationEndingViewFadeInRatio)
        let fadeOutDuration: Double = self.transitionDuration(transitionContext) * Double(self.animationDurationStartingViewFadeOutRatio)
    
        // Ending view / starting view replacement animation
        
        UIView.animateWithDuration(fadeInDuration, delay: 0, options: [.AllowAnimatedContent, .BeginFromCurrentState], animations: { () -> Void in
                endingViewForAnimation!.alpha = 1.0
            }) { (finished) -> Void in
                UIView.animateWithDuration(fadeOutDuration, delay: 0, options: [.AllowAnimatedContent, .BeginFromCurrentState], animations: { () -> Void in
                        startingViewForAnimation!.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        startingViewForAnimation!.removeFromSuperview()
                })
        }
        
        let startingViewFinalTransform: CGFloat = 1.0 / endingViewInitialTransform
        let translatedEndingViewFinalCenter: CGPoint  = ABPhotoTransitionAnimator.centerPointForView(self.endingView!,
        translatedToContainerView: containerView!)
    
        // Zoom animation
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: zoomingAnimationSpringDamping, initialSpringVelocity: 0.0, options: [.AllowAnimatedContent, .BeginFromCurrentState], animations: { () -> Void in
                endingViewForAnimation!.transform = finalEndingViewTransform;
                endingViewForAnimation!.center = translatedEndingViewFinalCenter;
                startingViewForAnimation!.transform = CGAffineTransformScale(startingViewForAnimation!.transform, startingViewFinalTransform, startingViewFinalTransform);
                startingViewForAnimation!.center = translatedEndingViewFinalCenter;
            }) { (finished) -> Void in
                endingViewForAnimation!.removeFromSuperview()
                self.endingView!.hidden = false
                self.startingView!.hidden = false
                
                self.completeTransitionWithTransitionContext(transitionContext)
        }
        
    }
    
    // MARK: - Convenience
    
    func transformForOrientation(orientation: UIInterfaceOrientation) -> CGAffineTransform {
        switch (orientation) {
        case .LandscapeLeft:
            return CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
    
        case .LandscapeRight:
            return CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0))
    
        case .PortraitUpsideDown:
            return CGAffineTransformMakeRotation(CGFloat(M_PI))
    
        case .Portrait: break
        default:
            return CGAffineTransformMakeRotation(0)
        }
        
        return CGAffineTransformMakeRotation(0)
    }
    
    func shouldPerformZoomingAnimation() -> Bool {
        
        if startingView != nil && endingView != nil {
            return true
        } else {
            return false
        }
        
        //return self.startingView && self.endingView
    }
    
    func completeTransitionWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        if (transitionContext.isInteractive()) {
            if (transitionContext.transitionWasCancelled()) {
                transitionContext.cancelInteractiveTransition()
            }
            else {
                transitionContext.finishInteractiveTransition()
            }
        }
    
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
    }
    
    class func centerPointForView(view: UIView, translatedToContainerView containerView: UIView) -> CGPoint {
        var centerPoint: CGPoint = view.center
    
        // Special case for zoomed scroll views.
        
        if let scrollView = view.superview as? UIScrollView {
            if (scrollView.zoomScale != 1.0) {
                centerPoint.x += (CGRectGetWidth(scrollView.bounds) - scrollView.contentSize.width) / 2.0 + scrollView.contentOffset.x
                centerPoint.y += (CGRectGetHeight(scrollView.bounds) - scrollView.contentSize.height) / 2.0 + scrollView.contentOffset.y
            }
        }
    
        return view.superview!.convertPoint(centerPoint, toView: containerView)
    }
    
    class func newAnimationViewFromView(view: UIView?) -> UIView? {
        if (view == nil) {
            return nil
        }
    
        var animationView: UIView
    
        if (view?.layer.contents != nil) {
            animationView = UIView(frame: (view!.frame))
            animationView.layer.contents = view!.layer.contents
            animationView.layer.bounds = view!.layer.bounds
            animationView.layer.cornerRadius = view!.layer.cornerRadius
            animationView.layer.masksToBounds = view!.layer.masksToBounds
            animationView.contentMode = view!.contentMode
            animationView.transform = view!.transform
        }
        else {
            animationView = view!.snapshotViewAfterScreenUpdates(true)
        }
    
        return animationView;
    }
    
    // MARK - UIViewControllerAnimatedTransitioning
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if (self.shouldPerformZoomingAnimation()) {
            return NSTimeInterval(self.animationDurationWithZooming)
        }
    
        return NSTimeInterval(self.animationDurationWithoutZooming)
    }
    
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.setupTransitionContainerHierarchyWithTransitionContext(transitionContext)
    
        self.performFadeAnimationWithTransitionContext(transitionContext)
    
        if (self.shouldPerformZoomingAnimation()) {
            self.performZoomingAnimationWithTransitionContext(transitionContext)
        }
    }
}
























