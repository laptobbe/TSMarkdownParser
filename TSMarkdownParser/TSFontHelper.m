//
//  TSFontHelper.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 03/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSFontHelper.h"

@implementation TSFontHelper

+ (UIFont *)convertFont:(UIFont *)font toHaveTrait:(TSFontTraitMask)traits
{
#if !TARGET_OS_IPHONE
    return [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:traits];
#else
    // to support iOS6
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        // CoreText font equivalent
        CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        // adding traits
        traits = CTFontGetSymbolicTraits(ctFont) | traits;
        CTFontRef newCTFont = CTFontCreateCopyWithSymbolicTraits(ctFont, 0.0, NULL, (CTFontSymbolicTraits)traits, (CTFontSymbolicTraits)traits);
        CFRelease(ctFont);
        // back to UIFont
        UIFont *newFont = [UIFont fontWithName:CFBridgingRelease(CTFontCopyPostScriptName(newCTFont)) size:CTFontGetSize(newCTFont)];
        CFRelease(newCTFont);
        return newFont;
    }
#endif
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    // making the new font
    return [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:fontDescriptor.symbolicTraits | traits] size:0];
#endif
}

+ (UIFont *)convertFont:(UIFont *)font toNotHaveTrait:(TSFontTraitMask)traits
{
    // to support iOS6
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        // CoreText font equivalent
        CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        // removing traits
        traits = CTFontGetSymbolicTraits(ctFont) & ~traits;
        CTFontRef newCTFont = CTFontCreateCopyWithSymbolicTraits(ctFont, 0.0, NULL, (CTFontSymbolicTraits)traits, (CTFontSymbolicTraits)traits);
        CFRelease(ctFont);
        // back to UIFont
        UIFont *newFont = [UIFont fontWithName:CFBridgingRelease(CTFontCopyPostScriptName(newCTFont)) size:CTFontGetSize(newCTFont)];
        CFRelease(newCTFont);
        return newFont;
    }
#endif
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    // making the new font
    return [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:fontDescriptor.symbolicTraits & ~traits] size:0];
}

@end
