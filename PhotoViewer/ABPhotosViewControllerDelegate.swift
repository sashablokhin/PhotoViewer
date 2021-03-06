//
//  ABPhotosViewControllerDelegate.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 26.11.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit

// A protocol of entirely optional methods called for configuration and lifecycle events by an `ABPhotosViewController` instance.

@objc protocol ABPhotosViewControllerDelegate : NSObjectProtocol {
    
     /* Called when a new photo is displayed through a swipe gesture.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     *  @param photo                The photo object that was just displayed.
     *  @param photoIndex           The index of the photo that was just displayed.
     */
    optional func photosViewController(photosViewController: ABPhotosViewController!, didNavigateToPhoto photo: ABPhoto!, atIndex photoIndex: UInt)
    
    
     /* Called immediately before the photos view controller is about to start dismissal. This will be the beginning of the interactive panning to dismiss, if it is enabled and performed.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     */
    optional func photosViewControllerWillDismiss(photosViewController: ABPhotosViewController!)
    
    
     /* Called immediately after the photos view controller has dismissed.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     */
    optional func photosViewControllerDidDismiss(photosViewController: ABPhotosViewController!)
    
    
     /* Returns a view to display over a photo, full width, locked to the bottom, representing the caption for the photo. Can be any `UIView` object, but is expected to respond to `intrinsicContentSize` appropriately to calculate height.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     *  @param photo                The photo object over which to display the caption view.
     *
     *  @return A view to display as the caption for the photo. Return `nil` to show a default view generated from the caption properties on the photo object.
     */
    optional func photosViewController(photosViewController: ABPhotosViewController!, captionViewForPhoto photo: ABPhoto!) -> UIView!
    
    
     /* Returns a view to display while a photo is loading. Can be any `UIView` object, but is expected to respond to `sizeToFit` appropriately. This view will be sized and centered in the blank area, and hidden when the photo image is loaded.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     *  @param photo                The photo object over which to display the activity view.
     *
     *  @return A view to display while the photo is loading. Return `nil` to show a default white `UIActivityIndicatorView`.
     */
    optional func photosViewController(photosViewController: ABPhotosViewController!, loadingViewForPhoto photo: ABPhoto!) -> UIView!
    
    
     /* Returns the view from which to animate for a given object conforming to the `ABPhoto` protocol.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     *  @param photo                The photo for which the animation will occur.
     *
     *  @return The view to animate out of or into for the given photo.
     */
    optional func photosViewController(photosViewController: ABPhotosViewController!, referenceViewForPhoto photo: ABPhoto!) -> UIView!
    
    
     /* Returns the maximum zoom scale for a given object conforming to the `ABPhoto` protocol.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     *  @param photo                The photo for which the maximum zoom scale is requested.
     *
     *  @return The maximum zoom scale for the given photo.
     */
    optional func photosViewController(photosViewController: ABPhotosViewController!, maximumZoomScaleForPhoto photo: ABPhoto!) -> CGFloat
    
    
     /* Called when a photo is long pressed.
     *
     *  @param photosViewController       The `ABPhotosViewController` instance that sent the delegate message.
     *  @param photo                      The photo being displayed that was long pressed.
     *  @param longPressGestureRecognizer The gesture recognizer that detected the long press.
     *
     *  @return `YES` if the long press was handled by the client, `NO` if the default `UIMenuController` with a Copy action is desired.
     */
    optional func photosViewController(photosViewController: ABPhotosViewController!, handleLongPressForPhoto photo: ABPhoto!, withGestureRecognizer longPressGestureRecognizer: UILongPressGestureRecognizer) -> Bool
    
    
     /* Called when the action button is tapped.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     *  @param photo                The photo being displayed when the action button was tapped.
     *
     *  @return `YES` if the action button tap was handled by the client, `NO` if the default `UIActivityViewController` is desired.
     */
    optional func photosViewController(photosViewController: ABPhotosViewController!, handleActionButtonTappedForPhoto photo: ABPhoto!) -> Bool
    
    
     /* Called after the default `UIActivityViewController` is presented and successfully completes an action with a specified activity type.
     *
     *  @param photosViewController The `ABPhotosViewController` instance that sent the delegate message.
     *  @param activityType         The activity type that was successfully shared.
     */
    optional func photosViewController(photosViewController: ABPhotosViewController!, actionCompletedWithActivityType activityType: String!) 
}
