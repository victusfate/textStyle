//
//  ViewController.swift
//  textStyle
//
//  Created by messel on 2/5/15.
//  Copyright (c) 2015 messel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var label = UILabel(frame: CGRectMake(0, 0, 200, 21))
        label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        label.text = "I'am a test label"
        self.view.addSubview(label)
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
        var font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
        let textFont = [NSFontAttributeName:font]
        
        let fontItal = UIFont(name: "Georgia-Italic", size:  fontSize) ?? UIFont.systemFontOfSize(fontSize)
        let italFont = [NSFontAttributeName:fontItal]
        
        // Create a string that will be our paragraph
        let para = NSMutableAttributedString()
        
        // Create locally formatted strings
        let attrString1 = NSAttributedString(string: text, attributes:textFont)
        let attrString2 = NSAttributedString(string: " attributed", attributes:italFont)
        let attrString3 = NSAttributedString(string: " strings.", attributes:textFont)
        
        // Add locally formatted strings to paragraph
        para.appendAttributedString(attrString1)
        para.appendAttributedString(attrString2)
        para.appendAttributedString(attrString3)
        
        // Define paragraph styling
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.firstLineHeadIndent = 15.0
        paraStyle.paragraphSpacingBefore = 10.0
        // https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSParagraphStyle_Class/#//apple_ref/c/tdef/NSLineBreakMode
        paraStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        // Apply paragraph styles to paragraph
        para.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0,length: para.length))
        
        // Create UITextView
        let view = UITextView(frame: CGRect(x: point.x, y: point.y, width: CGRectGetWidth(self.view.frame) - point.x, height: CGRectGetHeight(self.view.frame)-point.y))
        
        // Add string to UITextView
        view.attributedText = para
        
        // Add UITextView to main view
        self.view.addSubview(view)
        
        // now add to image
        UIGraphicsBeginImageContext(view.frame.size)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }


}

