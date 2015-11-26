//
//  ABPhoto.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//


//The model for photos displayed in an `ABPhotosViewController`.

import UIKit

protocol ABPhoto {
    var image: UIImage {get} // The image to display.
    var placeholderImage: UIImage {get} // A placeholder image for display while the image is loading.
    var attributedCaptionTitle: NSAttributedString {get} // An attributed string for display as the title of the caption.
    var attributedCaptionSummary: NSAttributedString {get} // An attributed string for display as the summary of the caption.
    var attributedCaptionCredit: NSAttributedString {get} // An attributed string for display as the credit of the caption.
}
