//
//  ABPhotosOverlayView.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit

// A view that overlays an `ABPhotosViewController`, and houses the left and right bar button items, a title, and a caption view.

class ABPhotosOverlayView : UIView {
    var navigationItem: UINavigationItem?

    // The internal navigation bar used to set the bar button items and title of the overlay.
    var navigationBar: UINavigationBar!

    // The title of the overlay. Centered between the left and right bar button items.
    var title: String? {
        get {
            return self.navigationItem!.title
        }
        
        set {
            self.navigationItem?.title = newValue
        }
    }

    // The attributes of the overlay's title.
    var titleTextAttributes: [String : AnyObject]? {
        get {
            return self.navigationBar!.titleTextAttributes
        }
        
        set {
            self.navigationBar!.titleTextAttributes = newValue
        }
    }

    // The bar button item appearing at the top left of the overlay.
    var leftBarButtonItem: UIBarButtonItem? {
        get {
            return self.navigationItem!.leftBarButtonItem
        }
        
        set {
            self.navigationItem?.setLeftBarButtonItem(newValue, animated: false)
        }
    }

    // The bar button items appearing at the top left of the overlay.
    var leftBarButtonItems: [UIBarButtonItem] {
        get {
            return self.navigationItem!.leftBarButtonItems!
        }
        
        set {
            self.navigationItem?.setLeftBarButtonItems(newValue, animated: false)
        }
    }

    // The bar button item appearing at the top right of the overlay.
    var rightBarButtonItem: UIBarButtonItem? {
        get {
            return self.navigationItem!.rightBarButtonItem
        }
        
        set {
            self.navigationItem?.setRightBarButtonItem(newValue, animated: false)
        }
    }

    // The bar button items appearing at the top right of the overlay.
    var rightBarButtonItems: [UIBarButtonItem] {
        get {
            return self.navigationItem!.rightBarButtonItems!
        }
        
        set {
            self.navigationItem?.setRightBarButtonItems(newValue, animated: false)
        }
    }
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNavigationBar()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, withEvent: event)
        
        if hitView == self {
            return nil
        }
        
        return hitView
    }
    
    override func layoutSubviews() {
        // The navigation bar has a different intrinsic content size upon rotation, so we must update to that new size.
        // Do it without animation to more closely match the behavior in `UINavigationController`
        
        UIView.performWithoutAnimation { () -> Void in
            self.navigationBar?.invalidateIntrinsicContentSize()
            self.navigationBar?.layoutIfNeeded()
        }
        
        super.layoutSubviews()
    }
    
    // MARK: - ABPhotosOverlayView
    
    func setupNavigationBar() {
        navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Make navigation bar background fully transparent.
        navigationBar.backgroundColor = UIColor.clearColor();
        navigationBar.barTintColor = nil;
        navigationBar.translucent = true;
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        navigationItem = UINavigationItem(title: "")
        navigationBar.items = [navigationItem!]
        
        addSubview(navigationBar)
        
        let topConstraint = NSLayoutConstraint(item: navigationBar, attribute: .Top, relatedBy:
            .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        let widthConstraint = NSLayoutConstraint(item: navigationBar, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
        
        let horizontalPositionConstraint = NSLayoutConstraint(item: navigationBar, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        
        addConstraints([topConstraint, widthConstraint, horizontalPositionConstraint])
    }
    
    
    // A view representing the caption for the photo, which will be set to full width and locked to the bottom. Can be any `UIView` object, but is expected to respond to `intrinsicContentSize` appropriately to calculate height.
    var captionView: UIView? {
        didSet {
            if captionView == oldValue {
                return
            }
            
            captionView?.removeFromSuperview()
            captionView?.translatesAutoresizingMaskIntoConstraints = false
            addSubview(self.captionView!)
            
            let bottomConstraint = NSLayoutConstraint(item: captionView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
            
            let widthConstraint = NSLayoutConstraint(item: captionView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0)
            
            let horizontalPositionConstraint = NSLayoutConstraint(item: captionView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
            
            addConstraints([bottomConstraint, widthConstraint, horizontalPositionConstraint])
        }
    }
}







































