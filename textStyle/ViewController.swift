//
//  CMTextStyle.swift
//  Cameo
//
//  Created by Mark Essel on 2/19/15.
//  Copyright (c) 2015 Cameo. All rights reserved.
//

import UIKit
import CoreText


let TS_DEFAULT_WIDTH    = CGFloat(200)
let TS_DEFAULT_HEIGHT   = CGFloat(100)
let TS_DEFAULT_FULL_WIDTH = CGFloat(1280)
let TS_DEFAULT_FULL_HEIGHT = CGFloat(720)
let SCALE_TO_FONT_SIZE = CGFloat(0.75)

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
            switch count(hex) {
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
    var lineHeight = CGFloat(0)
}


class CMTextStyle {
    var text = ""
    
    // fractional font box width, height
    var widthFraction = CGFloat(1.0)
    var heightFraction = CGFloat(1.0)
    var fontBoxWidth = TS_DEFAULT_WIDTH
    var fontBoxHeight = TS_DEFAULT_HEIGHT
    var boundingBox = CGRectMake(0, 0, TS_DEFAULT_WIDTH, TS_DEFAULT_HEIGHT)
    var backgroundBounds = CGRectMake(0, 0, TS_DEFAULT_WIDTH, TS_DEFAULT_HEIGHT)
    var baselineAdjust = CGFloat(0.0)
    var fullWidth = TS_DEFAULT_FULL_WIDTH
    var fullHeight = TS_DEFAULT_FULL_HEIGHT
    var nlines = 1
    
    var basefontCT : CTFontRef?
    var fontCT : CTFontRef? // used CTFont with traits set
    
    let options : NSStringDrawingOptions = .UsesFontLeading | .UsesLineFragmentOrigin | .UsesDeviceMetrics
    
    var fontFileBase = ""
    var fontFileExtension = "ttf"
    
    // all properties, see oFontProperties.json in cameo-montage-script
    // full width and height will scale just fontsize properties, 1080p 1.0, 720p
    var align = "Center"   // "Left", "Center", "Right"
    var autoSizeEnabled = true
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
    var lineSpacing = CGFloat(10)
    var shadowBlur = CGFloat(5.0)
    var shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
    var shadowX = CGFloat(3.0)
    var shadowY = CGFloat(3.0)
    var maxTextLines = Int(2)
    var useLineSpacing = false
    
    // fractional width height
    var x = CGFloat(0.0)
    var position = "Center"
    
    // point widht height
    var xPoint = CGFloat(0.0)
    
    var yFromTop = CGFloat(0.0)
    var yFromTopPoint = CGFloat(0.0)
    
    var para = NSMutableAttributedString()
    
    init() {
        
    }
    
    init(dict: Dictionary<String,AnyObject>) {
        setProperties(dict)
    }
    
    func setProperties(dict: Dictionary<String,AnyObject>) {
        if let vText : AnyObject = dict["text"] {
            self.text = vText as! String
        }
        if let vWidth : AnyObject = dict["width"] {
            self.widthFraction = CGFloat(vWidth as! Double)
        }
        if let vHeight : AnyObject = dict["height"] {
            self.heightFraction = CGFloat(vHeight as! Double)
        }
        if let vFullWidth : AnyObject = dict["fullWidth"] {
            self.fullWidth = CGFloat(vFullWidth as! Double)
        }
        if let vFullHeight : AnyObject = dict["fullHeight"] {
            self.fullHeight = CGFloat(vFullHeight as! Double)
        }
        if let vFontFileBase : AnyObject = dict["fontFileBase"] {
            self.fontFileBase = vFontFileBase as! String
        }
        if let vFontFileExtension : AnyObject = dict["fontFileExtension"] {
            self.fontFileExtension = vFontFileExtension as! String
        }
        if let vAlign : AnyObject = dict["align"] {
            self.align = vAlign as! String
        }
        if let vAutoSizeEnabled: AnyObject = dict["autoSizeEnabled"] {
            self.autoSizeEnabled = vAutoSizeEnabled as! Bool
        }
        if let vAutoSizeMax : AnyObject = dict["autoSizeMax"] {
            self.autoSizeMax = CGFloat(vAutoSizeMax as! Double)
        }
        if let vAutoSizeMin : AnyObject = dict["autoSizeMin"] {
            autoSizeMin = CGFloat(vAutoSizeMin as! Double)
        }
        if let vBackgroundColor : AnyObject = dict["backgroundColor"] {
            var sBackgroundtColor = vBackgroundColor as! String
            let colors = colorStringToVals(sBackgroundtColor)
            self.backgroundColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vBaseline : AnyObject = dict["baseline"] {
            self.baseline = vBaseline as! String
        }
        if let vBorderColor : AnyObject = dict["borderColor"] {
            var sBordertColor = vBorderColor as! String
            let colors = colorStringToVals(sBordertColor)
            self.borderColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vBorderLineWidth : AnyObject = dict["borderLineWidth"] {
            self.borderLineWidth = CGFloat(vBorderLineWidth as! Double)
        }
        if let vBorderOutline : AnyObject = dict["borderOutline"] {
            self.borderOutline = vBorderOutline as! Bool
        }
        if let vBorderPadding : AnyObject = dict["borderPadding"] {
            self.borderPadding = CGFloat(vBorderPadding as! Double)
        }
        if let vBorderPerLine : AnyObject = dict["borderPerLine"] {
            self.borderPerLine = vBorderPerLine as! Bool
        }
        if let vBorderShadowBlur : AnyObject = dict["borderShadowBlur"] {
            self.borderShadowBlur = CGFloat(vBorderShadowBlur as! Double)
        }
        if let vBorderShadowColor : AnyObject = dict["borderShadowColor"] {
            var sBorderShadowColor = vBorderShadowColor as! String
            let colors = colorStringToVals(sBorderShadowColor)
            self.borderShadowColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vBorderShadowX : AnyObject = dict["borderShadowX"] {
            self.borderShadowX = CGFloat(vBorderShadowX as! Double)
        }
        if let vBorderShadowY : AnyObject = dict["borderShadowY"] {
            self.borderShadowY = CGFloat(vBorderShadowY as! Double)
        }
        if let vCapsAll : AnyObject = dict["capsAll"] {
            self.capsAll = vCapsAll as! Bool
        }
        if let vCapsFirst : AnyObject = dict["capsFirst"] {
            self.capsFirst = vCapsFirst as! Bool
        }
        if let vCapsLower : AnyObject = dict["capsLower"] {
            self.capsLower = vCapsLower as! Bool
        }
        if let vFont : AnyObject = dict["font"] {
            self.font = vFont as! String
        }
        if let vFontColor : AnyObject = dict["fontColor"] {
            var sFontColor = vFontColor as! String
            //            println("fontColor passed in \(sFontColor)")
            let colors = colorStringToVals(sFontColor)
            self.fontColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vFontSize : AnyObject = dict["fontSize"] {
            self.fontSize = CGFloat(vFontSize as! Double)
        }
        if let vFontSlant : AnyObject = dict["fontSlant"] {
            self.fontSlant = vFontSlant as! String
        }
        if let vFontWeight : AnyObject = dict["fontWeight"] {
            self.fontWeight = vFontWeight as! String
        }
        if let vKerning : AnyObject = dict["kerning"] {
            self.kerning = CGFloat(vKerning as! Double)
        }
        if let vLineSpacing : AnyObject = dict["lineSpacing"] {
            self.lineSpacing = CGFloat(vLineSpacing as! Double)
        }
        if let vShadowBlur : AnyObject = dict["shadowBlur"] {
            self.shadowBlur = CGFloat(vShadowBlur as! Double)
        }
        if let vShadowColor : AnyObject = dict["shadowColor"] {
            var sShadowColor = vShadowColor as! String
            let colors = colorStringToVals(sShadowColor)
            self.shadowColor = UIColor(red: colors.0, green: colors.1, blue: colors.2, alpha: colors.3).CGColor
        }
        if let vShadowX : AnyObject = dict["shadowX"] {
            self.shadowX = CGFloat(vShadowX as! Double)
        }
        if let vShadowY : AnyObject = dict["shadowY"] {
            self.shadowY = CGFloat(vShadowY as! Double)
        }
        if let vMaxTextLines : AnyObject = dict["maxTextLines"] {
            self.maxTextLines = vMaxTextLines as! Int
        }
        if let vUseLineSpacing : AnyObject = dict["useLineSpacing"] {
            self.useLineSpacing = vUseLineSpacing as! Bool
        }
        if let vX : AnyObject = dict["x"] {
            // fractional value
            self.x = CGFloat(vX as! Double)
        }
        if let vY : AnyObject = dict["y"] {
            // fractional value
            self.yFromTop = CGFloat(vY as! Double)
        }
        if let vPosition : AnyObject = dict["position"] {
            self.position = vPosition as! String
        }
        
        // need a CTFontCreateWithFile(), maybe https://developer.apple.com/library/mac/documentation/Carbon/Reference/CoreText_FontManager_Ref/index.html#//apple_ref/c/func/CTFontManagerIsSupportedFontFile
        // and a way to use italics if its available if italics is set for slant
        // and to use weight if its set
        
        if count(self.fontFileBase) > 0 {
            let fontURL = NSBundle.mainBundle().URLForResource(fontFileBase, withExtension: fontFileExtension)
            
            // couldn't find this via swift, checking error instead CTFontManagerIsSupportedFont( fontURL )
            
            let descriptors : Array = CTFontManagerCreateFontDescriptorsFromURL(fontURL)! as Array
            for desc in descriptors {
                self.basefontCT = CTFontCreateWithFontDescriptor(desc as! CTFontDescriptor, fontSize, nil)
                self.font = CTFontCopyFullName(basefontCT) as! String
                println("only loading first font \(font) from file (may need adjustment)")
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
        // scale fractional values by full width height to get point locations
        self.fontBoxWidth = self.widthFraction * self.fullWidth
        self.fontBoxHeight = self.heightFraction * self.fullHeight
        self.xPoint = self.x * self.fullWidth
        self.yFromTopPoint = self.yFromTop * self.fullHeight
        
        updateTextAndSize(self.text, targetFontSize: self.fontSize)
        
    }
    
    // not currently used
    func naturalWrapText(text : String) -> String
    {
        // space delimit words into array
        let wordsRaw = text.componentsSeparatedByString(" ")
        var outWords = [String]()
        
        let NWords = wordsRaw.count
        var nlines = Int( floor( sqrt(Double(NWords) )) )
        if nlines <= 0 {
            nlines = 1
        }
        if self.maxTextLines > 0 {
            if nlines > self.maxTextLines {
                nlines = self.maxTextLines
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
        
        // strip out "\n ", replace with "\n"
        return " ".join(outWords).stringByReplacingOccurrencesOfString("\n ", withString: "\n")
        
    }
    
    func getScale(v1: CGFloat, v2: CGFloat) -> CGFloat {
        var scale = (v1/v2) * SCALE_TO_FONT_SIZE
        if scale > self.autoSizeMax {
            scale = self.autoSizeMax
        }
        if scale < self.autoSizeMin {
            scale = self.autoSizeMin
        }
        return scale
    }
    
    func computeLineHeight(ascent: CGFloat, descent: CGFloat, ascenderDelta: CGFloat) -> CGFloat {
        return ceil(ascent + descent)
    }
    
    func getFontProperties(font: CTFontRef) -> CMFontProperties {
        
        let ascent = CTFontGetAscent(font)
        let descent = CTFontGetDescent(font)
        var leading = CTFontGetLeading(font)
        
        if leading < 0 {
            leading = 0
        }
        leading = floor (leading + 0.5)
        
        let calcLineHeight = floor (ascent + 0.5) + floor (descent + 0.5) + leading
        
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
        //        fontProperties.lineHeight = calcLineHeight + ascenderDelta
        fontProperties.lineHeight = self.computeLineHeight(ascent,descent:descent,ascenderDelta:ascenderDelta)
        
        
        return fontProperties
    }
    
    func getLineHeight(font: CTFontRef) -> CGFloat {
        let fontProperties = getFontProperties(font)
        return fontProperties.lineHeight
    }
    
    func applyParagraphStyle(p : NSMutableAttributedString, inText : String, mode : NSLineBreakMode) -> NSMutableAttributedString {
        let sKeyAttributeName : String = (kCTFontAttributeName as NSString) as String
        let sForegroundColorAttributeName : String = (kCTForegroundColorAttributeName as NSString) as String
        let sKerningName : String = (kCTKernAttributeName as NSString) as String
        var textFont = [ sKeyAttributeName: self.fontCT!,    sForegroundColorAttributeName: self.fontColor!]
        if self.kerning > 0 {
            textFont = [ sKeyAttributeName: self.fontCT!,    sForegroundColorAttributeName: self.fontColor!, sKerningName: self.kerning ]
        }
        
        let attrString1 = NSMutableAttributedString(string: inText, attributes: textFont as [NSObject : AnyObject])
        
        // Define paragraph styling
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineBreakMode = mode
        
        if self.useLineSpacing {
            paraStyle.lineSpacing = self.lineSpacing
        }
        else {
            paraStyle.lineSpacing = 0
        }
        
        paraStyle.paragraphSpacing = 0
        paraStyle.paragraphSpacingBefore = 0
        
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
    
    func getBaselineCorrect(containerDim : CGFloat, boundDim : CGFloat) -> CGFloat {
        var adjust = CGFloat(0)
        if (self.baseline == "Top") {
        }
        else if self.baseline == "Bottom" {
            adjust = containerDim - boundDim
        }
        else {
            adjust = (containerDim - boundDim) / 2.0
        }
        return adjust
    }
    
    func getFinalOffsets(xPointIn: CGFloat, yPointIn: CGFloat) -> CGPoint {
        var xFinalPoint = xPointIn
        var yFinalPoint = yPointIn
        
        var xFraction = CGFloat(0)
        var yFraction = CGFloat(0)
        
        switch self.position {
        case "FarNorth","North","Center","South","FarSouth":
            xFraction = 0.5 - (self.widthFraction  / 2.0); // 0.5 represents half of the stage width
        case "East","NorthEast","SouthEast":
            xFraction = 1 - self.widthFraction
        case "FarWest":
            xFraction = 0 - self.widthFraction
        case "FarEast":
            xFraction = 1
        default:
            // default to center
            xFraction = 0.5 - (self.widthFraction  / 2.0); // 0.5 represents half of the stage width
        }
        
        switch self.position {
        case "FarWest","West","Center","East","FarEast":
            yFraction = 0.5 - (self.heightFraction / 2.0); // 0.5 represents half of the stage height
        case "South","SouthWest","SouthEast":
            yFraction = 1 - self.heightFraction
        case "FarNorth":
            yFraction = 0 - self.heightFraction
        case "FarSouth":
            yFraction = 1
        default:
            yFraction = 0.5 - (self.heightFraction / 2.0); // 0.5 represents half of the stage height
        }
        println("position \(self.position) original width \(self.widthFraction) height \(self.heightFraction) xFraction \(xFraction) yFraction \(yFraction)")
        xFinalPoint += xFraction * self.fullWidth
        yFinalPoint += yFraction * self.fullHeight
        
        return CGPoint(x: xFinalPoint, y: yFinalPoint)
        
    }
    
    func updateTextAndSize(inText: String, targetFontSize: CGFloat) {
        
        
        // TBD check memory usage over time
        // http://stackoverflow.com/questions/8491841/memory-usage-grows-with-ctfontcreatewithname-and-ctframesetterref
        
        self.text = inText
        //        var lines = text.componentsSeparatedByString("\n")
        
        // case handling
        if self.capsAll {
            self.text = inText.uppercaseString
        }
        else if self.capsLower {
            self.text = inText.lowercaseString
        }
        else if self.capsFirst {
            self.text = inText.substringToIndex(advance(inText.startIndex, 1)).uppercaseString + inText.substringFromIndex(advance(inText.startIndex,1)).lowercaseString
        }
        else {
            self.text = inText
        }
        
        
        self.fontSize = targetFontSize
        
        // https://developer.apple.com/library/prerelease/ios/documentation/Carbon/Reference/CTFontRef/index.html
        self.basefontCT = CTFontCreateWithName(self.font, self.fontSize, nil)
        var fontTraits = CTFontGetSymbolicTraits(self.basefontCT)
        if self.fontSlant == "Italics" {
            fontTraits |= CTFontSymbolicTraits.ItalicTrait
        }
        if self.fontWeight == "Bold" {
            fontTraits |= CTFontSymbolicTraits.BoldTrait
        }
        self.fontCT = CTFontCreateCopyWithSymbolicTraits(self.basefontCT!, CGFloat(0.0), nil, fontTraits, fontTraits)
        
        self.para = NSMutableAttributedString()
        // this updates the computed lineHeight if useLineHeight is false
        
        //        self.para = applyParagraphStyle(self.para, inText: self.text, mode: NSLineBreakMode.ByWordWrapping)
        
        // manually line balancing words
        let wrapText = naturalWrapText(self.text)
        //        self.para = applyParagraphStyle(self.para, inText: self.text, mode: NSLineBreakMode.ByWordWrapping)
        
        var lines = wrapText.componentsSeparatedByString("\n")
        for (iline,line) in enumerate(lines) {
            var pad = "\n"
            var lineBreakMode = NSLineBreakMode.ByClipping
            //            if iline == (lines.count - 1) {
            //                pad = ""
            //                lineBreakMode = NSLineBreakMode.ByWordWrapping
            //            }
            println("iline \(iline) line \(line)")
            self.para = applyParagraphStyle(self.para, inText: line + pad, mode: lineBreakMode)
        }
        self.nlines = count(lines)
        
        
    }
    
    
    func getPathAndBaselines(tightTextBounds: CGRect, textBounds: CGRect) -> (CGMutablePath,CGFloat) {
        
        var path = CGPathCreateMutable()
        
        var aBaseLineAdjust = self.getBaselineCorrect(self.fontBoxHeight, boundDim: tightTextBounds.height)
        let fp = self.getFontProperties(fontCT!)
        var ctGlyph = CTFontGetGlyphWithName(fontCT!, "M")
        let glyphBoundingBox = withUnsafePointer(&ctGlyph) { pointer -> CGRect in
            return CTFontGetBoundingRectsForGlyphs(fontCT!, CTFontOrientation.OrientationDefault, pointer, nil, 1)
        }
        let glyphHeight = glyphBoundingBox.height
        let yTop = fp.ascent - glyphHeight
        aBaseLineAdjust -= yTop
        CGPathAddRect(path, nil, CGRectMake(textBounds.origin.x, textBounds.origin.y - aBaseLineAdjust, textBounds.width, textBounds.height))
        
        return (path,aBaseLineAdjust)
    }
    
    func autoSize() {
        let rect = self.getTextSizeFromParagraph(self.para)
        
        //        let frame = CTFramesetterCreateFrame(frameSetter!,CFRangeMake(0, 0), rect, nil)
        //        let theSize = getTextSizeFromFrame(frame)
        
        println("autoSize fontbox width \(fontBoxWidth) height \(fontBoxHeight) rect \(rect)")
        
        if rect.width > self.fontBoxWidth {
            let scale = getScale(CGFloat(self.fontBoxWidth),v2: rect.width)
            //            let scale = CGFloat(self.fontBoxWidth) / rect.width
            let newFontSize = scale * self.fontSize
            println("autoSize width > fontBoxWidth 1 updating with new font size \(newFontSize)")
            self.updateTextAndSize(self.text,targetFontSize: newFontSize)
            let rect2 = self.getTextSizeFromParagraph(self.para)
            //            let rect2 = para.boundingRectWithSize(CGSizeMake(self.fontBoxWidth,10000), options:  self.options, context: nil)
            println("autoSize rect2 \(rect) fontboxwidth,height \(self.fontBoxWidth) \(self.fontBoxHeight) rect width \(rect2.width) height \(rect2.height)")
            self.boundingBox = rect2
            if rect2.height > self.fontBoxHeight {
                let scale2 = getScale(CGFloat(self.fontBoxHeight),v2: rect2.height)
                let newFontSize = scale2 * self.fontSize
                println("autoSize 2 updating with new font size \(newFontSize)")
                self.updateTextAndSize(self.text,targetFontSize: newFontSize)
                let rect3 = self.getTextSizeFromParagraph(self.para)
                //                let rect3 = para.boundingRectWithSize(CGSizeMake(self.fontBoxWidth,10000), options:  self.options, context: nil)
                self.boundingBox = rect3
                println("autoSize rect3 \(rect) fontboxwidth,height \(fontBoxWidth) \(fontBoxHeight) rect width \(rect3.width) height \(rect3.height)")
            }
        }
        else if rect.height > self.fontBoxHeight {
            let scale = getScale(CGFloat(self.fontBoxHeight), v2: rect.height)
            let newFontSize = scale * self.fontSize
            println("autoSize height > fontBoxHeight 3 updating with new font size \(newFontSize)")
            self.updateTextAndSize(self.text,targetFontSize: newFontSize)
            let rect2 = self.getTextSizeFromParagraph(self.para)
            //            let rect2 = para.boundingRectWithSize(CGSizeMake(self.fontBoxWidth,10000), options:  self.options, context: nil)
            boundingBox = rect2
            println("autoSize rect2 \(rect) fontboxwidth,height \(self.fontBoxWidth) \(self.fontBoxHeight) rect width \(rect2.width) height \(rect2.height)")
            if rect2.width > self.fontBoxWidth {
                let scale2 = getScale(CGFloat(self.fontBoxWidth), v2: rect2.width)
                let newFontSize = scale2 * self.fontSize
                println("autoSize 4 updating with new font size \(newFontSize)")
                self.updateTextAndSize(self.text,targetFontSize: newFontSize)
                let rect3 = self.getTextSizeFromParagraph(self.para)
                //                let rect3 = para.boundingRectWithSize(CGSizeMake(fontBoxWidth,10000), options:  self.options, context: nil)
                self.boundingBox = rect3
                println("autoSize rect3 \(rect) fontboxwidth,height \(self.fontBoxWidth) \(self.fontBoxHeight) rect width \(rect3.width) height \(rect3.height)")
            }
            
        }
        else {
            // make it bigger
            let widthScale = self.fontBoxWidth/rect.width
            let heightScale = self.fontBoxHeight/rect.height
            let scale = min(widthScale,heightScale) * SCALE_TO_FONT_SIZE
            let newFontSize = scale * self.fontSize
            println("autoSize 5 updating with new font size \(newFontSize)")
            self.updateTextAndSize(self.text,targetFontSize: newFontSize)
            let rect5 = self.getTextSizeFromParagraph(self.para)
            //            var rect5 = para.boundingRectWithSize(CGSizeMake(self.fontBoxWidth,10000), options:  self.options, context: nil)
            self.boundingBox = CGRectMake(0,0,rect5.width + rect5.origin.x, rect5.height)
            println("autoSize rect5 \(rect5) fontboxwidth,height \(self.fontBoxWidth) \(self.fontBoxHeight) using container bounds \(self.boundingBox)")
        }
        //        }
    }
    
    
    func drawText() -> CGImage {
        
        var width = Int(self.fullWidth)
        var height = Int(self.fullHeight)
        // ensure even width height, hopefully that will lead to 16-byte alignment below, might need powers of 2 for efficient texture map
        if (width % 2) != 0 {
            width++
        }
        if (height % 2) != 0 {
            height++
        }
        
        let bitsPerComponent : Int = 8
        let bytesPerRow : Int = 4 * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // misc notes on bitmap info https://gist.github.com/victusfate/6c64a0ed9325ff42d3bb
        var bitmapInfo : CGBitmapInfo = .ByteOrder32Big
        bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask
        bitmapInfo |= CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        // CGImageAlphaInfo.PremultipliedLast | CGBitmapInfo.ByteOrder32Big
        
        //        Tip:  When you create a bitmap graphics context, you’ll get the best performance
        //        if you make sure the data and bytesPerRow are 16-byte aligned.
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        
        var transform = CGAffineTransformIdentity
        CGContextSetTextMatrix(context, transform)
        
        
        var rect = self.getTextSizeFromParagraph(self.para)
        //        var rect = self.para.boundingRectWithSize(CGSizeMake(self.fontBoxWidth,10000), options:  self.options, context: nil)
        
        
        
        if self.autoSizeEnabled {
            self.autoSize()
        }
        else {
            self.boundingBox = rect
        }
        
        var fontBoundingBox = CTFontGetBoundingBox(self.fontCT)
        let fontProperties = getFontProperties(self.fontCT!)
        
        //        self.boundingBox = para.boundingRectWithSize(CGSizeMake(self.fontBoxWidth,10000), options:  self.options, context: nil)
        
        // had an issue where the bounding box was clipping the last line
        println("bounding box \(self.boundingBox) fontProperties ascent \(fontProperties.ascent) descent \(fontProperties.descent) leading \(fontProperties.leading) ascenderDelta \(fontProperties.ascenderDelta)")
        
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        
        // set background to 0,0,0,0
        let fullRectangle = CGRectMake(CGFloat(0),CGFloat(0),CGFloat(self.fullWidth),CGFloat(self.fullHeight))
        CGContextSetFillColorWithColor(context,UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).CGColor)
        CGContextFillRect(context, fullRectangle)
        
        
        
        //        let yPoint = self.fullHeight - (self.yFromTopPoint + self.fontBoxHeight)
        var point = getFinalOffsets(self.xPoint,yPointIn: self.yFromTopPoint)
        println("final offset point into full width/height \(point)")
        
        // debug show fontbox
        CGContextSetFillColorWithColor(context,UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.5).CGColor)
        CGContextFillRect(context, CGRectMake(point.x,point.y,self.fontBoxWidth,self.fontBoxHeight))
        
        let bounds = CGRectMake(point.x, point.y, self.fontBoxWidth, self.fontBoxHeight)
        
        // text rendering time
        //        let aPathAndBaselines = self.getPathAndBaselines(self.boundingBox, textBounds: bounds)
        let aPathAndBaselines = self.getPathAndBaselines(self.boundingBox, textBounds: bounds)
        let path = aPathAndBaselines.0
        self.baselineAdjust = aPathAndBaselines.1
        
        println("final path and baseline adjust \(self.baselineAdjust)")
        
        // framesetter
        let framesetter = CTFramesetterCreateWithAttributedString(self.para)
        let frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), path, nil)
        
        drawBackgroundPerLineAndComputeBounds(context,point: point, frame: frame)
        
        if !borderPerLine {
            CGContextSetFillColorWithColor(context,self.backgroundColor)
            CGContextFillRect(context, self.backgroundBounds)
            
            if self.borderLineWidth > 0  {
                // drop shadow
                CGContextSaveGState(context)
                CGContextSetShadowWithColor(context, CGSizeMake(self.shadowX, self.shadowY), self.shadowBlur, self.shadowColor)
                
                // then outline
                CGContextAddRect(context, self.backgroundBounds)
                CGContextSetStrokeColorWithColor(context, self.borderColor)
                CGContextSetLineWidth(context, self.borderLineWidth)
                CGContextStrokePath(context)
            }
        }
        
        // drop shadow
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, CGSizeMake(self.shadowX, self.shadowY), self.shadowBlur, self.shadowColor)
        
        
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
    
    
    func getTextSizeFromParagraph(aParagraph : NSMutableAttributedString ) -> CGRect {
        
        let bounds = CGRectMake(0, 0, self.fontBoxWidth, self.fontBoxHeight)
        let aPathAndBaselines = self.getPathAndBaselines(bounds, textBounds: bounds)
        let aPath = aPathAndBaselines.0
        let aBaselineAdjust = aPathAndBaselines.1
        println("getTextSizeFromParagraph bounds \(bounds) aPath \(aPath) baseline adjust \(aBaselineAdjust)")
        
        let framesetter = CTFramesetterCreateWithAttributedString(aParagraph)
        let frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0), aPath, nil)
        let framePath = CTFrameGetPath(frame)
        let frameRect = CGPathGetBoundingBox(framePath)
        println("getTextSizeFromParagraph frameRect \(frameRect)")
        
        let lines = CTFrameGetLines(frame) as NSArray
        let numLines = CFArrayGetCount(lines)
        
        var minX = CGFloat(0)
        var maxX = CGFloat(0)
        var minY = CGFloat(0)
        var maxY = CGFloat(0)
        
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
            lineHeight = self.computeLineHeight(ascent,descent:descent,ascenderDelta:ascenderDelta)
            // lets base line height on capital M
            
            var ctGlyph = CTFontGetGlyphWithName(fontCT!, "M")
            let glyphBoundingBox = withUnsafePointer(&ctGlyph) { pointer -> CGRect in
                return CTFontGetBoundingRectsForGlyphs(fontCT!, CTFontOrientation.OrientationDefault, pointer, nil, 1)
            }
            lineHeight = glyphBoundingBox.height
            
            
            var  lineOrigin : CGPoint = CGPointMake(0,0)
            CTFrameGetLineOrigins(frame, CFRangeMake(index, 1), &lineOrigin)
            
            let bounds = CGRectMake(lineOrigin.x - self.borderPadding, lineOrigin.y + aBaselineAdjust - self.borderPadding, width + 2*self.borderPadding, lineHeight + 2*self.borderPadding)
            
            // update overall background bounding box from individual drawn glyphs
            if index == 0 {
                minX = bounds.origin.x
                maxX = minX + bounds.width
                minY = bounds.origin.y
                maxY = minY + bounds.height
            }
            else {
                if bounds.origin.x < minX {
                    minX = bounds.origin.x
                }
                if (bounds.origin.x + bounds.width) > maxX {
                    maxX = bounds.origin.x + bounds.width
                }
                if bounds.origin.y < minY {
                    minY = bounds.origin.y
                }
                if (bounds.origin.y + bounds.height) > maxY {
                    maxY = bounds.origin.y + bounds.height
                }
            }
            println("getTextSizeFromParagraph current line bounds \(bounds) minX \(minX) maxX \(maxX) minY \(minY) maxY \(maxY)")
        }
        return CGRectMake(minX,minY,maxX-minX,maxY-minY)
        
    }
    
    func drawBackgroundPerLineAndComputeBounds(context : CGContext!, point: CGPoint, frame : CTFrameRef) {
        let framePath = CTFrameGetPath(frame)
        let frameRect = CGPathGetBoundingBox(framePath)
        
        let lines = CTFrameGetLines(frame) as NSArray
        let numLines = CFArrayGetCount(lines)
        
        var minX = CGFloat(0)
        var maxX = CGFloat(0)
        var minY = CGFloat(0)
        var maxY = CGFloat(0)
        
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
            lineHeight = self.computeLineHeight(ascent,descent:descent,ascenderDelta:ascenderDelta)
            // lets base line height on capital M
            
            var ctGlyph = CTFontGetGlyphWithName(fontCT!, "M")
            let glyphBoundingBox = withUnsafePointer(&ctGlyph) { pointer -> CGRect in
                return CTFontGetBoundingRectsForGlyphs(fontCT!, CTFontOrientation.OrientationDefault, pointer, nil, 1)
            }
            lineHeight = glyphBoundingBox.height
            
            
            var  lineOrigin : CGPoint = CGPointMake(0,0)
            CTFrameGetLineOrigins(frame, CFRangeMake(index, 1), &lineOrigin)
            
            //                let bounds = CGRectMake(point.x + lineOrigin.x, point.y + lineOrigin.y - leading - (ascent+descent), width, ascent + descent)
            var xOffset = CGFloat(0.0)
            if align == "Center" {
                var fontBoundingBox = CTFontGetBoundingBox(self.fontCT)
                xOffset = fontBoundingBox.origin.x
            }
            
            let bounds = CGRectMake(point.x + lineOrigin.x - self.borderPadding, point.y + lineOrigin.y - self.baselineAdjust - self.borderPadding, width + 2*self.borderPadding, lineHeight + 2*self.borderPadding)
            
            
            // update overall background bounding box from individual drawn glyphs
            if index == 0 {
                minX = bounds.origin.x
                maxX = minX + bounds.width
                minY = bounds.origin.y
                maxY = minY + bounds.height
            }
            else {
                if bounds.origin.x < minX {
                    minX = bounds.origin.x
                }
                if (bounds.origin.x + bounds.width) > maxX {
                    maxX = bounds.origin.x + bounds.width
                }
                if bounds.origin.y < minY {
                    minY = bounds.origin.y
                }
                if (bounds.origin.y + bounds.height) > maxY {
                    maxY = bounds.origin.y + bounds.height
                }
            }
            
            //                println("line \(index) point \(point) lineOrigin \(lineOrigin) xoffset \(xOffset) width \(width) descent \(descent)")
            
            if self.borderPerLine  {
                // background
                CGContextSetFillColorWithColor(context,self.backgroundColor)
                CGContextFillRect(context, bounds)
                
                // drop shadow
                CGContextSaveGState(context)
                CGContextSetShadowWithColor(context, CGSizeMake(self.shadowX, self.shadowY), self.shadowBlur, self.shadowColor)
                
                
                // then outline
                CGContextAddRect(context, bounds)
                CGContextSetStrokeColorWithColor(context, self.borderColor)
                CGContextSetLineWidth(context, self.borderLineWidth)
                CGContextStrokePath(context)
            }
        }
        let finalWidth = min(fontBoxWidth,maxX-minX)
        self.backgroundBounds = CGRectMake(minX,minY,finalWidth,maxY-minY)
    }
    
}

class ViewController: UIViewController {
    var textStyle  = CMTextStyle()
    

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textStyle =  CMTextStyle(dict: [
//            "fullWidth" : 1920,
//            "fullHeight": 1080,
            "text": "This is a Demo Caption",
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
            "width" : 0.25, // font box width height
            "height" : 0.25,
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
            "borderColor" : "rgba(0,0,255,128)",
            "backgroundColor" : "rgba(0,255,0,128)",
            "shadowColor" : "rgba(51,51,0,255)",
            "lineHeight" : 60.0,
            "useLineHeight" : false,
            "kerning" : 2.0,
            "x" : 0.0,
            "y" : 0.0,
            "position": "Center"
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

