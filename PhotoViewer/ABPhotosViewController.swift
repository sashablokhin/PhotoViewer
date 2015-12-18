//
//  PhotosViewController.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit

// All notifications will have the `ABPhotosViewController` instance set as the object.
let ABPhotosViewControllerDidNavigateToPhotoNotification = "ABPhotosViewControllerDidNavigateToPhotoNotification"
let ABPhotosViewControllerWillDismissNotification = "ABPhotosViewControllerWillDismissNotification"
let ABPhotosViewControllerDidDismissNotification = "ABPhotosViewControllerDidDismissNotification"

let ABPhotosViewControllerOverlayAnimationDuration = 0.2
let ABPhotosViewControllerInterPhotoSpacing = 16.0
let ABPhotosViewControllerCloseButtinImageInsets = UIEdgeInsets(top: 3, left: 0, bottom: -3, right: 0)

@objc class ABPhotosViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ABPhotoViewControllerDelegate {
    // The pan gesture recognizer used for panning to dismiss the photo. Disable to stop the pan-to-dismiss behavior.
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    // The tap gesture recognizer used to hide the overlay, including the caption, left and right bar button items, and title, all at once. Disable to always show the overlay.
    var singleTapGestureRecognizer: UITapGestureRecognizer?
    
    // The internal page view controller used for swiping horizontally, photo to photo. Created during `viewDidLoad`.
    var pageViewController: UIPageViewController?
    
    // The object conforming to `ABPhoto` that is currently being displayed by the `pageViewController`.
    
    var transitionController: ABPhotoTransitionController?

    var currentlyDisplayedPhoto: ABPhoto? {
        return self.currentPhotoViewController().photo
    }
    
    // The overlay view displayed over photos. Created during `viewDidLoad`.
    var overlayView: ABPhotosOverlayView?
    
    /// A custom notification center to scope internal notifications to this `ABPhotosViewController` instance.
    var notificationCenter = NSNotificationCenter()
    
    var shouldHandleLongPress = false
    var overlayWasHiddenBeforeTransition = false
    
    // The left bar button item overlaying the photo.
    var leftBarButtonItem: UIBarButtonItem? {
        set {
            self.overlayView?.leftBarButtonItem = newValue
        }
        
        get {
            return self.overlayView?.leftBarButtonItem
        }
    }
    
    // The left bar button items overlaying the photo.
    var leftBarButtonItems: [UIBarButtonItem] {
        set {
            self.overlayView?.leftBarButtonItems = newValue
        }
        
        get {
            return self.overlayView!.leftBarButtonItems
        }
    }
    
    
    // The right bar button item overlaying the photo.
    var rightBarButtonItem: UIBarButtonItem? {
        set {
            self.overlayView?.rightBarButtonItem = newValue
        }
        
        get {
            return self.overlayView?.rightBarButtonItem
        }
    }
    
    // The right bar button items overlaying the photo.
    var rightBarButtonItems: [UIBarButtonItem] {
        set {
            self.overlayView?.rightBarButtonItems = newValue
        }
        
        get {
            return self.overlayView!.rightBarButtonItems
        }
    }
    
    
    // The object that acts as the delegate of the `ABPhotosViewController`.
    var delegate: ABPhotosViewControllerDelegate?
    
    var dataSource: ABPhotosViewControllerDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.blackColor()
        self.pageViewController!.view.backgroundColor = UIColor.clearColor()
        
        self.pageViewController!.view.addGestureRecognizer(self.panGestureRecognizer!)
        self.pageViewController!.view.addGestureRecognizer(self.singleTapGestureRecognizer!)
        
        self.addChildViewController(self.pageViewController!)

        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMoveToParentViewController(self)

        self.addOverlayView()   // MARK: error
        
        self.transitionController!.startingView = self.referenceViewForCurrentPhoto() // crash

        var endingView: UIView?
        if (self.currentlyDisplayedPhoto!.image != nil || self.currentlyDisplayedPhoto!.placeholderImage != nil) {
            endingView = self.currentPhotoViewController().scalingImageView!.imageView!
        }
        
        self.transitionController!.endingView = endingView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!self.overlayWasHiddenBeforeTransition) {
            self.setOverlayViewHidden(false, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.pageViewController!.view.frame = self.view.bounds
        self.overlayView!.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
    
    
    
    // MARK: - NSObject
    
    deinit {
        pageViewController!.dataSource = nil
        pageViewController!.delegate = nil
    }
    
    // MARK: - NSObject(UIResponderStandardEditActions)
    /*
    override func copy(sender: AnyObject?) {
        UIPasteboard.generalPasteboard().setData(self.currentlyDisplayedPhoto!.image, forPasteboardType: "currentImage")
    }*/
    
    
    // MARK: - UIResponder
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
 
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if (self.shouldHandleLongPress && action == "copy:" && self.currentlyDisplayedPhoto!.image != nil) {
            return true
        }
        
        return false
    }
    
    
    /* A convenience initializer that calls `initWithPhotos:initialPhoto:`, passing the first photo as the `initialPhoto` argument.
    *
    *  @param photos An array of objects conforming to the `ABPhoto` protocol.
    *
    *  @return A fully initialized object.
    */
    convenience init(photos: [ABPhoto], delegate: ABPhotosViewControllerDelegate) {
        self.init(photos: photos, initialPhoto: photos.first!, delegate: delegate)
    }
    
    /*  The designated initializer that stores the array of objects conforming to the `ABPhoto` protocol for display, along with specifying an initial photo for display.
    *
    *  @param photos An array of objects conforming to the `ABPhoto` protocol.
    *  @param initialPhoto The photo to display initially. Must be contained within the `photos` array. If `nil` or not within the `photos` array, the first photo within the `photos` array will be displayed.
    *
    *  @return A fully initialized object.
    */
    
    init(photos: [ABPhoto], initialPhoto: ABPhoto, delegate: ABPhotosViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = delegate
        
        self.commonInitWithPhotos(photos, initialPhoto: initialPhoto)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInitWithPhotos(nil, initialPhoto: nil)
        //fatalError("init(coder:) has not been implemented")
    }
    
    
    func commonInitWithPhotos(photos: [ABPhoto]?, initialPhoto: ABPhoto?) {
        dataSource = ABPhotosDataSource(withPhotos: photos)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didSingleTapWithGestureRecognizer:")
        singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didSingleTapWithGestureRecognizer:")
        
        transitionController = ABPhotoTransitionController()
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = transitionController
        self.modalPresentationCapturesStatusBarAppearance = true
        
        // iOS 7 has an issue with constraints that could evaluate to be negative, so we set the width to the margins' size.
        overlayView = ABPhotosOverlayView(frame: CGRectMake(0, 0, ABPhotoCaptionViewHorizontalMargin * 2.0, 0))
        
        overlayView!.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ABPhotoViewerCloseButtonX"), landscapeImagePhone: UIImage(named: "ABPhotoViewerCloseButtonXLandscape"), style: .Plain, target: self, action: "doneButtonTapped:")

        overlayView!.leftBarButtonItem!.imageInsets = ABPhotosViewControllerCloseButtinImageInsets
        overlayView!.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonTapped:")
        
        notificationCenter = NSNotificationCenter() //////////////////////////////??????????????????????????????????????????????????????????????
        
        self.setupPageViewControllerWithInitialPhoto(initialPhoto!)
    }
    
    
    func setupPageViewControllerWithInitialPhoto(initialPhoto: ABPhoto) {
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : ABPhotosViewControllerInterPhotoSpacing])
    
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self
    
        var initialPhotoViewController: ABPhotoViewController?
        
        if let dataSrc = self.dataSource {
            if dataSrc.containsPhoto(initialPhoto) {
                initialPhotoViewController = self.newPhotoViewControllerForPhoto(initialPhoto)!
            } else {
                initialPhotoViewController = self.newPhotoViewControllerForPhoto(self.dataSource![0]!)!
            }
        }
    
        self.setCurrentlyDisplayedViewController(initialPhotoViewController, animated: false)
    }
    
    
    
    func addOverlayView() {
        assert(self.overlayView != nil, "overlayView must be set during initialization, to provide bar button items")
    
        let textColor = self.view.tintColor != nil ? self.view.tintColor : UIColor.whiteColor()
        self.overlayView!.titleTextAttributes = [NSForegroundColorAttributeName : textColor]
    
        self.updateOverlayInformation()
        self.view.addSubview(self.overlayView!)
    
        self.setOverlayViewHidden(true, animated: false)
    }
    
    func updateOverlayInformation() {
        var displayIndex = 1
    
        let photoIndex = self.dataSource?.indexOfPhoto(currentlyDisplayedPhoto!)
        
        if (photoIndex < self.dataSource!.numberOfPhotos) {
            displayIndex = photoIndex! + 1
        }
    
        var overlayTitle: String?
        if (self.dataSource!.numberOfPhotos > 1) {
            overlayTitle = "\(displayIndex) of \(dataSource!.numberOfPhotos)"
        }
    
        self.overlayView!.title = overlayTitle
    
        var captionView: UIView?
        //if ([self.delegate respondsToSelector:@selector(photosViewController:captionViewForPhoto:)]) {
        //    captionView = [self.delegate photosViewController:self captionViewForPhoto:self.currentlyDisplayedPhoto];
        //}
        
        if let del = self.delegate {
            if del.respondsToSelector("photosViewController:captionViewForPhoto:") {
                captionView = self.delegate?.photosViewController!(self, captionViewForPhoto: currentlyDisplayedPhoto)
            }
        }
    
        if (captionView == nil) {
            captionView = ABPhotoCaptionView(attributedTitle: currentlyDisplayedPhoto!.attributedCaptionTitle, attributedSummary: currentlyDisplayedPhoto!.attributedCaptionSummary, attributedCredit: currentlyDisplayedPhoto!.attributedCaptionCredit)
        }
    
        self.overlayView!.captionView = captionView
    }
    
    func doneButtonTapped(sender: AnyObject?) {
        self.transitionController!.forcesNonInteractiveDismissal = true
        self.setOverlayViewHidden(true, animated: false)
        self.dismissAnimated(true)
    }
    
    func actionButtonTapped(sender: AnyObject?) {
        var clientDidHandle = false
        
        if let del = self.delegate {
            if del.respondsToSelector("photosViewController:handleActionButtonTappedForPhoto:") {
                clientDidHandle = self.delegate!.photosViewController!(self, handleActionButtonTappedForPhoto: currentlyDisplayedPhoto)
            }
        }
    
        if (!clientDidHandle && (self.currentlyDisplayedPhoto!.image != nil)) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [currentlyDisplayedPhoto!.image!], applicationActivities: nil)
            
            activityViewController.popoverPresentationController!.barButtonItem = sender as? UIBarButtonItem
            
            activityViewController.completionWithItemsHandler = {(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) in
                if (completed && self.delegate!.respondsToSelector("photosViewController:actionCompletedWithActivityType:")) {
                    self.delegate!.photosViewController!(self, actionCompletedWithActivityType: activityType)
                }
            }
            
    
            self.displayActivityViewController(activityViewController, animated: true)
        }
    }
    
    func displayActivityViewController(controller: UIActivityViewController, animated: Bool) {
    
        if (UI_USER_INTERFACE_IDIOM() == .Phone) {
            self.presentViewController(controller, animated: animated, completion:nil)
        }
        else {
            controller.popoverPresentationController!.barButtonItem = self.rightBarButtonItem
            self.presentViewController(controller, animated: animated, completion: nil)
        }
    }
    

    
    func displayPhoto(photo: ABPhoto, animated: Bool) {
        if !self.dataSource!.containsPhoto(photo) {
            return
        }
    
        let photoViewController: ABPhotoViewController = self.newPhotoViewControllerForPhoto(photo)!
        self.setCurrentlyDisplayedViewController(photoViewController, animated: animated)
    }
    
    func updateImageForPhoto(photo: ABPhoto) {
        //[self.notificationCenter postNotificationName:NYTPhotoViewControllerPhotoImageUpdatedNotification object:photo];
        
        NSNotificationCenter.defaultCenter().postNotificationName(ABPhotoViewControllerPhotoImageUpdatedNotification, object: photo)
    }
    
    // MARK: - Gesture Recognizers
    
    func didSingleTapWithGestureRecognizer(tapGestureRecognizer: UITapGestureRecognizer) {
        self.setOverlayViewHidden(!self.overlayView!.hidden, animated: true)
    }
    
    func didPanWithGestureRecognizer(panGestureRecognizer: UIPanGestureRecognizer) {
        if (panGestureRecognizer.state == .Began) {
            self.overlayWasHiddenBeforeTransition = self.overlayView!.hidden
            self.setOverlayViewHidden(true, animated: true)
            self.dismissAnimated(true)
        }
        else {
            self.transitionController!.didPanWithPanGestureRecognizer(panGestureRecognizer, viewToPan: self.pageViewController!.view, anchorPoint: self.boundsCenterPoint())
        }
    }
    
    func dismissAnimated(animated: Bool) {
        var startingView: UIView?
        if (self.currentlyDisplayedPhoto!.image != nil || self.currentlyDisplayedPhoto!.placeholderImage != nil) {
            startingView = self.currentPhotoViewController().scalingImageView!.imageView!
        }
    
        self.transitionController!.startingView = startingView
        self.transitionController!.endingView = self.referenceViewForCurrentPhoto()
        
        if let del = self.delegate {
            if del.respondsToSelector("photosViewControllerWillDismiss:") {
                self.delegate?.photosViewControllerWillDismiss!(self)
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ABPhotosViewControllerWillDismissNotification, object: self)
        
        self.dismissViewControllerAnimated(animated) { () -> Void in
            let isStillOnscreen = self.view.window != nil // Happens when the dismissal is canceled.
            
            if (isStillOnscreen && !self.overlayWasHiddenBeforeTransition) {
                self.setOverlayViewHidden(false, animated: true)
            }
            
            if (!isStillOnscreen) {
                if let del = self.delegate {
                    if del.respondsToSelector("photosViewControllerDidDismiss:") {
                        self.delegate?.photosViewControllerDidDismiss!(self)
                    }
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(ABPhotosViewControllerDidDismissNotification, object: self)
            }
        }
    }
    
    // MARK: - Convenience
    
    func setCurrentlyDisplayedViewController(viewController: ABPhotoContainer?, animated: Bool) {
        if (viewController == nil) {
            return
        }
        
        pageViewController!.setViewControllers([viewController as! ABPhotoViewController], direction: .Forward, animated: animated, completion: nil)
    }
    
    
    func setOverlayViewHidden(hidden: Bool, animated: Bool) {
        if (hidden == self.overlayView!.hidden) {
            return
        }
    
        if (animated) {
            self.overlayView!.hidden = false
    
            self.overlayView!.alpha = hidden ? 1.0 : 0.0
            
            UIView.animateWithDuration(ABPhotosViewControllerOverlayAnimationDuration, delay: 0.0, options: [.CurveEaseInOut, .AllowAnimatedContent, .AllowUserInteraction], animations: { () -> Void in
                    self.overlayView!.alpha = hidden ? 0.0 : 1.0
                }, completion: { (finished) -> Void in
                    self.overlayView!.alpha = 1.0
                    self.overlayView!.hidden = hidden
            })
            
        }
        else {
            self.overlayView!.hidden = hidden
        }
    }
    
    func newPhotoViewControllerForPhoto(photo: ABPhoto?) -> ABPhotoViewController? {
        if (photo != nil) {
            var loadingView: UIView?
            
            if let del = self.delegate {
                
                if del.respondsToSelector("photosViewController:loadingViewForPhoto:") {
                    
                    loadingView = self.delegate!.photosViewController!(self, loadingViewForPhoto: photo)
                }
            }
            
            let photoViewController = ABPhotoViewController.init(photo: photo, loadingView: loadingView)
            
            photoViewController.delegate = self
            
            singleTapGestureRecognizer?.requireGestureRecognizerToFail(photoViewController.doubleTapGestureRecognizer!)
            
            if let del = self.delegate {
                if del.respondsToSelector("photosViewController:maximumZoomScaleForPhoto:") {
                    let maximumZoomScale = self.delegate!.photosViewController!(self, maximumZoomScaleForPhoto: photo)
                    photoViewController.scalingImageView!.maximumZoomScale = maximumZoomScale
                }
            }
    
            return photoViewController
        }
    
        return nil
    }
    
    func didNavigateToPhoto(photo: ABPhoto) {
        if let del = self.delegate {
            if del.respondsToSelector("photosViewController:didNavigateToPhoto:atIndex:") {
                self.delegate!.photosViewController!(self, didNavigateToPhoto: photo, atIndex: UInt(self.dataSource!.indexOfPhoto(photo)!))
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ABPhotosViewControllerDidNavigateToPhotoNotification, object: self)
    }

    
    func currentPhotoViewController() -> ABPhotoViewController {
        return self.pageViewController!.viewControllers?.first as! ABPhotoViewController//firstObject
    }
    
    func referenceViewForCurrentPhoto() -> UIView? {
        if let del = self.delegate {
            if del.respondsToSelector("photosViewController:referenceViewForPhoto:") {
                return self.delegate!.photosViewController!(self, referenceViewForPhoto: self.currentlyDisplayedPhoto)
            }
        }
    
        return nil
    }
    
    func boundsCenterPoint() -> CGPoint {
        return CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    }
    
    // MARK: - ABPhotoViewControllerDelegate
    
    func photoViewController(photoViewController: ABPhotoViewController, didLongPressWithGestureRecognizer longPressGestureRecognizer:UILongPressGestureRecognizer) {
        self.shouldHandleLongPress = false
        
        var clientDidHandle = false
        
        if let del = self.delegate {
            if del.respondsToSelector("photosViewController:handleLongPressForPhoto:withGestureRecognizer:") {
                clientDidHandle = self.delegate!.photosViewController!(self, handleLongPressForPhoto: photoViewController.photo, withGestureRecognizer:longPressGestureRecognizer)
            }
        }
        
        self.shouldHandleLongPress = !clientDidHandle;
        
        if (self.shouldHandleLongPress) {
            let menuController = UIMenuController.sharedMenuController()
            var targetRect = CGRectZero
            targetRect.origin = longPressGestureRecognizer.locationInView(longPressGestureRecognizer.view)
            menuController.setTargetRect(targetRect, inView: longPressGestureRecognizer.view!)
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let photoIndex: Int = self.dataSource!.indexOfPhoto((viewController as! ABPhotoViewController).photo!)!
        return newPhotoViewControllerForPhoto(self.dataSource![photoIndex - 1])
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let photoIndex: Int = self.dataSource!.indexOfPhoto((viewController as! ABPhotoViewController).photo!)!
        return newPhotoViewControllerForPhoto(self.dataSource![photoIndex + 1])
    }
    
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed) {
            self.updateOverlayInformation()
            
            //UIViewController <NYTPhotoContainer> *photoViewController = pageViewController.viewControllers.firstObject;
            //[self didNavigateToPhoto:photoViewController.photo];
            
            let photoViewController = pageViewController.viewControllers?.first as! ABPhotoViewController
            didNavigateToPhoto(photoViewController.photo!)
        }
    }
}
















