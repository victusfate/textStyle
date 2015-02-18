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

// https://github.com/yeahdongcn/UIColor-Hex-Swift/blob/master/UIColorExtension.swift
func colorStringToVals(rgba: String) -> (r: CGFloat,g: CGFloat,b: CGFloat,a: CGFloat) {
    var red:   CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue:  CGFloat = 0.0
    var alpha: CGFloat = 1.0
    
    if rgba.hasPrefix("#") {
        let index   = advance(rgba.startIndex, 1)
        let hex     = rgba.substringFromIndex(index)
        let scanner = NSScanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexLongLong(&hexValue) {
            switch (count(hex)) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print("Invalid RGB string \(rgba), number of characters after '#' should be either 3, 4, 6 or 8, default color used rgba(0,0,0,1)")
            }
        } else {
            println("Scan hex error from string \(rgba) default color used rgba(0,0,0,1)")
        }
    } else {
        if rgba.hasPrefix("rgba(") {
            let sInd = advance(rgba.startIndex,5)
            let eInd = advance(rgba.startIndex,count(rgba)-1)
            var num = rgba[sInd..<eInd]
            var loc = num.componentsSeparatedByString(",")
            if count(loc) < 4 {
                println("unable to find 4 color values from string \(rgba) default color used rgba(0,0,0,1)")
            }
            else {
                red = CGFloat(loc[0].toInt()!)/CGFloat(255.0)
                green = CGFloat(loc[1].toInt()!)/CGFloat(255.0)
                blue = CGFloat(loc[2].toInt()!)/CGFloat(255.0)
                alpha = CGFloat(loc[3].toInt()!)/CGFloat(255.0)
            }
        }
        else if rgba.hasPrefix("rgb(") {
            let sInd = advance(rgba.startIndex,4)
            let eInd = advance(rgba.startIndex,count(rgba)-1)
            var num = rgba[sInd..<eInd]
            var loc = num.componentsSeparatedByString(",")
            if count(loc) < 3 {
                println("unable to find 3 color values from string \(rgba) default color used rgba(0,0,0,1)")
            }
            else {
                red = CGFloat(loc[0].toInt()!)/CGFloat(255.0)
                green = CGFloat(loc[1].toInt()!)/CGFloat(255.0)
                blue = CGFloat(loc[2].toInt()!)/CGFloat(255.0)
            }
            
        }
        else {
            println("String \(rgba)does not have #hex or rgb() or rgba() format default color used rgba(0,0,0,1)")
        }
    }
    return (red, green, blue, alpha)
}

class CMFontProperties : NSObject {
    var ascent = CGFloat(0)
    var descent = CGFloat(0)
    var leading = CGFloat(0)
    var ascenderDelta = CGFloat(0)
}


class CMTextStyle {
    var text = ""
    
    var fontBoxWidth = TS_DEFAULT_WIDTH
    var fontBoxHeight = TS_DEFAULT_HEIGHT
    var boundingBox = CGRectMake(0, 0, TS_DEFAULT_WIDTH, TS_DEFAULT_HEIGHT)
    var backgroundBounds = CGRectMake(0, 0, TS_DEFAULT_WIDTH, TS_DEFAULT_HEIGHT)
    var baselineAdjust = CGFloat(0.0)
    var fullWidth = TS_DEFAULT_FULL_WIDTH
    var fullHeight = TS_DEFAULT_FULL_HEIGHT
    
    var basefontCT : CTFontRef?
    var fontCT : CTFontRef? // used CTFont with traits set
    
    let options : NSStringDrawingOptions = .UsesFontLeading | .UsesLineFragmentOrigin | .UsesDeviceMetrics
    
    var fontFileBase = ""
    var fontFileExtension = "ttf"
    
    // all properties, see oFontProperties.json in cameo-montage-script
    // full width and height will scale just fontsize properties, 1080p 1.0, 720p
    var align = "Center"   // "Left", "Center", "Right"
    var autoSizeEnabled = false
    var autoSizeMax = CGFloat(10) // scale factor to nominal font size
    var autoSizeMin = CGFloat(0.25)
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
    var maxTextLines = Int(2)
    var useLineHeight = false
    
    var x = CGFloat(0.0)
    var y = CGFloat(0.0)
    
    var para = NSMutableAttributedString()
    
    init() {
        
    }

    init(dict: Dictionary<String,AnyObject>) {
        setProperties(dict)
    }
    
    func setProperties(dict: Dictionary<String,AnyObject>) {
        if let vText : AnyObject = dict["text"] {
            text = vText as! String
        }
        if let vWidth : AnyObject = dict["width"] {
             fontBoxWidth = CGFloat(vWidth as! Double)
        }
        if let vHeight : AnyObject = dict["height"] {
            fontBoxHeight = CGFloat(vHeight as! Double)
        }
        if let vFullWidth : AnyObject = dict["fullWidth"] {
            fullWidth = CGFloat(vFullWidth as! Double)
        }
        if let vFullHeight : AnyObject = dict["fullHeight"] {
            fullHeight = CGFloat(vFullHeight as! Double)
        }
        if let vFontFileBase : AnyObject = dict["fontFileBase"] {
            fontFileBase = vFontFileBase as! String
        }
        if let vFontFileExtension : AnyObject = dict["fontFileExtension"] {
            fontFileExtension = vFontFileExtension as! String
        }
        if let vAlign : AnyObject = dict["align"] {
            align = vAlign as! String
        }
        if let vAutoSizeEnabled: AnyObject = dict["autoSizeEnabled"] {
            autoSizeEnabled = vAutoSizeEnabled as! Bool
        }
        if let vAutoSizeMax : AnyObject = dict["autoSizeMax"] {
            autoSizeMax = CGFloat(vAutoSizeMax as! Double)
        }
        if let vAutoSizeMin : AnyObject = dict["autoSizeMin"] {
            autoSizeMin = CGFloat(vAutoSizeMin as! Double)
        }
        if let vBackgroundColor : AnyObject = dict["backgroundColor"] {
            var sBackgroundtColor = vBackgroundColor as! String
            let colors = colorStringToVals(sBackgroundtColor)
            backgroundColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vBaseline : AnyObject = dict["baseline"] {
            baseline = vBaseline as! String
        }
        if let vBorderColor : AnyObject = dict["borderColor"] {
            var sBordertColor = vBorderColor as! String
            let colors = colorStringToVals(sBordertColor)
            borderColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vBorderLineWidth : AnyObject = dict["borderLineWidth"] {
            borderLineWidth = CGFloat(vBorderLineWidth as! Double)
        }
        if let vBorderOutline : AnyObject = dict["borderOutline"] {
            borderOutline = vBorderOutline as! Bool
        }
        if let vBorderPadding : AnyObject = dict["borderPadding"] {
            borderPadding = CGFloat(vBorderPadding as! Double)
        }
        if let vBorderPerLine : AnyObject = dict["borderPerLine"] {
            borderPerLine = vBorderPerLine as! Bool
        }
        if let vBorderShadowBlur : AnyObject = dict["borderShadowBlur"] {
            borderShadowBlur = CGFloat(vBorderShadowBlur as! Double)
        }
        if let vBorderShadowColor : AnyObject = dict["borderShadowColor"] {
            var sBorderShadowColor = vBorderShadowColor as! String
            let colors = colorStringToVals(sBorderShadowColor)
            borderShadowColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vBorderShadowX : AnyObject = dict["borderShadowX"] {
            borderShadowX = CGFloat(vBorderShadowX as! Double)
        }
        if let vBorderShadowY : AnyObject = dict["borderShadowY"] {
            borderShadowY = CGFloat(vBorderShadowY as! Double)
        }
        if let vCapsAll : AnyObject = dict["capsAll"] {
            capsAll = vCapsAll as! Bool
        }
        if let vCapsFirst : AnyObject = dict["capsFirst"] {
            capsFirst = vCapsFirst as! Bool
        }
        if let vCapsLower : AnyObject = dict["capsLower"] {
            capsLower = vCapsLower as! Bool
        }
        if let vFont : AnyObject = dict["font"] {
            font = vFont as! String
        }
        if let vFontColor : AnyObject = dict["fontColor"] {
            var sFontColor = vFontColor as! String
            println("fontColor passed in \(sFontColor)")
            let colors = colorStringToVals(sFontColor)
            fontColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vFontSize : AnyObject = dict["fontSize"] {
            fontSize = CGFloat(vFontSize as! Double)
        }
        if let vFontSlant : AnyObject = dict["fontSlant"] {
            fontSlant = vFontSlant as! String
        }
        if let vFontWeight : AnyObject = dict["fontWeight"] {
            fontWeight = vFontWeight as! String
        }
        if let vKerning : AnyObject = dict["kerning"] {
            kerning = CGFloat(vKerning as! Double)
        }
        if let vLineHeight : AnyObject = dict["lineHeight"] {
            lineHeight = CGFloat(vLineHeight as! Double)
        }
        if let vShadowBlur : AnyObject = dict["shadowBlur"] {
            shadowBlur = CGFloat(vShadowBlur as! Double)
        }
        if let vShadowColor : AnyObject = dict["shadowColor"] {
            var sShadowColor = vShadowColor as! String
            let colors = colorStringToVals(sShadowColor)
            shadowColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vShadowX : AnyObject = dict["shadowX"] {
            shadowX = CGFloat(vShadowX as! Double)
        }
        if let vShadowY : AnyObject = dict["shadowY"] {
            shadowY = CGFloat(vShadowY as! Double)
        }
        if let vMaxTextLines : AnyObject = dict["maxTextLines"] {
            maxTextLines = vMaxTextLines as! Int
        }
        if let vUseLineHeight : AnyObject = dict["useLineHeight"] {
            useLineHeight = vUseLineHeight as! Bool
        }
        if let vX : AnyObject = dict["x"] {
            x = CGFloat(vX as! Double)
        }
        if let vY : AnyObject = dict["y"] {
            y = CGFloat(vY as! Double)
        }
        
        // need a CTFontCreateWithFile(), maybe https://developer.apple.com/library/mac/documentation/Carbon/Reference/CoreText_FontManager_Ref/index.html#//apple_ref/c/func/CTFontManagerIsSupportedFontFile
        // and a way to use italics if its available if italics is set for slant
        // and to use weight if its set
        
        if count(fontFileBase) > 0 {
            let fontURL = NSBundle.mainBundle().URLForResource(fontFileBase, withExtension: fontFileExtension)
            
            // couldn't find this via swift, checking error instead CTFontManagerIsSupportedFont( fontURL )
            
            let descriptors : Array = CTFontManagerCreateFontDescriptorsFromURL(fontURL)! as Array
            for desc in descriptors {
                basefontCT = CTFontCreateWithFontDescriptor(desc as! CTFontDescriptor, fontSize, nil)
                font = CTFontCopyFullName(basefontCT) as! String
                println("loading font \(font) from file")
                break;
            }
            
            // alternative method, wasn't error checking properly
            //            var error : Unmanaged<CFErrorRef>? = nil
            //            CTFontManagerRegisterFontsForURL(fontURL, CTFontManagerScope.Process, &error)
            //            if error != nil {
            ////                assert(false, "error loading font file \(fontFileBase) url \(fontURL), error \(error) ")
            //                println("error loading font file \(fontFileBase) url \(fontURL), error \(error?.takeRetainedValue())")
            //                font = "Helvetica"
            //            }
        }
        

        
        updateTextAndSize(text, targetFontSize: fontSize)
        
    }
    
    // not currently used
    func naturalWrapText(text : String) -> String
    {
        // space delimit words into array
        let wordsRaw = text.componentsSeparatedByString(" ")
        var outWords = [String]()
        
        let NWords = wordsRaw.count
        var nlines = Int( floor( sqrt(Double(NWords) )) )
        if maxTextLines > 0 {
            if nlines > maxTextLines {
                nlines = maxTextLines
            }
        }
        nlines = max(nlines,1)
        
        if nlines == 1 {
            outWords.append(text)
            return text
        }
        else {
            let targetWordsPerLine = Int( Double(NWords)/Double(nlines) + 0.5)
            var iWord = 0
            
            for var iline=1;iline < nlines;iline++ {
                
                for var jWord=0;jWord < targetWordsPerLine;jWord++ {
                    if wordsRaw.count > iWord {
                        outWords.append(wordsRaw[iWord++])
                    }
                }
                
                if wordsRaw.count > iWord {
                    if count(wordsRaw[iWord]) < 3 {
                        outWords.append(wordsRaw[iWord++])
                        outWords.append("\n")
                    }
                    else {
                        outWords.append("\n")
                    }
                }
            }
            // add all remaining words
            for var jWord=iWord;jWord < wordsRaw.count;jWord++ {
                outWords.append(wordsRaw[jWord])
            }
        }
        return " ".join(outWords)

    }

    func getScale(v1: CGFloat, v2: CGFloat) -> CGFloat {
        var scale = sqrt(v1/v2)
        if scale > autoSizeMax {
            scale = autoSizeMax
        }
        if scale < autoSizeMin {
            scale = autoSizeMin
        }
        return scale
    }

    func getFontProperties(font: CTFontRef) -> CMFontProperties {
        
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
        var fontProperties = CMFontProperties()
        fontProperties.ascent = ascent
        fontProperties.descent = descent
        fontProperties.leading = leading
        fontProperties.ascenderDelta = ascenderDelta
        
        return fontProperties
    }
    
    func getLineHeight(font: CTFontRef) -> CGFloat {
        let fontProperties = getFontProperties(font)
        
        let ascent = fontProperties.ascent
        let descent = fontProperties.descent
        var leading = fontProperties.leading
        
        let calcLineHeight = floor (ascent + 0.5) + floor (descent + 0.5) + leading;
        
        var ascenderDelta = fontProperties.ascenderDelta
        let defaultLineHeight = calcLineHeight + ascenderDelta
        return defaultLineHeight
    }
    
    func applyParagraphStyle(p : NSMutableAttributedString, inText : String, mode : NSLineBreakMode) -> NSMutableAttributedString {
        let sKeyAttributeName : String = (kCTFontAttributeName as NSString) as String
        let sForegroundColorAttributeName : String = (kCTForegroundColorAttributeName as NSString) as String
        let sKerningName : String = (kCTKernAttributeName as NSString) as String
        var textFont = [ sKeyAttributeName: fontCT!,    sForegroundColorAttributeName: fontColor!]
        if kerning > 0 {
            textFont = [ sKeyAttributeName: fontCT!,    sForegroundColorAttributeName: fontColor!, sKerningName: kerning ]
        }
        
        let attrString1 = NSMutableAttributedString(string: inText, attributes: textFont as [NSObject : AnyObject])
        
        // Define paragraph styling
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineBreakMode = mode

        if useLineHeight {
            let lineSpacing = lineHeight - getLineHeight(fontCT!)
            paraStyle.lineSpacing = lineSpacing
        }
        else {
            lineHeight = getLineHeight(fontCT!)
            println("updating lineHeight used to \(lineHeight)")
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
        attrString1.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0,length: attrString1.length))

        // Add locally formatted strings to paragraph
        p.appendAttributedString(attrString1)
        return p
    }
    
    func updateTextAndSize(inText: String, targetFontSize: CGFloat) {
   
        
        // TBD check memory usage over time
        // http://stackoverflow.com/questions/8491841/memory-usage-grows-with-ctfontcreatewithname-and-ctframesetterref
        
//        text = naturalWrapText(inText)
        text = inText
//        var lines = text.componentsSeparatedByString("\n")
        
        // case handling
        if capsAll {
            text = inText.uppercaseString
        }
        else if capsLower {
            text = inText.lowercaseString
        }
        else if capsFirst {
            text = inText.substringToIndex(advance(inText.startIndex, 1)).uppercaseString + inText.substringFromIndex(advance(inText.startIndex,1)).lowercaseString
        }
        else {
            text = inText
        }
        

        fontSize = targetFontSize
        
        // https://developer.apple.com/library/prerelease/ios/documentation/Carbon/Reference/CTFontRef/index.html
        basefontCT = CTFontCreateWithName(font, fontSize, nil)
        var fontTraits = CTFontGetSymbolicTraits(basefontCT)
        if fontSlant == "Italics" {
            fontTraits |= CTFontSymbolicTraits.ItalicTrait
        }
        if fontWeight == "Bold" {
            fontTraits |= CTFontSymbolicTraits.BoldTrait
        }
        fontCT = CTFontCreateCopyWithSymbolicTraits(basefontCT!, CGFloat(0.0), nil, fontTraits, fontTraits)

        para = NSMutableAttributedString()
        // this updates the computed lineHeight if useLineHeight is false
        para = applyParagraphStyle(para,inText: text, mode: NSLineBreakMode.ByWordWrapping)
    }
    
    func setPathBasedOnBaseline(textBounds: CGRect, containerBounds: CGRect) -> CGMutablePath {
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
            println("baseline top bounds \(textBounds)")
            CGPathAddRect(path, nil, textBounds) // Draw normally (top)
//            backgroundBounds = CGRectMake(textBounds.origin.x - borderPadding, textBounds.origin.y + lineHeight - borderPadding, containerBounds.width + 2*borderPadding, containerBounds.height + ascenderDelta + 2*borderPadding)
            backgroundBounds = CGRectMake(textBounds.origin.x - borderPadding, textBounds.origin.y - borderPadding, textBounds.width + 2*borderPadding, textBounds.height + 2*borderPadding)
        }
        else if (baseline == "Middle") {
            //Get the position on the y axis (middle)
            var midHeight = textBounds.height / 2.0
            midHeight = midHeight - (containerBounds.height / 2.0)
            println("baseline middle midheight offset \(midHeight), text bounds \(textBounds) container \(containerBounds)")
            // - midHeight based on lower left origin
            CGPathAddRect(path, nil, CGRectMake(textBounds.origin.x, textBounds.origin.y - midHeight, textBounds.width, textBounds.height))
//            backgroundBounds = CGRectMake(textBounds.origin.x - borderPadding, textBounds.origin.y + lineHeight - midHeight - borderPadding, containerBounds.width + 2*borderPadding, containerBounds.height + ascenderDelta + 2*borderPadding)
            backgroundBounds = CGRectMake(textBounds.origin.x - borderPadding, textBounds.origin.y - midHeight - borderPadding, textBounds.width + 2*borderPadding, textBounds.height + 2*borderPadding)
            baselineAdjust = -midHeight
        }
        else {
            let bottomHeight = textBounds.height - containerBounds.height
            println("baseline bottom text bounds.height \(textBounds.height) container.height \(containerBounds.height) bottomHeight offset \(bottomHeight)")
            // - bottomHeight based on lower left origin
            CGPathAddRect(path, nil, CGRectMake(textBounds.origin.x, textBounds.origin.y - bottomHeight, textBounds.width, textBounds.height));
//            backgroundBounds = CGRectMake(textBounds.origin.x - borderPadding, textBounds.origin.y + lineHeight - bottomHeight - borderPadding, containerBounds.width + 2*borderPadding, containerBounds.height + ascenderDelta + 2*borderPadding)
            backgroundBounds = CGRectMake(textBounds.origin.x - borderPadding, textBounds.origin.y - bottomHeight - borderPadding, textBounds.width + 2*borderPadding, textBounds.height + 2*borderPadding)
            baselineAdjust = -bottomHeight
        }

        println("leading \(leading) ascent \(ascent) descent \(descent) lineHeight \(lineHeight) ascenderDelta \(ascenderDelta) backgroundBounds \(backgroundBounds)")
        
        return path
    }
    
    func autoSize(rect: CGRect) {
        
//        let frame = CTFramesetterCreateFrame(frameSetter!,CFRangeMake(0, 0), rect, nil)
//        let theSize = getTextSizeFromFrame(frame)
        
        println("fontbox width \(fontBoxWidth) height \(fontBoxHeight) rect \(rect)")
        
        let clipHeight = CGFloat(maxTextLines) * lineHeight
        if rect.height > clipHeight {
            boundingBox = CGRectMake(boundingBox.origin.x,boundingBox.origin.y,boundingBox.width,clipHeight)
            let scale = getScale(CGFloat(clipHeight),v2: rect.height)
            let newFontSize = scale * fontSize
            println("clip check updating with new font size \(newFontSize)")
            self.updateTextAndSize(text,targetFontSize: newFontSize)
            let rect2 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
            println("clip check rect2 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect2.width) height \(rect2.height)")
            boundingBox = rect2
        }
        else {
            if rect.width > fontBoxWidth {
                let scale = getScale(CGFloat(fontBoxWidth),v2: rect.width)
    //            let scale = CGFloat(fontBoxWidth) / rect.width
                let newFontSize = scale * fontSize
                println("1 updating with new font size \(newFontSize)")
                self.updateTextAndSize(text,targetFontSize: newFontSize)
                let rect2 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
                println("rect2 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect2.width) height \(rect2.height)")
                boundingBox = rect2
                if rect2.height > fontBoxHeight {
                    let scale2 = getScale(CGFloat(fontBoxHeight),v2: rect2.height)
                    let newFontSize = scale2 * fontSize
                    println("2 updating with new font size \(newFontSize)")
                    self.updateTextAndSize(text,targetFontSize: newFontSize)
                    let rect3 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
                    boundingBox = rect3
                    println("rect3 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect3.width) height \(rect3.height)")
                }
            }
            else if rect.height > fontBoxHeight {
                let scale = getScale(CGFloat(fontBoxHeight), v2: rect.height)
                let newFontSize = scale * fontSize
                println("3 updating with new font size \(newFontSize)")
                self.updateTextAndSize(text,targetFontSize: newFontSize)
                let rect2 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
                boundingBox = rect2
                println("rect2 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect2.width) height \(rect2.height)")
                if rect2.width > fontBoxWidth {
                    let scale2 = getScale(CGFloat(fontBoxWidth), v2: rect2.width)
                    let newFontSize = scale2 * fontSize
                    println("4 updating with new font size \(newFontSize)")
                    self.updateTextAndSize(text,targetFontSize: newFontSize)
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
                self.updateTextAndSize(text,targetFontSize: newFontSize)
                var rect5 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
                boundingBox = CGRectMake(0,0,rect5.width + rect5.origin.x, rect5.height + rect5.origin.y)
    //            boundingBox = CGRectMake(0,0,fontBoxWidth,fontBoxHeight)
                println("rect5 \(rect5) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) using container bounds \(boundingBox)")
            }
        }
    }
    
    
    func drawText() -> CGImage {
        let point = CGPoint(x: x, y: y)
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
        
        
        var rect = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  options, context: nil)
        // height
        println("rect \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect.width) height \(rect.height)")
        



        
        // Handle autoSizing Text to fit a rectangle
        // saw some tricks with UILabel to do this, set a huge font size and call adjustsFontSizeToFitWidth
        // https://developer.apple.com/library/ios/documentation/UIKit/Reference/UILabel_Class/index.html#//apple_ref/occ/instp/UILabel/adjustsFontSizeToFitWidth
        // but nothing equivalent for paragraph styles and CTFrames/core text
        
        if autoSizeEnabled {
            autoSize(rect)
            // handle max lines
            let clipHeight = CGFloat(maxTextLines) * lineHeight
            if boundingBox.height > clipHeight {
                boundingBox = CGRectMake(boundingBox.origin.x,boundingBox.origin.y,boundingBox.width,clipHeight)
            }

        }
        else {
            // handle max lines here
            let clipHeight = CGFloat(maxTextLines) * lineHeight
            if rect.height > clipHeight {
                rect = CGRectMake(rect.origin.x,rect.origin.y,rect.width,clipHeight)
            }
            boundingBox = rect
        }
        var fontBoundingBox = CTFontGetBoundingBox(fontCT)
        let fontProperties = getFontProperties(fontCT!)
//        boundingBox = CGRectMake(boundingBox.origin.x,boundingBox.origin.y, boundingBox.width, boundingBox.height + fontProperties.ascenderDelta)
        boundingBox = CGRectMake(boundingBox.origin.x,boundingBox.origin.y, boundingBox.width, boundingBox.height + fontBoundingBox.height * 0.25)

        // adjust fontBoxWidth/Height to rendered text
        println("before fontBoxWidth \(fontBoxWidth) fontBoxHeight \(fontBoxHeight)")
        fontBoxWidth = boundingBox.width
        fontBoxHeight = boundingBox.height // gotta get this right
//        fontBoxHeight = boundingBox.height + lineHeight
//        fontBoxHeight = boundingBox.height + fontBoundingBox.height

        println("after font bounding box \(fontBoundingBox), height \(fontBoundingBox.height) fontboxWidth \(fontBoxWidth) fontboxHeight \(fontBoxHeight)")
        
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        
        // scale example
        //        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), image)
        
        //        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        // set background to 0,0,0,0
        let fullRectangle = CGRectMake(CGFloat(0),CGFloat(0),CGFloat(fullWidth),CGFloat(fullHeight))
        CGContextSetFillColorWithColor(context,UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor)
        CGContextFillRect(context, fullRectangle)
        
        let bounds = CGRectMake(point.x, point.y, fontBoxWidth, fontBoxHeight)
        
        // text rendering time
        let path = setPathBasedOnBaseline(bounds,containerBounds: boundingBox)
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
                let bounds = CGRectMake(point.x + lineOrigin.x - borderPadding, point.y + lineOrigin.y - descent + baselineAdjust - borderPadding, width + 2*borderPadding, ascent + descent + 2*borderPadding)
                
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
        textStyle = CMTextStyle(dict: [
            "text": "i am a meat popsicle, NO really that is precisely what I am",
            "fontColor" : "rgba(255,0,0,255)",
            "fontSize" : 32.0,
            "maxTextLines" : 10,
            //        "font" : "Helvetica",
            //        "fontFileBase" : "",
            "font" : "MuseoSans-900",
            "fontFileBase" : "MuseoSans-900",
            //        "font" : "Georgia Italic",
            //        "fontFileBase" : "Georgia Italic",
            "fontFileExtension" : "ttf",
            "fontBoxWidth" : 200,
            "fontBoxHeight" : 200,
            "fontSlant" : "Italics",  // "Normal", "Italics", "Oblique"
            "fontWeight" : "Normal", // "Lighter", "Normal", "Bold", "Bolder"
            "autoSizeEnabled" : false,
            "align" : "Center",
            // "align" : "Left",
            // "align" : "Right",
            // "baseline" : "Top",
            // "baseline" : "Bottom",
            "baseline" : "Middle",
            "borderPerLine" : false,
            "borderPadding" : 0.0,
            "borderLineWidth" : 4.0,
            "borderColor" : "rgba(0,0,255,255)",
            "backgroundColor" : "rgba(0,255,0,128)",
            "shadowColor" : "rgba(51,51,0,255)",
            "lineHeight" : 60.0,
            "useLineHeight" : false,
            "kerning" : 2.0,
            "x" : 100,
            "y" : 50
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textStyle.fullWidth = self.view.frame.width
        textStyle.fullHeight = self.view.frame.height
        self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let cgImage = textStyle.drawText()

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

