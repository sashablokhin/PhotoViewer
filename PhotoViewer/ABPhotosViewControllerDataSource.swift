//
//  ABPhotosViewControllerDataSource.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//


// A protocol defining methods that must exist on a data source for an `ABPhotosViewController`.

protocol NYTPhotosViewControllerDataSource {
    // The total number of photos in the data source.
    var numberOfPhotos: UInt {get}
    
    
    /* Returns the photo object at a specified index, or `nil` if one does not exist at that index.
    *
    *  @param photoIndex The index of the desired photo.
    *
    *  @return The photo object at a specified index, or `nil` if one does not exist at that index.
    */
    func photoAtIndex(photoIndex: UInt) -> ABPhoto
    
    
    /* Returns the index of a given photo, or `NSNotFound` if the photo is ot in the data source.
    *
    *  @param photo The photo against which to look for the index.
    *
    *  @return The index of a given photo, or `NSNotFound` if the photo is ot in the data source.
    */
    func indexOfPhoto(photo: ABPhoto) -> UInt
    
    
    /* Returns a `Bool` representing whether the data source contains the passed-in photo.
    *
    *  @param photo The photo to check existence of in the data source.
    *
    *  @return A `Bool` representing whether the data source contains the passed-in photo.
    */
    func containsPhoto(photo: ABPhoto) -> Bool
    

    /* Subscripting support. For example, `dataSource[0]` will be a valid way to obtain the photo at index 0.
    *  @note Indexes outside the range of the data source are expected to return `nil` and not to crash.
    *
    *  @param photoIndex The index of the photo.
    *
    *  @return The photo at the index, or `nil` if there is none.
    */
    func objectAtIndexedSubscript(photoIndex: UInt) -> ABPhoto
}


