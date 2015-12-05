//
//  ABPhotosDataSource.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 30.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import Foundation

class ABPhotosDataSource: ABPhotosViewControllerDataSource {

    var photos = [ABPhoto]()

// MARK: - NSObject
    
    convenience init() {
        self.init(withPhotos: nil)
    }

// MARK: - ABPhotosDataSource

    init(withPhotos photos: [ABPhoto]?) {
        if photos != nil {
            self.photos = photos!
        }
    }

// MARK: - ABPhotosViewControllerDataSource
    
    var numberOfPhotos: Int {
        return photos.count
    }


    func photoAtIndex(photoIndex: Int) -> ABPhoto? {
        if (photoIndex < self.photos.count) {
            return self.photos[photoIndex]
        }
        
        return nil
    }
    
    func indexOfPhoto(photo: ABPhoto) -> Int? {
        return self.photos.indexOf({$0 === photo})
    }
    
    func containsPhoto(photo: ABPhoto) -> Bool {
        return self.photos.contains({$0 === photo})
    }

    func objectAtIndexedSubscript(photoIndex: Int) -> ABPhoto? {
        return self.photoAtIndex(photoIndex)
    }
}

























