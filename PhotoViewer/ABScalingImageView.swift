//
//  ABScalingImageView.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 09.12.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit

class ABScalingImageView : UIScrollView {
    
    var imageView: UIImageView?
    
    // MARK: - UIView
    
    override convenience init(frame: CGRect) {
        //[self initWithImage:nil frame:frame]
        self.init(image: nil, frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitWithImage(nil)
        //fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didAddSubview(subview: UIView) {
        super.didAddSubview(subview)
        self.centerScrollViewContents()
    }
    
    
    override var frame: CGRect {
        didSet {
            self.updateZoomScale()
            self.centerScrollViewContents()
        }
    }

    
    // MARK: - ABScalingImageView
    
    init(image: UIImage?, frame: CGRect) {
        super.init(frame: frame)
        self.commonInitWithImage(image)
    }
    
    
    func commonInitWithImage(image: UIImage?) {
        self.setupInternalImageViewWithImage(image)
        self.setupImageScrollView()
        self.updateZoomScale()
    }
    
    // MARK: - Setup
    
    func setupInternalImageViewWithImage(image: UIImage?) {
        self.imageView = UIImageView(image: image)
        self.updateImage(image)
    
        self.addSubview(self.imageView!)
    }
    
    func updateImage(image: UIImage?) {
        // Remove any transform currently applied by the scroll view zooming.
        
        self.imageView?.transform = CGAffineTransformIdentity
        self.imageView?.image = image
        
        if image != nil {
            self.imageView!.frame = CGRectMake(0, 0, image!.size.width, image!.size.height)
            self.contentSize = image!.size
        }
    
        self.updateZoomScale()
        self.centerScrollViewContents()
    }
    
    func setupImageScrollView() {
        self.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    func updateZoomScale() {
        if (self.imageView?.image != nil) {
            let scrollViewFrame = self.bounds
    
            let scaleWidth = scrollViewFrame.size.width / self.imageView!.image!.size.width
            let scaleHeight = scrollViewFrame.size.height / self.imageView!.image!.size.height
            let minScale = min(scaleWidth, scaleHeight)
    
            self.minimumZoomScale = minScale
            self.maximumZoomScale = max(minScale, self.maximumZoomScale)
    
            self.zoomScale = self.minimumZoomScale;
    
            // scrollView.panGestureRecognizer.enabled is on by default and enabled by
            // viewWillLayoutSubviews in the container controller so disable it here
            // to prevent an interference with the container controller's pan gesture.
            //
            // This is enabled in scrollViewWillBeginZooming so panning while zoomed-in
            // is unaffected.
            self.panGestureRecognizer.enabled = false
        }
    }
    
    // MARK: - Centering
    
    func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0
    
        if (self.contentSize.width < CGRectGetWidth(self.bounds)) {
            horizontalInset = (CGRectGetWidth(self.bounds) - self.contentSize.width) * 0.5
        }
    
        if (self.contentSize.height < CGRectGetHeight(self.bounds)) {
            verticalInset = (CGRectGetHeight(self.bounds) - self.contentSize.height) * 0.5
        }
    
        if (self.window?.screen.scale < 2.0) {
            horizontalInset = floor(horizontalInset)
            verticalInset = floor(verticalInset)
        }
    
        // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        self.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
    }
}


























