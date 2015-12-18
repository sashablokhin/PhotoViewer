//
//  ABPhotoViewController.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 09.12.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit


@objc protocol ABPhotoViewControllerDelegate: NSObjectProtocol {
    /**
     *  Called when a long press is recognized.
     *
     *  @param photoViewController        The `ABPhotoViewController` instance that sent the delegate message.
     *  @param longPressGestureRecognizer The long press gesture recognizer that recognized the long press.
     */
    optional func photoViewController(photoViewController: ABPhotoViewController, didLongPressWithGestureRecognizer longPressGestureRecognizer:UILongPressGestureRecognizer)
}


let ABPhotoViewControllerPhotoImageUpdatedNotification = "ABPhotoViewControllerPhotoImageUpdatedNotification"


class ABPhotoViewController: UIViewController, ABPhotoContainer, UIScrollViewDelegate {
    
    var photo: ABPhoto?
    
    var scalingImageView: ABScalingImageView?
    var loadingView: UIView?
    //var notificationCenter: NSNotificationCenter
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    // The object that acts as the photo view controller's delegate.
    var delegate: ABPhotoViewControllerDelegate?
    
    
    // MARK - NSObject
    
    deinit {
        scalingImageView!.delegate = nil
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    convenience override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.init(photo: nil, loadingView:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInitWithPhoto(nil, loadingView: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoImageUpdatedWithNotification:", name:ABPhotoViewControllerPhotoImageUpdatedNotification, object: nil)
        
        self.scalingImageView!.frame = self.view.bounds
        self.view.addSubview(self.scalingImageView!)
        
        if let loadingView = self.loadingView {
            self.view.addSubview(loadingView)
            self.loadingView!.sizeToFit()
        }
        
        self.view.addGestureRecognizer(self.doubleTapGestureRecognizer!)
        self.view.addGestureRecognizer(self.longPressGestureRecognizer!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    
        self.scalingImageView!.frame = self.view.bounds
    
        self.loadingView?.sizeToFit()
        self.loadingView?.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
    }
    
    // MARK: - ABPhotoViewController
    
    init(photo: ABPhoto?, loadingView: UIView?) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.commonInitWithPhoto(photo, loadingView: loadingView)
    }
    
    func commonInitWithPhoto(photo: ABPhoto?, loadingView: UIView?) {
        self.photo = photo
    
        let photoImage: UIImage = (photo?.image != nil ? photo!.image : photo!.placeholderImage)!
    
        scalingImageView = ABScalingImageView(image: photoImage, frame: CGRectZero)
        scalingImageView!.delegate = self
    
        if (photo?.image == nil) {
            self.setupLoadingView(loadingView)
        }
    
        self.setupGestureRecognizers()
    }
    
    func setupLoadingView(loadingView: UIView?) {
        self.loadingView = loadingView
        if (loadingView == nil) {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
            
            activityIndicator.startAnimating()
            self.loadingView = activityIndicator
        }
    }
    
    func photoImageUpdatedWithNotification(notification: NSNotification) {
        if let photo = notification.object {
            if photo.conformsToProtocol(ABPhoto) && photo.isEqual(self.photo) {
                self.updateImage((photo as! ABPhoto).image)
            }
        }
    }
    
    func updateImage(image: UIImage?) {
        self.scalingImageView!.updateImage(image)
    
        if (image != nil) {
            self.loadingView!.removeFromSuperview()
            self.loadingView = nil
        }
    }
    
    // MARK: - Gesture Recognizers
    
    func setupGestureRecognizers() {
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didDoubleTapWithGestureRecognizer:")
        self.doubleTapGestureRecognizer!.numberOfTapsRequired = 2
    
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "didLongPressWithGestureRecognizer:")
    }
    
    func didDoubleTapWithGestureRecognizer(recognizer: UITapGestureRecognizer) {
        let pointInView: CGPoint = recognizer.locationInView(self.scalingImageView!.imageView)
    
        var newZoomScale = self.scalingImageView!.maximumZoomScale
    
        if (self.scalingImageView!.zoomScale >= self.scalingImageView!.maximumZoomScale) {
            newZoomScale = self.scalingImageView!.minimumZoomScale
        }
    
        let scrollViewSize = self.scalingImageView!.bounds.size
    
        let width: CGFloat = scrollViewSize.width / newZoomScale
        let height: CGFloat = scrollViewSize.height / newZoomScale
        let originX: CGFloat = pointInView.x - (width / 2.0)
        let originY: CGFloat = pointInView.y - (height / 2.0)
    
        let rectToZoomTo: CGRect = CGRectMake(originX, originY, width, height)
    
        self.scalingImageView!.zoomToRect(rectToZoomTo, animated: true)
    }
    
    func didLongPressWithGestureRecognizer(recognizer: UILongPressGestureRecognizer) {
        if let del = self.delegate {
            if del.respondsToSelector("photoViewController:didLongPressWithGestureRecognizer:") {
                if recognizer.state == .Began {
                    self.delegate?.photoViewController!(self, didLongPressWithGestureRecognizer: recognizer)
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.scalingImageView!.imageView
    }

    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        scrollView.panGestureRecognizer.enabled = true
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.enabled = false
        }
    }
}
