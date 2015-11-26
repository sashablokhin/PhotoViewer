//
//  PhotosViewController.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit

@objc class ABPhotosViewController: UIViewController {
    // The pan gesture recognizer used for panning to dismiss the photo. Disable to stop the pan-to-dismiss behavior.
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    // The tap gesture recognizer used to hide the overlay, including the caption, left and right bar button items, and title, all at once. Disable to always show the overlay.
    var singleTapGestureRecognizer: UITapGestureRecognizer?
    
    // The internal page view controller used for swiping horizontally, photo to photo. Created during `viewDidLoad`.
    var pageViewController: UIPageViewController?
    
    // The object conforming to `NYTPhoto` that is currently being displayed by the `pageViewController`.

    var currentlyDisplayedPhoto: ABPhoto?
    
    // The overlay view displayed over photos. Created during `viewDidLoad`.
    // var overlayView: ABPhotosOverlayView
    
    // The left bar button item overlaying the photo.
    var leftBarButtonItem: UIBarButtonItem?
    
    // The left bar button items overlaying the photo.
    var leftBarButtonItems = [UIBarButtonItem]()
    
    // The right bar button item overlaying the photo.
    var rightBarButtonItem: UIBarButtonItem?
    
    // The right bar button items overlaying the photo.
    var rightBarButtonItems = [UIBarButtonItem]()
    
    // The object that acts as the delegate of the `ABPhotosViewController`.
    var delegate: ABPhotosViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /* A convenience initializer that calls `initWithPhotos:initialPhoto:`, passing the first photo as the `initialPhoto` argument.
    *
    *  @param photos An array of objects conforming to the `ABPhoto` protocol.
    *
    *  @return A fully initialized object.
    */
    func initWithPhotos(photos: [ABPhoto]) -> ABPhotosViewController {
        return ABPhotosViewController()
    }
    
    /*  The designated initializer that stores the array of objects conforming to the `ABPhoto` protocol for display, along with specifying an initial photo for display.
    *
    *  @param photos An array of objects conforming to the `ABPhoto` protocol.
    *  @param initialPhoto The photo to display initially. Must be contained within the `photos` array. If `nil` or not within the `photos` array, the first photo within the `photos` array will be displayed.
    *
    *  @return A fully initialized object.
    */
    func initWithPhotos(photos: [ABPhoto], initialPhoto: ABPhoto) -> ABPhotosViewController {
        return ABPhotosViewController()
    }
    
    /*  Displays the specified photo. Can be called before the view controller is displayed. Calling with a photo not contained within the data source has no effect.
    *
    *  @param photo    The photo to make the currently displayed photo.
    *  @param animated Whether to animate the transition to the new photo.
    */
    func displayPhoto(photo: ABPhoto, animated: Bool) {
        
    }
    
    /*  Update the image displayed for the given photo object.
    *
    *  @param photo The photo for which to display the new image.
    */
    func updateImageForPhoto(photo: ABPhoto) {
        
    }
}
















