//
//  ViewController.swift
//  textStyle
//
//  Created by messel on 2/5/15.
//  Copyright (c) 2015 messel. All rights reserved.
//

import UIKit
import CoreText

class MarginLabel : UILabel {
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsetsMake(0, 5, 0, 5)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        var label = UILabel(frame: CGRectMake(0, 0, 200, 21))
//        label.center = CGPointMake(160, 284)
//        label.textAlignment = NSTextAlignment.Center
//        label.text = "I'am a test label"
//        self.view.addSubview(label)

        drawText("I am a meat popsicle, no really that is precisely what I am", point: CGPointMake(CGFloat(100),CGFloat(50)))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func drawText( text : NSString, image: UIImage, point: CGPoint) -> UIImage
    {
        var fontName = "Helvetica"
        var fontBoxWidth = CGFloat(200)
        var fontBoxHeight = CGFloat(100)
        var fontSize = CGFloat(32)
        var font = UIFont(name: fontName, size: fontSize)
        UIGraphicsBeginImageContext(self.view.frame.size)
        // blend modes https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGContext/index.html#//apple_ref/c/tdef/CGBlendMode
        image.drawInRect(CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height), blendMode: kCGBlendModeSourceAtop, alpha: CGFloat(1.0))
        var rect = CGRectMake(0,0,fontBoxWidth,fontBoxHeight)
        // no label to set text color
        // label.textColor = UIColor( colorWithRed:255 green:0 blue:0 alpha:1.0 )
        // label.numberOfLines = 1
        
        // style for text http://stackoverflow.com/questions/18948180/align-text-using-drawinrectwithattributes
        /// Make a copy of the default paragraph style
        var  paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
        // set # of lines
        /// Set line break mode
        paragraphStyle.lineBreakMode = NSLineBreakMode(NSLineBreakByTruncatingTail)
        /// Set text alignment
        paragraphStyle.alignment = "NSTextAlignmentCenter"
        
        var attributes = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle ]
        
        text.drawInRect(rect, withAttributes:attributes)
        
//        text.drawInRect(rect, withFont: font)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    */
    
    func drawText( text: String, point: CGPoint) -> UIImage
    {
        // Define string attributes
        var fontName = "Helvetica"
        var fontBoxWidth = CGFloat(200)
        var fontBoxHeight = CGFloat(100)
        var fontSize = CGFloat(32)
        var textColorUI = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        var textColor   = textColorUI.CGColor
        var font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
        var lineSpacing = CGFloat(10)
        var autoSize = true
        
        var borderWidth = CGFloat(4.0)
        var borderColor    = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor
        var backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor

        let textFont = [NSFontAttributeName:font ]
        
        let fontItal = UIFont(name: "Georgia-Italic", size:  fontSize) ?? UIFont.systemFontOfSize(fontSize)
        let italFont = [NSFontAttributeName:fontItal]

        let fontBold = UIFont(name: "Helvetica Bold", size:  fontSize) ?? UIFont.systemFontOfSize(fontSize)
        let boldFont = [NSFontAttributeName:fontBold]
        
        
        // Create a string that will be our paragraph
        let para = NSMutableAttributedString()
        
        // Create locally formatted strings
        let attrString1 = NSAttributedString(string: text, attributes:textFont)
        let attrString2 = NSAttributedString(string: " attributed", attributes:italFont)
        let attrString3 = NSAttributedString(string: " strings.", attributes:boldFont)
        
        // Add locally formatted strings to paragraph
        para.appendAttributedString(attrString1)
        para.appendAttributedString(attrString2)
        para.appendAttributedString(attrString3)
        
        // Define paragraph styling
        let paraStyle = NSMutableParagraphStyle()
//        paraStyle.firstLineHeadIndent = 15.0
//        paraStyle.paragraphSpacingBefore = 10.0
        paraStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paraStyle.lineSpacing = lineSpacing
        
        // Apply paragraph styles to paragraph
        para.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0,length: para.length))
        
        
        // next step figure out how to draw to a rectangle or UIImage and render that to the screen
//        let textRect = CGRectMake(0, 0, fontBoxWidth, fontBoxHeight)
//        let textFontAttributes = [
//            NSFontAttributeName: font,
//            NSForegroundColorAttributeName: textColor,
//            NSParagraphStyleAttributeName: paraStyle
//        ]
//        
//        text.drawInRect(textRect, withAttributes: textFontAttributes)
        
        let view = MarginLabel(frame: CGRect(x: point.x, y: point.y, width: CGRectGetWidth(self.view.frame) - point.x, height: CGRectGetHeight(self.view.frame)-point.y))
        view.numberOfLines = 0
        view.textColor = textColorUI
        view.layer.bounds = CGRectMake(0, 0, fontBoxWidth, fontBoxHeight)
        view.layer.cornerRadius = CGFloat(8)
        view.layer.masksToBounds = true
        view.layer.borderColor = borderColor
        view.layer.borderWidth = borderWidth
        view.layer.backgroundColor = backgroundColor
        
        
        // Add string to UITextView
        view.attributedText = para
        if autoSize {
            view.sizeToFit()
        }
        
        // Add UITextView to main view
        self.view.addSubview(view)
        
        // now add to image
        UIGraphicsBeginImageContext(view.frame.size)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }


}

