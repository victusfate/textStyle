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
let TS_DEFAULT_FULL_WIDTH = CGFloat(1280)
let TS_DEFAULT_FULL_HEIGHT = CGFloat(720)

class CMTextStyle {
    var text = ""
    
    var fontBoxWidth = TS_DEFAULT_WIDTH
    var fontBoxHeight = TS_DEFAULT_HEIGHT
    var boundingBox = CGRectMake(0, 0, TS_DEFAULT_WIDTH, TS_DEFAULT_HEIGHT)
    var backgroundBounds = CGRectMake(0, 0, TS_DEFAULT_WIDTH, TS_DEFAULT_HEIGHT)
    var baselineAdjust = CGFloat(0.0)
    var fullWidth = TS_DEFAULT_FULL_WIDTH
    var fullHeight = TS_DEFAULT_FULL_HEIGHT
    
    var fontColorUI = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
    
    var fontUI : UIFont?
    var fontCT : CTFontRef?

    //    var lineSpacing = CGFloat(10)
    
    
    // all properties, see oFontProperties.json in cameo-montage-script
    // full width and height will scale just fontsize properties, 1080p 1.0, 720p
    var align = "Center"   // "Left", "Center", "Right"
    var autoSizeEnabled = false
    var autoSizeMax = 10 // scale factor to nominal font size
    var autoSizeMin = 0.25
    var backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
    var baseline = "Top" // "Top", "Middle", "Bottom"
    var borderColor    = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor
    var borderLineWidth = CGFloat(4.0)
    var borderOutline = true
    var borderPadding = CGFloat(0.0)
    var borderPerLine = false
    var borderShadowBlur = CGFloat(0.0)
    var borderShadowColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor
    var borderShadowX = CGFloat(3.0)
    var borderShadowY = CGFloat(3.0)
    var capsAll = false
    var capsFirst = false
    var capsLower = false
    var font = "Helvetica"
    var fontColor   : CGColor?
    var fontSize = CGFloat(32) // normalize based on passed full width /height 1080p 1.0, 720p some fraction (look up font size to pixels)
    var fontSlant = "Normal"  // "Normal", "Italics", "Oblique"
    var fontWeight = "Normal" // "Lighter", "Normal", "Bold", "Bolder"
    var kerning = CGFloat(0.0) // additional space beyond nominal
    var lineHeight = CGFloat(10)
    var shadowBlur = CGFloat(5.0)
    var shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
    var shadowX = CGFloat(3.0)
    var shadowY = CGFloat(3.0)
    var maxTextLines = 10
    var useLineHeight = false
    
    var para = NSMutableAttributedString()

    func getScale(v1: CGFloat, v2: CGFloat) -> CGFloat {
        return sqrt(v1/v2)
    }
    
    func getLineHeight(font: CTFontRef) -> CGFloat {
        let ascent = CTFontGetAscent(font)
        let descent = CTFontGetDescent(font)
        var leading = CTFontGetLeading(font)
        
        if leading < 0 {
            leading = 0
        }
        leading = floor (leading + 0.5)
        
        let calcLineHeight = floor (ascent + 0.5) + floor (descent + 0.5) + leading;
        
        var ascenderDelta = CGFloat(0)
        if leading > 0 {
            ascenderDelta = 0
        }
        else {
            ascenderDelta = floor (0.25 * calcLineHeight + 0.5)
        }
        
        let defaultLineHeight = calcLineHeight + ascenderDelta
        return defaultLineHeight
    }
    
    func setProperties(inText: String, targetFontSize: CGFloat) {
        text = inText
        font = "Helvetica"
        fontBoxWidth = CGFloat(200)
        fontBoxHeight = CGFloat(200)
        fontSize = targetFontSize
        fontColorUI = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        fontColor   = fontColorUI.CGColor
        fontUI = UIFont(name: font, size: fontSize) ?? UIFont.systemFontOfSize(fontSize)
        
        //        font = CTFontCreateWithName(name: fontName, size: fontSize, matrix: UnsafePointer<CGAffineTransform>)
        // https://developer.apple.com/library/prerelease/ios/documentation/Carbon/Reference/CTFontRef/index.html
        fontCT = CTFontCreateWithName(font, fontSize, nil)
        autoSizeEnabled = true
        align = "Center"
        // align = "Left"
        // align = "Right"
//        baseline = "Top"
         baseline = "Bottom"
//        baseline = "Middle"
        borderPerLine = true
        
        borderLineWidth = CGFloat(4.0)
        borderColor    = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).CGColor
        backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5).CGColor
        shadowColor = UIColor(red: 0.2, green: 0.2, blue: 0.0, alpha: 1.0).CGColor
        lineHeight = CGFloat(10)
        kerning = CGFloat(2.0)
        
        let fontItal = CTFontCreateWithName("Georgia-Italic", fontSize, nil)
        let fontBold = CTFontCreateWithName("Helvetica-Bold", fontSize, nil)
        
        //apply the current text style
        let sKeyAttributeName : String = (kCTFontAttributeName as NSString) as String
        let sForegroundColorAttributeName : String = (kCTForegroundColorAttributeName as NSString) as String
        let sKerningName : String = (kCTKernAttributeName as NSString) as String
        var textFont = [ sKeyAttributeName: fontCT!,    sForegroundColorAttributeName: fontColor!]
        var italFont = [ sKeyAttributeName: fontItal!,  sForegroundColorAttributeName: fontColor!]
        var boldFont = [ sKeyAttributeName: fontBold!,  sForegroundColorAttributeName: fontColor!]
        if kerning > 0 {
            textFont = [ sKeyAttributeName: fontCT!,    sForegroundColorAttributeName: fontColor!, sKerningName: kerning ]
            italFont = [ sKeyAttributeName: fontItal!,  sForegroundColorAttributeName: fontColor!, sKerningName: kerning]
            boldFont = [ sKeyAttributeName: fontBold!,  sForegroundColorAttributeName: fontColor!, sKerningName: kerning]
        }
        
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
        if useLineHeight {
            let lineSpacing = lineHeight - getLineHeight(fontCT!)
            paraStyle.lineSpacing = lineSpacing
        }
        if align == "Left" {
            paraStyle.alignment = NSTextAlignment.Left
        }
        else if align == "Right" {
            paraStyle.alignment = NSTextAlignment.Right
        }
        else { // default center
            paraStyle.alignment = NSTextAlignment.Center
        }
        
        // Apply paragraph styles to paragraph
        para.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0,length: para.length))
        
        //        let expectedLabelSize = (text + " attributed" + " strings.").sizeWithFont([UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    
    }
    
    func setPathBasedOnBaseline(bounds: CGRect) -> CGMutablePath {
        let leading = floor( CTFontGetLeading(fontCT) + 0.5)
        let ascent = floor( CTFontGetAscent(fontCT) + 0.5)
        let descent = floor( CTFontGetDescent(fontCT) + 0.5)
        var lineHeight = ascent + descent + leading
        var ascenderDelta = CGFloat(0)
        if leading > 0 {
            ascenderDelta = 0
        }
        else {
            ascenderDelta = floor( 0.25 * lineHeight + 0.5 )
        }
        lineHeight = lineHeight + ascenderDelta
        
        
        var path = CGPathCreateMutable()
        if (baseline == "Top") {
            println("baseline top bounds \(bounds)")
            CGPathAddRect(path, nil, bounds) // Draw normally (top)
            backgroundBounds = CGRectMake(bounds.origin.x, bounds.origin.y + lineHeight, boundingBox.width, boundingBox.height + ascenderDelta)
        }
        else if (baseline == "Middle") {
            //Get the position on the y axis (middle)
            var midHeight = bounds.height / 2.0
            midHeight = midHeight - (boundingBox.height / 2.0)
            println("baseline middle midheight offset \(midHeight), bounds \(bounds) boundingBox \(boundingBox)")
            // - midHeight based on lower left origin
            CGPathAddRect(path, nil, CGRectMake(bounds.origin.x, bounds.origin.y - midHeight, bounds.width, bounds.height))
            backgroundBounds = CGRectMake(bounds.origin.x, bounds.origin.y + lineHeight - midHeight, boundingBox.width, boundingBox.height + ascenderDelta)
            baselineAdjust = -midHeight
        }
        else {
            let bottomHeight = bounds.height - boundingBox.height
            println("baseline bottom bounds.height \(bounds.height) boundingBox.height \(boundingBox.height) bottomHeight offset \(bottomHeight)")
            // - bottomHeight based on lower left origin
            CGPathAddRect(path, nil, CGRectMake(bounds.origin.x, bounds.origin.y - bottomHeight, bounds.width, bounds.height));
            backgroundBounds = CGRectMake(bounds.origin.x, bounds.origin.y + lineHeight - bottomHeight, boundingBox.width, boundingBox.height + ascenderDelta)
            baselineAdjust = -bottomHeight
        }

        println("leading \(leading) ascent \(ascent) descent \(descent) lineHeight \(lineHeight) ascenderDelta \(ascenderDelta) backgroundBounds \(backgroundBounds)")
        
        return path
    }
    
    func autoSize(rect: CGRect,options : NSStringDrawingOptions) {
        
//        let frame = CTFramesetterCreateFrame(frameSetter!,CFRangeMake(0, 0), rect, nil)
//        let theSize = getTextSizeFromFrame(frame)
        
        
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
        else {
            // make it bigger
//            let widthScale = getScale(CGFloat(fontBoxWidth), v2: rect.width)
//            let heightScale = getScale(CGFloat(fontBoxHeight), v2: rect.height)
            let widthScale = CGFloat(fontBoxWidth)/rect.width
            let heightScale = CGFloat(fontBoxHeight)/rect.height
            let scale = min(widthScale,heightScale) * 0.85
            let newFontSize = scale * fontSize
            println("5 updating with new font size \(newFontSize)")
            self.setProperties(text,targetFontSize: newFontSize)
            var rect5 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
            boundingBox = CGRectMake(0,0,rect5.width + rect5.origin.x, rect5.height + rect5.origin.y)
//            boundingBox = CGRectMake(0,0,fontBoxWidth,fontBoxHeight)
            println("rect5 \(rect5) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) using boundingbox \(boundingBox)")
        }
    }
    
    
    func handleMaxTextLines(path: CGMutablePath) {
        let framesetter = CTFramesetterCreateWithAttributedString(para)
        //        let theSize = getTextSizeFromFrameSetter(framesetter)
        //        println("the size after creating framesetter \(theSize) boundingBox \(boundingBox)")
        
        let frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), path, nil)
        
        // handle max lines here?
        //        let lines = CTFrameGetLines(frame) as NSArray
        //        let numLines = CFArrayGetCount(lines)
    }
    
    func drawText(point: CGPoint) -> CGImage {
        //        UIGraphicsBeginImageContextWithOptions(CGSizeMake(fontBoxWidth,fontBoxHeight), false, 2.0)
        //        let context = UIGraphicsGetCurrentContext()
        
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
        
//        struct CGBitmapInfo : RawOptionSetType {
//            init(_ rawValue: UInt32)
//            init(rawValue: UInt32)
//            
//            static var AlphaInfoMask: CGBitmapInfo { get }
//            static var FloatComponents: CGBitmapInfo { get }
//            
//            static var ByteOrderMask: CGBitmapInfo { get }
//            static var ByteOrderDefault: CGBitmapInfo { get }
//            static var ByteOrder16Little: CGBitmapInfo { get }
//            static var ByteOrder32Little: CGBitmapInfo { get }
//            static var ByteOrder16Big: CGBitmapInfo { get }
//            static var ByteOrder32Big: CGBitmapInfo { get }

         // MVO pulled this from GPUImage
//        } else if (byteOrderInfo == kCGBitmapByteOrderDefault || byteOrderInfo == kCGBitmapByteOrder32Big) {
//            /* Big endian, for alpha-last we can use this bitmap directly in GL */
//            CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
//            if (alphaInfo != kCGImageAlphaPremultipliedLast && alphaInfo != kCGImageAlphaLast &&
//                alphaInfo != kCGImageAlphaNoneSkipLast) {
//                shouldRedrawUsingCoreGraphics = YES;
//            } else {
//                /* Can access directly using GL_RGBA pixel format */
//                format = GL_RGBA;
//            }
//        }
    
        // set buffer to big endian and alpha to premultiplied last for direct use in opengl maybe
        // http://stackoverflow.com/a/25773894/51700
        // mixed types struct, enum can't just | them
        var bitmapInfo : CGBitmapInfo = .ByteOrder32Big
        bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask
        bitmapInfo |= CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        
            // CGImageAlphaInfo.PremultipliedLast | CGBitmapInfo.ByteOrder32Big
        
        //        Tip:  When you create a bitmap graphics context, you’ll get the best performance
        //        if you make sure the data and bytesPerRow are 16-byte aligned.
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        
        var transform = CGAffineTransformIdentity
        //        transform = CGAffineTransformMakeRotation(CGFloat(90 * M_PI / 180.0))
        CGContextSetTextMatrix(context, transform)
        //        CGContextTranslateCTM(context, 0, CGFloat(height))
        //        CGContextScaleCTM(context, 1.0, -1.0)
        
        
        let options : NSStringDrawingOptions = .UsesFontLeading | .UsesLineFragmentOrigin | .UsesDeviceMetrics
        let rect = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
        // height
        println("rect \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect.width) height \(rect.height)")
        
        
        // Handle autoSizing Text to fit a rectangle
        // saw some tricks with UILabel to do this, set a huge font size and call adjustsFontSizeToFitWidth
        // https://developer.apple.com/library/ios/documentation/UIKit/Reference/UILabel_Class/index.html#//apple_ref/occ/instp/UILabel/adjustsFontSizeToFitWidth
        // but nothing equivalent for paragraph styles and CTFrames/core text
        
        if autoSizeEnabled {
            // handle maxlines here
            
            autoSize(rect, options: options)

        }
        else {
            // handle max lines here
            
            boundingBox = rect
        }

        // adjust fontBoxWidth/Height to rendered text
        println("before fontBoxWidth \(fontBoxWidth) fontBoxHeight \(fontBoxHeight)")
        fontBoxWidth = boundingBox.width
        var fontBoundingBox = CTFontGetBoundingBox(fontCT)
        fontBoxHeight = boundingBox.height + fontBoundingBox.height
//        fontBoxHeight = boundingBox.height
        println("after font bounding box \(fontBoundingBox), height \(fontBoundingBox.height) fontboxWidth \(fontBoxWidth) fontboxHeight \(fontBoxHeight)")
        
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        
        // scale example
        //        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), image)
        
        //        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        // set background to 0,0,0,0
        let fullRectangle = CGRectMake(CGFloat(0),CGFloat(0),CGFloat(fullWidth),CGFloat(fullHeight))
        CGContextSetFillColorWithColor(context,UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor)
        CGContextFillRect(context, fullRectangle)
        
        
//        let leading = floor( CTFontGetLeading(fontCT) + 0.5)
//        let ascent = floor( CTFontGetAscent(fontCT) + 0.5)
//        let descent = floor( CTFontGetDescent(fontCT) + 0.5)
//        var lineHeight = ascent + descent + leading
//        var ascenderDelta = CGFloat(0)
//        if leading > 0 {
//            ascenderDelta = 0
//        }
//        else {
//            ascenderDelta = floor( 0.2 * lineHeight + 0.5 )
//        }
//        lineHeight = lineHeight + ascenderDelta
        
        let bounds = CGRectMake(point.x, point.y, fontBoxWidth, fontBoxHeight)
        
        // text rendering time
        let path = setPathBasedOnBaseline(bounds)

        // text graphics if single box/outline
        if !borderPerLine {
//            backgroundBounds = CGRectMake(boundingBox.origin.x + point.x, boundingBox.origin.y + point.y + lineHeight, boundingBox.width, boundingBox.height + ascenderDelta)
            //            var backgroundBounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.width, bounds.height + ascenderDelta)
//            println("leading \(leading) ascent \(ascent) descent \(descent) lineHeight \(lineHeight) ascenderDelta \(ascenderDelta) backgroundBounds \(backgroundBounds)")
            CGContextSetFillColorWithColor(context,backgroundColor)
            CGContextFillRect(context, backgroundBounds)
            
            
            // then outline
            CGContextAddRect(context, backgroundBounds)
            CGContextSetStrokeColorWithColor(context, borderColor)
            CGContextSetLineWidth(context, borderLineWidth)
            CGContextStrokePath(context)
            
        }
        
        // drop shadow
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, CGSizeMake(shadowX, shadowY), shadowBlur, shadowColor)

        // framesetter
        let framesetter = CTFramesetterCreateWithAttributedString(para)
        let frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), path, nil)
        let theSize = getTextSizeFromFrame(frame)
        drawBackgroundPerLine(context,point: point, frame: frame)
        println("the size after creating frame \(theSize) boundingBox \(boundingBox)")
        
        // render text
        CTFrameDraw(frame, context)

        // return CGImage
        return CGBitmapContextCreateImage(context)
        
    }
    
    // didn't quite work out
    // the size after creating framesetter (170.78125, 266.0) boundingBox (0.0, 0.0, 179.671875, 257.6)
    func getTextSizeFromFrameSetter(frameSetter : CTFramesetterRef) -> CGSize {
        // method 1
        let maxSize = CGSizeMake(fontBoxWidth, 0)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, maxSize, nil)
        return size
    }
    
    
    // standardized method to compute rendered text bounding box
    // http://stackoverflow.com/a/9697647/51700
    func getTextSizeFromFrame(frame : CTFrameRef) -> CGSize {
        let framePath = CTFrameGetPath(frame)
        let frameRect = CGPathGetBoundingBox(framePath)
        
        let lines = CTFrameGetLines(frame) as NSArray
        let numLines = CFArrayGetCount(lines)
        
        var maxWidth : CGFloat = 0
        var textHeight : CGFloat = 0
        
        // Now run through each line determining the maximum width of all the lines.
        // We special case the last line of text. While we've got it's descent handy,
        // we'll use it to calculate the typographic height of the text as well.
        var lastLineIndex : CFIndex = numLines - 1
        for var index = 0; index < numLines; index++ {
            var ascent = CGFloat(0),
            descent = CGFloat(0),
            leading = CGFloat(0),
            width = CGFloat(0)
            let line = lines[0] as! CTLine
            //            CTLineGetTypographicBounds(line: CTLine!, ascent: UnsafeMutablePointer<CGFloat>, descent: UnsafeMutablePointer<CGFloat>, leading: UnsafeMutablePointer<CGFloat>)
            width = CGFloat(CTLineGetTypographicBounds(line, &ascent,  &descent, &leading))
            
            if width > maxWidth {
                maxWidth = width
            }
            
            if index == lastLineIndex {
                // Get the origin of the last line. We add the descent to this
                // (below) to get the bottom edge of the last line of text.
                var  lastLineOrigin : CGPoint = CGPointMake(0,0)
                CTFrameGetLineOrigins(frame, CFRangeMake(lastLineIndex, 1), &lastLineOrigin)
                
                // The height needed to draw the text is from the bottom of the last line
                // to the top of the frame.
                textHeight =  CGRectGetMaxY(frameRect) - lastLineOrigin.y + descent
            }
        }
        
        // For some text the exact typographic bounds is a fraction of a point too
        // small to fit the text when it is put into a context. We go ahead and round
        // the returned drawing area up to the nearest point.  This takes care of the
        // discrepencies.
        return CGSizeMake(ceil(maxWidth), ceil(textHeight));
    }
    
    func drawBackgroundPerLine(context : CGContext!, point: CGPoint, frame : CTFrameRef) {
        let framePath = CTFrameGetPath(frame)
        let frameRect = CGPathGetBoundingBox(framePath)
        
        let lines = CTFrameGetLines(frame) as NSArray
        let numLines = CFArrayGetCount(lines)
        
        for var index = 0; index < numLines; index++ {
            var ascent = CGFloat(0),
            descent = CGFloat(0),
            leading = CGFloat(0),
            width = CGFloat(0)
            let line = lines[index] as! CTLine
            //            CTLineGetTypographicBounds(line: CTLine!, ascent: UnsafeMutablePointer<CGFloat>, descent: UnsafeMutablePointer<CGFloat>, leading: UnsafeMutablePointer<CGFloat>)
            width = CGFloat(CTLineGetTypographicBounds(line, &ascent,  &descent, &leading) - CTLineGetTrailingWhitespaceWidth(line))
            ascent = floor(ascent + 0.5)
            descent = floor(descent + 0.5)
            leading = floor(leading + 0.5)
            var lineHeight = ascent + descent + leading
            var ascenderDelta = CGFloat(0)
            if leading > 0 {
                ascenderDelta = 0
            }
            else {
                ascenderDelta = floor( 0.25 * lineHeight + 0.5 )
            }
            lineHeight = lineHeight + ascenderDelta
            
            if borderPerLine {
                var  lineOrigin : CGPoint = CGPointMake(0,0)
                CTFrameGetLineOrigins(frame, CFRangeMake(index, 1), &lineOrigin)
                
                //                let bounds = CGRectMake(point.x + lineOrigin.x, point.y + lineOrigin.y - leading - (ascent+descent), width, ascent + descent)
                var xOffset = CGFloat(0.0)
                if align == "Center" {
                    var fontBoundingBox = CTFontGetBoundingBox(fontCT)
                    xOffset = fontBoundingBox.origin.x
                }
                let bounds = CGRectMake(point.x + lineOrigin.x, point.y + lineOrigin.y - descent + baselineAdjust, width, ascent + descent)
                
                println("line \(index) point \(point) lineOrigin \(lineOrigin) xoffset \(xOffset) width \(width) descent \(descent)")
                
                // background
                CGContextSetFillColorWithColor(context,backgroundColor)
                CGContextFillRect(context, bounds)
                
                
                // then outline
                CGContextAddRect(context, bounds)
                CGContextSetStrokeColorWithColor(context, borderColor)
                CGContextSetLineWidth(context, borderLineWidth)
                CGContextStrokePath(context)
            }
            
        }
    }
    
}


class ViewController: UIViewController {
    var textStyle  = CMTextStyle()
    

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textStyle.setProperties("I am a meat popsicle, no really that is precisely what I am", targetFontSize: CGFloat(32))
//        textStyle.setProperties("YO", targetFontSize: CGFloat(32))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textStyle.fullWidth = self.view.frame.width
        textStyle.fullHeight = self.view.frame.height
        self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let cgImage = textStyle.drawText(CGPointMake(CGFloat(100),CGFloat(50)))

        let image = UIImage(CGImage: cgImage)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRectMake(0,0,CGFloat(textStyle.fullWidth),CGFloat(textStyle.fullWidth))
        view.addSubview(imageView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

