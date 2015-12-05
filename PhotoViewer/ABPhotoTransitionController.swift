//
//  ABPhotoTransitionController.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 30.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit


class ABPhotoTransitionController: NSObject, UIViewControllerTransitioningDelegate {
 
    var animator: ABPhotoTransitionAnimator
    var interactionController: ABPhotoDismissalInteractionController
    
    var forcesNonInteractiveDismissal = false

    // MARK: - NSObject
    
    override init() {
        animator = ABPhotoTransitionAnimator()
        interactionController = ABPhotoDismissalInteractionController()
    }
    
    
    // MARK: - ABPhotoTransitionController
    
    
    func didPanWithPanGestureRecognizer(panGestureRecognizer: UIPanGestureRecognizer, viewToPan: UIView, anchorPoint: CGPoint) {
        interactionController.didPanWithPanGestureRecognizer(panGestureRecognizer, viewToPan: viewToPan, anchorPoint: anchorPoint)
    }
    
    var startingView: UIView? {
        set {
            animator.startingView = newValue
        }
        
        get {
            return animator.startingView
        }
    }
    
    var endingView: UIView? {
        set {
            animator.endingView = newValue
        }
        
        get {
            return animator.endingView
        }
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    @objc func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.dismissing = false
        
        return animator
    }
    

    @objc func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.dismissing = true
        
        return animator
    }
    

    @objc func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if (self.forcesNonInteractiveDismissal) {
            return nil
        }
    
        // The interaction controller will be hiding the ending view, so we should get and set a visible version now.
        //self.animator.endingViewForAnimation = [[self.animator class] newAnimationViewFromView:self.endingView]
        self.animator.endingViewForAnimation = ABPhotoTransitionAnimator.newAnimationViewFromView(self.endingView)
    
        self.interactionController.animator = animator
        self.interactionController.shouldAnimateUsingAnimator = self.endingView != nil
        self.interactionController.viewToHideWhenBeginningTransition = self.startingView != nil ? self.endingView : nil
    
        return self.interactionController
    }
}






















