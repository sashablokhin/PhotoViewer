//
//  ViewController.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ABPhotosViewControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    private let photos = PhotosProvider().photos
    
    let imageTap = UITapGestureRecognizer()
    

    func updateImagesOnPhotosViewController(photosViewController: ABPhotosViewController, afterDelayWithPhotos: [ABPhoto]) {
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, 5 * Int64(NSEC_PER_SEC))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            for photo in self.photos {
                if photo.image == nil {
                    photo.image = UIImage(named: PrimaryImageName)
                    photosViewController.updateImageForPhoto(photo)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.addGestureRecognizer(imageTap)
        imageView.userInteractionEnabled = true
        
        imageTap.addTarget(self, action: "imageTapped")
        
        imageView.image = photos[0].image
    }
    
    func imageTapped() {
        let photosViewController = ABPhotosViewController(photos: photos, delegate: self)
        //photosViewController.delegate = self
        presentViewController(photosViewController, animated: true, completion: nil)
        
        updateImagesOnPhotosViewController(photosViewController, afterDelayWithPhotos: photos)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - ABPhotosViewControllerDelegate
    
    func photosViewController(photosViewController: ABPhotosViewController!, handleActionButtonTappedForPhoto photo: ABPhoto!) -> Bool {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            let shareActivityViewController = UIActivityViewController(activityItems: [photo.image!], applicationActivities: nil)
            
            shareActivityViewController.completionWithItemsHandler = {(activityType: String?, completed: Bool, items: [AnyObject]?, error: NSError?) in
                if completed {
                    photosViewController.delegate?.photosViewController!(photosViewController, actionCompletedWithActivityType: activityType!)
                }
            }
            
            shareActivityViewController.popoverPresentationController?.barButtonItem = photosViewController.rightBarButtonItem
            photosViewController.presentViewController(shareActivityViewController, animated: true, completion: nil)
            
            return true
        }
        
        return false
    }
    
    func photosViewController(photosViewController: ABPhotosViewController!, referenceViewForPhoto photo: ABPhoto!) -> UIView! {
        
        if photo as? Photo == photos[NoReferenceViewPhotoIndex] {
            return nil
        }
        return imageView
    }
    
    func photosViewController(photosViewController: ABPhotosViewController!, loadingViewForPhoto photo: ABPhoto!) -> UIView! {
        if photo as! Photo == photos[CustomEverythingPhotoIndex] {
            let label = UILabel()
            label.text = "Custom Loading..."
            label.textColor = UIColor.greenColor()
            return label
        }
        return nil
    }
    
    func photosViewController(photosViewController: ABPhotosViewController!, captionViewForPhoto photo: ABPhoto!) -> UIView! {
        if photo as! Photo == photos[CustomEverythingPhotoIndex] {
            let label = UILabel()
            label.text = "Custom Caption View"
            label.textColor = UIColor.whiteColor()
            label.backgroundColor = UIColor.redColor()
            return label
        }
        return nil
    }
    
    func photosViewController(photosViewController: ABPhotosViewController!, didNavigateToPhoto photo: ABPhoto!, atIndex photoIndex: UInt) {
        print("Did Navigate To Photo: \(photo) identifier: \(photoIndex)")
    }
    
    func photosViewController(photosViewController: ABPhotosViewController!, actionCompletedWithActivityType activityType: String!) {
        print("Action Completed With Activity Type: \(activityType)")
    }
    
    func photosViewControllerDidDismiss(photosViewController: ABPhotosViewController!) {
        print("Did dismiss Photo Viewer: \(photosViewController)")
    }
}

