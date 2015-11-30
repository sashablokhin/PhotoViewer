//
//  PhotosProvider.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit

class PhotosProvider: NSObject {
    
    let photos: [Photo] = {
        
        var mutablePhotos: [Photo] = []
        
        for photoIndex in 0..<4 {
            
            let image = UIImage(named: "img_0\(photoIndex)")
            
            let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            let photo = Photo(image: image!, attributedCaptionTitle: title)
            
            mutablePhotos.append(photo)
        }
        
        return mutablePhotos
    }()
}
