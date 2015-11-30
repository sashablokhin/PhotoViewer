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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.addGestureRecognizer(imageTap)
        imageView.userInteractionEnabled = true
        
        imageTap.addTarget(self, action: "imageTapped")
        
        imageView.image = photos[0].image
    }
    
    func imageTapped() {
        let photosViewController = ABPhotosViewController(withPhotos: photos)
        photosViewController.delegate = self
        presentViewController(photosViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

