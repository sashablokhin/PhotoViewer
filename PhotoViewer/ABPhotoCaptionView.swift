//
//  ABPhotoCaptionView.swift
//  PhotoViewer
//
//  Created by Alexander Blokhin on 06.12.15.
//  Copyright © 2015 Alexander Blokhin. All rights reserved.
//

import UIKit


let ABPhotoCaptionViewHorizontalMargin: CGFloat = 16.0
let ABPhotoCaptionViewVerticalMargin: CGFloat = 12.0

class ABPhotoCaptionView: UIView {

    var attributedTitle: NSAttributedString?
    var attributedSummary: NSAttributedString?
    var attributedCredit: NSAttributedString?

    var textLabel: UILabel!
    var gradientLayer: CAGradientLayer!

    // MARK: - UIView

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    convenience override init(frame: CGRect) {        
        self.init(attributedTitle: nil, attributedSummary: nil, attributedCredit: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        self.gradientLayer!.frame = self.layer.bounds
    }

// MARK: - ABPhotoCaptionView

    init(attributedTitle: NSAttributedString?, attributedSummary: NSAttributedString?, attributedCredit: NSAttributedString?) {
        super.init(frame: CGRectZero)
    
        self.attributedTitle = attributedTitle
        self.attributedSummary = attributedSummary
        self.attributedCredit = attributedCredit
        
        self.commonInit()
    }
    
    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.setupTextLabel()
        self.updateTextLabelAttributedText()
        self.setupGradient()
    }
        
    func setupTextLabel() {
        self.textLabel = UILabel()
        self.textLabel.numberOfLines = 0
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textLabel)
        
        let topConstraint = NSLayoutConstraint(item: textLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: ABPhotoCaptionViewVerticalMargin)
        
        let bottomConstraint = NSLayoutConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -ABPhotoCaptionViewVerticalMargin)
        
        let widthConstraint = NSLayoutConstraint(item: textLabel, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: -ABPhotoCaptionViewHorizontalMargin * 2.0)
        
        let horizontalPositionConstraint = NSLayoutConstraint(item: textLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            
        self.addConstraints([topConstraint, bottomConstraint, widthConstraint, horizontalPositionConstraint])
    }
            
    func setupGradient() {
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer.frame = self.layer.bounds
        self.gradientLayer.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().colorWithAlphaComponent(0.85).CGColor]
        self.layer.insertSublayer(self.gradientLayer, atIndex: 0)
    }
                
    func updateTextLabelAttributedText() {
        let attributedLabelText = NSMutableAttributedString()
                    
        if (self.attributedTitle != nil) {
            attributedLabelText.appendAttributedString(self.attributedTitle!)
        }
                    
        if (self.attributedSummary != nil) {
            if (self.attributedTitle != nil) {
                attributedLabelText.appendAttributedString(NSAttributedString(string: "\n", attributes: nil))
            }
                        
            attributedLabelText.appendAttributedString(self.attributedSummary!)
        }
                    
        if (self.attributedCredit != nil) {
            if (self.attributedTitle != nil || self.attributedSummary != nil) {
                attributedLabelText.appendAttributedString(NSAttributedString(string: "\n", attributes: nil))
            }
                        
            attributedLabelText.appendAttributedString(self.attributedCredit!)
        }
                    
        self.textLabel.attributedText = attributedLabelText;
    }
}












