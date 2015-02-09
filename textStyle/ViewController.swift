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
    

    var fontName = "Helvetica"
    var fontBoxWidth = CGFloat(200)
    var fontBoxHeight = CGFloat(100)
    var fontSize = CGFloat(32)
    var textColorUI = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
    var textColor   : CGColor?
    var fontUI : UIFont?
    var font : CTFontRef?
    var lineSpacing = CGFloat(10)
    var autoSize = false
    
    var borderWidth = CGFloat(4.0)
    var borderColor    = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor
    var backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
    var dropShadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
    var shadowX = CGFloat(3.0)
    var shadowY = CGFloat(3.0)
    var borderShadowX = CGFloat(3.0)
    var borderShadowY = CGFloat(3.0)
    
    
    var para = NSMutableAttributedString()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProperties("I am a meat popsicle, no really that is precisely what I am")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        drawTextToScreen("I am a meat popsicle, no really that is precisely what I am", point: CGPointMake(CGFloat(100),CGFloat(50)))

        drawText("I am a meat popsicle, no really that is precisely what I am",
            point: CGPointMake(CGFloat(100),CGFloat(50)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setProperties(text: String) {
        fontName = "Helvetica"
        fontBoxWidth = CGFloat(200)
        fontBoxHeight = CGFloat(500)
        fontSize = CGFloat(32)
        textColorUI = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        textColor   = textColorUI.CGColor
        fontUI = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFontOfSize(fontSize)

//        font = CTFontCreateWithName(name: fontName, size: fontSize, matrix: UnsafePointer<CGAffineTransform>)
        // https://developer.apple.com/library/prerelease/ios/documentation/Carbon/Reference/CTFontRef/index.html
        font = CTFontCreateWithName(fontName, fontSize, nil)
        lineSpacing = CGFloat(10)
        autoSize = true
        
        borderWidth = CGFloat(4.0)
        borderColor    = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor
        backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
        dropShadowColor = UIColor(red: 0.4, green: 0.4, blue: 0.0, alpha: 1.0).CGColor
        
        
        
        
        let fontItal = CTFontCreateWithName("Georgia-Italic", fontSize, nil)
        let fontBold = CTFontCreateWithName("Helvetica-Bold", fontSize, nil)
        
        //apply the current text style
        let textFont = [ kCTFontAttributeName as String : font!, kCTForegroundColorAttributeName as String: textColor! ]
        let italFont = [ kCTFontAttributeName as String: fontItal!, kCTForegroundColorAttributeName as String: textColor! ]
        let boldFont = [ kCTFontAttributeName as String: fontBold!, kCTForegroundColorAttributeName as String: textColor!]
        
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
        
    }
    

    func drawText(text : NSString, point: CGPoint) {
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(fontBoxWidth,fontBoxHeight), false, 2.0)
//        let context = UIGraphicsGetCurrentContext()

        
        var fullWidth   = UInt(self.view.frame.width)
        var fullHeight  = UInt(self.view.frame.height)
        
        // getting scaled from later draw call into full sized image
//        var width = UInt(fontBoxWidth)
//        var height = UInt(fontBoxHeight)
        var width = UInt(fullWidth)
        var height = UInt(fullHeight)
        // ensure even width height, hopefully that will lead to 16-byte alignment below
        if (width % 2) != 0 {
            width++
        }
        if (height % 2) != 0 {
            height++
        }
        
        let bitsPerComponent : UInt = 8
        let bytesPerRow : UInt = 4 * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        enum CGImageAlphaInfo : UInt32 {
//            case None
//            case PremultipliedLast
//            case PremultipliedFirst
//            case Last
//            case First
//            case NoneSkipLast
//            case NoneSkipFirst
//            case Only
//        }

        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)

//        Tip:  When you create a bitmap graphics context, you’ll get the best performance 
//        if you make sure the data and bytesPerRow are 16-byte aligned.
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
//        CGContextTranslateCTM(context, 0, CGFloat(height))
//        CGContextScaleCTM(context, 1.0, -1.0)
        
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)

        // scale example
//        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), image)
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        let path = CGPathCreateMutable()
        let bounds = CGRectMake(point.x, point.y, fontBoxWidth, fontBoxHeight)


        CGContextAddRect(context, bounds)
        CGContextStrokePath(context)
        CGContextSetFillColorWithColor(context,backgroundColor)
        CGContextFillRect(context, bounds)

        
        // then outline
        CGContextAddRect(context, bounds)
        CGContextSetStrokeColorWithColor(context, borderColor)
        CGContextSetLineWidth(context, borderWidth)
        CGContextStrokePath(context)

        // text rendering time
        CGPathAddRect(path, nil, bounds)

        // drop shadow
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, CGSizeMake(shadowX, shadowY), 5.0, dropShadowColor)
        
        //rotate text
//        CGContextSetTextMatrix(context, CGAffineTransformMakeRotation( CGFloat(M_PI) ))
        // Create the framesetter with the attributed string.
        
        let framesetter = CTFramesetterCreateWithAttributedString(para);
        let frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), path, nil)
        CTFrameDraw(frame, context)
        
        let image = UIImage(CGImage: CGBitmapContextCreateImage(context))
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRectMake(0,0,CGFloat(fullWidth),CGFloat(fullWidth))
        view.addSubview(imageView)
    }
    
    
    func drawTextToScreen( text: String, point: CGPoint) -> UIImage
    {
        // Define string attributes
        let textFont = [NSFontAttributeName: fontUI! ]
        
        let fontItal = UIFont(name: "Georgia-Italic", size:  fontSize) ?? UIFont.systemFontOfSize(fontSize)
        let italFont = [NSFontAttributeName:fontItal]

        let fontBold = UIFont(name: "Helvetica Bold", size:  fontSize) ?? UIFont.systemFontOfSize(fontSize)
        let boldFont = [NSFontAttributeName:fontBold]
        
        
        // Create a string that will be our paragraph
        let para = NSMutableAttributedString()
        
        // Create locally formatted strings
        let attrString1 = NSAttributedString(string: text, attributes: textFont)
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

