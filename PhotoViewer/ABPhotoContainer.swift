//
//  ABPhotoContainer.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//


// A protocol that defines that an object contains a photo property.

protocol ABPhotoContainer {
    // An object conforming to the `ABPhoto` protocol.
    var photo: ABPhoto? {get}
}