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
let ABPhotosViewControllerWillDismissNotification = "NYTPhotosViewControllerWillDismissNotification"
let ABPhotosViewControllerDidDismissNotification = "NYTPhotosViewControllerDidDismissNotification"

let ABPhotosViewControllerOverlayAnimationDuration = 0.2;
let ABPhotosViewControllerInterPhotoSpacing = 16.0;
let ABPhotosViewControllerCloseButtinImageInsets = UIEdgeInsets(top: 3, left: 0, bottom: -3, right: 0)

@objc class ABPhotosViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ABPhotosViewControllerDelegate {
    // The pan gesture recognizer used for panning to dismiss the photo. Disable to stop the pan-to-dismiss behavior.
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    // The tap gesture recognizer used to hide the overlay, including the caption, left and right bar button items, and title, all at once. Disable to always show the overlay.
    var singleTapGestureRecognizer: UITapGestureRecognizer?
    
    // The internal page view controller used for swiping horizontally, photo to photo. Created during `viewDidLoad`.
    var pageViewController: UIPageViewController?
    
    // The object conforming to `ABPhoto` that is currently being displayed by the `pageViewController`.
    
    var transitionController: ABPhotoTransitionController?


    var currentlyDisplayedPhoto: ABPhoto?
    
    // The overlay view displayed over photos. Created during `viewDidLoad`.
    var overlayView: ABPhotosOverlayView?
    
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
    
    var dataSource: ABPhotosViewControllerDataSource?

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
    convenience init(withPhotos photos: [ABPhoto]) {
        self.init(withPhotos: photos, initialPhoto: photos.first!)
    }
    
    /*  The designated initializer that stores the array of objects conforming to the `ABPhoto` protocol for display, along with specifying an initial photo for display.
    *
    *  @param photos An array of objects conforming to the `ABPhoto` protocol.
    *  @param initialPhoto The photo to display initially. Must be contained within the `photos` array. If `nil` or not within the `photos` array, the first photo within the `photos` array will be displayed.
    *
    *  @return A fully initialized object.
    */
    /*
    func initWithPhotos(photos: [ABPhoto], initialPhoto: ABPhoto) -> ABPhotosViewController {
        //return ABPhotosViewController()
        
        /*
        self = [super initWithNibName:nil bundle:nil];
        
        if (self) {
            [self commonInitWithPhotos:photos initialPhoto:initialPhoto];
        }
        
        return self;*/
    }*/
    
    init(withPhotos photos: [ABPhoto], initialPhoto: ABPhoto) {
        super.init(nibName: nil, bundle: nil)
        
        //if self {
            
        //}
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    - (void)commonInitWithPhotos:(NSArray *)photos initialPhoto:(id <NYTPhoto>)initialPhoto {
    
    _transitionController = [[NYTPhotoTransitionController alloc] init];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = _transitionController;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    // iOS 7 has an issue with constraints that could evaluate to be negative, so we set the width to the margins' size.
    _overlayView = [[NYTPhotosOverlayView alloc] initWithFrame:CGRectMake(0, 0, NYTPhotoCaptionViewHorizontalMargin * 2.0, 0)];
    _overlayView.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NYTPhotoViewerCloseButtonX" inBundle:[NSBundle nyt_photoViewerResourceBundle] compatibleWithTraitCollection:nil] landscapeImagePhone:[UIImage imageNamed:@"NYTPhotoViewerCloseButtonXLandscape" inBundle:[NSBundle nyt_photoViewerResourceBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    _overlayView.leftBarButtonItem.imageInsets = NYTPhotosViewControllerCloseButtinImageInsets;
    _overlayView.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
    
    _notificationCenter = [[NSNotificationCenter alloc] init];
    
    [self setupPageViewControllerWithInitialPhoto:initialPhoto];
    }*/
    
    
    func commonInitWithPhotos(photos: [ABPhoto], initialPhoto: ABPhoto) {
        dataSource = ABPhotosDataSource(withPhotos: photos)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didSingleTapWithGestureRecognizer:")
        singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didSingleTapWithGestureRecognizer:")
        
        
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
    
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }
}
















