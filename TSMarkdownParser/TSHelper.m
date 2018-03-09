//
//  TSHelper.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 03/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "TSHelper.h"

@implementation TSHelper

+ (UIFont *)convertFont:(UIFont *)font toHaveTrait:(TSFontTraitMask)traits
{
#if !TARGET_OS_IPHONE
    return [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:traits];
#else
    // to support iOS6
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    // Testing availability of @available (https://stackoverflow.com/a/46927445/1033581)
#if __clang_major__ >= 9
    // iOS 7+ (/ macOS 10.9+) test compatible with Xcode 9+
    if (@available(macOS 10.9, iOS 7.0, watchOS 2.0, tvOS 9.0, *)) {
#else
    // iOS 7+ (/ macOS 10.9+) test compatible with Xcode 8-
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
#endif
#endif
        UIFontDescriptor *fontDescriptor = font.fontDescriptor;
        // making the new font
        return [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:fontDescriptor.symbolicTraits | traits] size:0];
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    } else {
        // iOS 6: CoreText font equivalent
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
#endif// !TARGET_OS_IPHONE
}

+ (UIFont *)convertFont:(UIFont *)font toNotHaveTrait:(TSFontTraitMask)traits
{
#if !TARGET_OS_IPHONE
    return [[NSFontManager sharedFontManager] convertFont:font toNotHaveTrait:traits];
#else
    // to support iOS6
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    // Testing availability of @available (https://stackoverflow.com/a/46927445/1033581)
#if __clang_major__ >= 9
    // iOS 7+ (/ macOS 10.9+) test compatible with Xcode 9+
    if (@available(macOS 10.9, iOS 7.0, watchOS 2.0, tvOS 9.0, *)) {
#else
    // iOS 7+ (/ macOS 10.9+) test compatible with Xcode 8-
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
#endif
#endif
        UIFontDescriptor *fontDescriptor = font.fontDescriptor;
        // making the new font
        return [UIFont fontWithDescriptor:[fontDescriptor fontDescriptorWithSymbolicTraits:fontDescriptor.symbolicTraits & ~traits] size:0];
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    } else {
        // iOS 6: CoreText font equivalent
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
#endif// !TARGET_OS_IPHONE
}

+ (UIFont *)monospaceFontOfSize:(CGFloat)fontSize
{
    // Courier New and Courier are the only monospace fonts compatible with watchOS 2
    UIFont *font = [UIFont fontWithName:@"Courier New" size:fontSize] ?: [UIFont fontWithName:@"Courier" size:fontSize];
    //if (font == nil)
    //    font = [UIFont monospacedDigitSystemFontOfSize:fontSize weight:UIFontWeightRegular];
    // #69: avoiding crash if font is missing
    if (font == nil)
        font = [UIFont systemFontOfSize:fontSize];
    return font;
}

/// #61: tries link and fallback for an unescaped link
+ (nullable NSURL *)URLWithStringByAddingPercentEncoding:(NSString *)link
{
    // TODO: use [link stringByAddingPercentEncodingWithAllowedCharacters:<#(nonnull NSCharacterSet *)#>];
    NSURL *url = [NSURL URLWithString:link] ?: [NSURL URLWithString:
                                                [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return url;
}

@end
