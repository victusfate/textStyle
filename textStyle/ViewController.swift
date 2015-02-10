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

let TS_DEFAULT_WIDTH    = CGFloat(200)
let TS_DEFAULT_HEIGHT   = CGFloat(100)


class ViewController: UIViewController {
    
    var text = ""
    var fontName = "Helvetica"
    var fontBoxWidth = TS_DEFAULT_WIDTH
    var fontBoxHeight = TS_DEFAULT_HEIGHT
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
    var shadowBlur = CGFloat(5.0)
    var borderShadowX = CGFloat(3.0)
    var borderShadowY = CGFloat(3.0)
    var align = "Left"   // "Left", "Center", "Right"
    var baseline = "Top" // "Top", "Middle", "Bottom"
    var boundingBox = CGRectMake(0, 0, TS_DEFAULT_WIDTH, TS_DEFAULT_HEIGHT)
    

    // all properties
//    "align":                { "type": "int",      "val": "Theme.TextAlign.Left"    },
//    "autoSizeEnabled":      { "type": "bool",     "val": false                     },
//    "autoSizeMax":          { "type": "float",    "val": 10                        },
//    "autoSizeMin":          { "type": "float",    "val": 0.25                      },
//    "backgroundColor":      { "type": "string",   "val": "rgba(0,0,0,0)"           },
//    "baseline":             { "type": "int",      "val": "Theme.TextBaseline.Top"  },
//    "borderColor":          { "type": "string",   "val": "#FFFFFF"                 },
//    "borderLineWidth":      { "type": "float",    "val": 0.003125                  },
//    "borderOutline":        { "type": "bool",     "val": false                     },
//    "borderPadding":        { "type": "float",    "val": 0.0078125                 },
//    "borderPerLine":        { "type": "bool",     "val": false                     },
//    "borderShadowBlur":     { "type": "float",    "val": 0                         },
//    "borderShadowColor":    { "type": "string",   "val": "#000"                    },
//    "borderShadowX":        { "type": "float",    "val": 0                         },
//    "borderShadowY":        { "type": "float",    "val": 0                         },
//    "capsAll":              { "type": "bool",     "val": false                     },
//    "capsFirst":            { "type": "bool",     "val": false                     },
//    "capsLower":            { "type": "bool",     "val": false                     },
//    "font":                 { "type": "string",   "val": "Sans Serif"              },
//    "fontColor":            { "type": "string",   "val": "#FFFFFF"                 },
//    "fontSize":             { "type": "float",    "val": 0                         },
//    "fontSlant":            { "type": "int",      "val": "Theme.FontSlant.Normal"  },
//    "fontWeight":           { "type": "int",      "val": "Theme.FontWeight.Normal" },
//    "kerning":              { "type": "float",    "val": 0                         },
//    "lineHeight":           { "type": "float",    "val": 0                         },
//    "shadowBlur":           { "type": "float",    "val": 0                         },
//    "shadowColor":          { "type": "string",   "val": "#000"                    },
//    "shadowX":              { "type": "float",    "val": 0                         },
//    "shadowY":              { "type": "float",    "val": 0                         },
//    "maxTextLines":         { "type": "int",      "val": 0                         },
//    "useLineHeight":        { "type": "bool",     "val": false                     }
    
    
    
    var para = NSMutableAttributedString()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProperties("I am a meat popsicle, no really that is precisely what I am", targetFontSize: CGFloat(32))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        drawTextToScreen("I am a meat popsicle, no really that is precisely what I am", point: CGPointMake(CGFloat(100),CGFloat(50)))

        drawText(CGPointMake(CGFloat(100),CGFloat(50)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getScale(v1: CGFloat, v2: CGFloat) -> CGFloat {
        return sqrt(v1/v2)
    }
    
    func setProperties(inText: String, targetFontSize: CGFloat) {
        text = inText
        fontName = "Helvetica"
        fontBoxWidth = CGFloat(200)
        fontBoxHeight = CGFloat(200)
        fontSize = targetFontSize
        textColorUI = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        textColor   = textColorUI.CGColor
        fontUI = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFontOfSize(fontSize)

//        font = CTFontCreateWithName(name: fontName, size: fontSize, matrix: UnsafePointer<CGAffineTransform>)
        // https://developer.apple.com/library/prerelease/ios/documentation/Carbon/Reference/CTFontRef/index.html
        font = CTFontCreateWithName(fontName, fontSize, nil)
        lineSpacing = CGFloat(10)
        autoSize = false
        align = "Top"
        baseline = "Top"
//        baseline = "Middle"
        
        borderWidth = CGFloat(4.0)
        borderColor    = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor
        backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
        dropShadowColor = UIColor(red: 0.4, green: 0.4, blue: 0.0, alpha: 1.0).CGColor
        
        let fontItal = CTFontCreateWithName("Georgia-Italic", fontSize, nil)
        let fontBold = CTFontCreateWithName("Helvetica-Bold", fontSize, nil)
        
        //apply the current text style
        let sKeyAttributeName : String = (kCTFontAttributeName as NSString) as String
        let sForegroundColorAttributeName : String = (kCTForegroundColorAttributeName as NSString) as String
        let textFont = [ sKeyAttributeName: font!,      sForegroundColorAttributeName: textColor!]
        let italFont = [ sKeyAttributeName: fontItal!,  sForegroundColorAttributeName: textColor!]
        let boldFont = [ sKeyAttributeName: fontBold!,  sForegroundColorAttributeName: textColor!]
        
        let attrString1 = NSAttributedString(string: text, attributes: textFont as [NSObject : AnyObject])
        let attrString2 = NSAttributedString(string: " attributed", attributes:italFont as [NSObject : AnyObject])
        let attrString3 = NSAttributedString(string: " strings.", attributes:boldFont as [NSObject : AnyObject])
        
        // Add locally formatted strings to paragraph
        para = NSMutableAttributedString()
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
        
//        let expectedLabelSize = (text + " attributed" + " strings.").sizeWithFont([UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        
    }

    func drawText(point: CGPoint) {
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

        
        let options : NSStringDrawingOptions = .UsesFontLeading | .UsesLineFragmentOrigin | .UsesDeviceMetrics
        let rect = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
        // height
        println("rect \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect.width) height \(rect.height)")
  
        if autoSize {
            if rect.width > fontBoxWidth {
                let scale = getScale(CGFloat(fontBoxWidth),v2: rect.width)
                let newFontSize = scale * fontSize
                println("1 updating with new font size \(newFontSize)")
                self.setProperties(text,targetFontSize: newFontSize)
                let rect2 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
                println("rect2 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect2.width) height \(rect2.height)")
                boundingBox = rect2
                if rect2.height > fontBoxHeight {
                    let scale2 = getScale(CGFloat(fontBoxHeight),v2: rect2.height)
                    let newFontSize = scale2 * fontSize
                    println("2 updating with new font size \(newFontSize)")
                    self.setProperties(text,targetFontSize: newFontSize)
                    let rect3 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
                    boundingBox = rect3
                    println("rect3 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect3.width) height \(rect3.height)")
                }
            }
            else if rect.height > fontBoxHeight {
                let scale = getScale(CGFloat(fontBoxHeight), v2: rect.height)
                let newFontSize = scale * fontSize
                println("3 updating with new font size \(newFontSize)")
                self.setProperties(text,targetFontSize: newFontSize)
                let rect2 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
                boundingBox = rect2
                println("rect2 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect2.width) height \(rect2.height)")
                if rect2.width > fontBoxWidth {
                    let scale2 = getScale(CGFloat(fontBoxWidth), v2: rect2.width)
                    let newFontSize = scale2 * fontSize
                    println("4 updating with new font size \(newFontSize)")
                    self.setProperties(text,targetFontSize: newFontSize)
                    let rect3 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
                    boundingBox = rect3
                    println("rect3 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect3.width) height \(rect3.height)")
                }
                
            }
        }
        else {
            boundingBox = rect
            // adjust fontBoxWidth/Height to rendered text
            fontBoxWidth = rect.width
            var fontBoundingBox = CTFontGetBoundingBox(font)
//            fontBoxHeight = rect.height + fontBoundingBox.height
            fontBoxHeight = rect.height + fontBoundingBox.height
//            fontBoxHeight = rect.height + boundingBox.origin.y - boundingBox.height
            println("font bounding box \(fontBoundingBox), height \(fontBoundingBox.height)")
//            fontBoxHeight = rect.height - boundingBox.height // need to compensate for something off here
        }
        
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

        // text vertical align, and horizontal align
//        CGRect boundingBox = CTFontGetBoundingBox(font);
//        
//        //Get the position on the y axis
//        float midHeight = self.frame.size.height / 2;
//        midHeight -= boundingBox.size.height / 2;
//        
//        CGPathAddRect(path, NULL, CGRectMake(0, midHeight, self.frame.size.width, boundingBox.size.height));

        //        CGPathAddRect(path, nil, bounds)
        if (baseline == "Top") {
            CGPathAddRect(path, nil, bounds) // Draw normally (top)
        }
        else if (baseline == "Middle") {
            //Get the position on the y axis (middle)
            var midHeight = bounds.height / 2.0
            midHeight = midHeight - (boundingBox.height / 2.0)
            println("baseline middle midheight offset \(midHeight), bounds \(bounds) boundingBox \(boundingBox)")
            
            CGPathAddRect(path, nil, CGRectMake(bounds.origin.x, bounds.origin.y + midHeight, bounds.width, boundingBox.height))
        }
        else {
            let bottomHeight = bounds.height - boundingBox.height
            CGPathAddRect(path, nil, CGRectMake(bounds.origin.x, bounds.origin.y + bottomHeight, bounds.width, boundingBox.height));
        }

        // drop shadow
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, CGSizeMake(shadowX, shadowY), shadowBlur, dropShadowColor)
        
        //rotate text
//        CGContextSetTextMatrix(context, CGAffineTransformMakeRotation( CGFloat(M_PI) ))
        // Create the framesetter with the attributed string.
        
        let framesetter = CTFramesetterCreateWithAttributedString(para);
        let frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), path, nil)
        
//        var fitRange: CFRange
//        
//        let textRange = CFRangeMake(0, para.length)
//        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, textRange, nil, bounds, &fitRange)
        
        
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
//        paraStyle.lineSpacing = lineSpacing
        
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

          // standardized method to compute rendered text bounding box
    //    func getTextSize(frame : CTFrameRef) -> CGSize {
    //        let framePath = CTFrameGetPath(frame)
    //        let frameRect = CGPathGetBoundingBox(framePath)
    //
    //        let lines = CTFrameGetLines(frame)
    //        let numLines = CFArrayGetCount(lines)
    //
    //        var maxWidth = 0
    //        var textHeight = 0
    //
    //        // Now run through each line determining the maximum width of all the lines.
    //        // We special case the last line of text. While we've got it's descent handy,
    //        // we'll use it to calculate the typographic height of the text as well.
    //        var lastLineIndex : CFIndex = numLines - 1
    //        for var index = 0; index < numLines; index++ {
    //            maxWidth = width;
    //
    //            if(index == lastLineIndex)
    //            {
    //                // Get the origin of the last line. We add the descent to this
    //                // (below) to get the bottom edge of the last line of text.
    //                var  lastLineOrigin : CGPoint
    //                CTFrameGetLineOrigins(frame, CFRangeMake(lastLineIndex, 1), &lastLineOrigin)
    //
    //                // The height needed to draw the text is from the bottom of the last line
    //                // to the top of the frame.
    //                textHeight =  CGRectGetMaxY(frameRect) - lastLineOrigin.y + descent
    //            }
    //        }
    //
    //        // For some text the exact typographic bounds is a fraction of a point too
    //        // small to fit the text when it is put into a context. We go ahead and round
    //        // the returned drawing area up to the nearest point.  This takes care of the
    //        // discrepencies.
    //        return CGSizeMake(ceil(maxWidth), ceil(textHeight));
    //    }

}

