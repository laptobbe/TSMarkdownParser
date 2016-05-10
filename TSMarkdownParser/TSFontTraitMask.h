//
//  TSFontTraitMask.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 10/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#ifndef TSFontTraitMask_h
#define TSFontTraitMask_h

#if TARGET_OS_IPHONE
@import UIKit;
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
@import CoreText.CTFont;
typedef CTFontSymbolicTraits TSFontTraitMask;
typedef NS_OPTIONS(uint32_t, TSFontMask) {
    TSFontMaskItalic = kCTFontTraitItalic,
    TSFontMaskBold = kCTFontTraitBold,
    TSFontMaskExpanded = kCTFontTraitExpanded,
    TSFontMaskCondensed = kCTFontTraitCondensed,
    TSFontMaskMonoSpace = kCTFontTraitMonoSpace,
    TSFontMaskVertical = kCTFontTraitVertical,
    TSFontMaskUIOptimized = kCTFontTraitUIOptimized,
    TSFontMaskColorGlyphs = kCTFontTraitColorGlyphs,
    TSFontMaskComposite = kCTFontTraitComposite,
};
#else
typedef UIFontDescriptorSymbolicTraits TSFontTraitMask;
typedef NS_OPTIONS(uint32_t, TSFontMask) {
    TSFontMaskItalic = UIFontDescriptorTraitItalic,
    TSFontMaskBold = UIFontDescriptorTraitBold,
    TSFontMaskExpanded = UIFontDescriptorTraitExpanded,
    TSFontMaskCondensed = UIFontDescriptorTraitCondensed,
    TSFontMaskMonoSpace = UIFontDescriptorTraitMonoSpace,
    TSFontMaskVertical = UIFontDescriptorTraitVertical,
    TSFontMaskUIOptimized = UIFontDescriptorTraitUIOptimized,
    TSFontMaskTightLeading = UIFontDescriptorTraitTightLeading,
    TSFontMaskLooseLeading = UIFontDescriptorTraitLooseLeading,
};
#endif
#else
@import AppKit;
typedef NSColor UIColor;
typedef NSImage UIImage;
typedef NSFont UIFont;
typedef NSFontDescriptor UIFontDescriptor;
typedef NSFontSymbolicTraits UIFontDescriptorSymbolicTraits;
typedef NSFontTraitMask TSFontTraitMask;
typedef NS_OPTIONS(uint32_t, TSFontMask) {
    TSFontMaskItalic = NSItalicFontMask,
    TSFontMaskBold = NSBoldFontMask,
    TSFontMaskNarrow = NSNarrowFontMask,
    TSFontMaskExpanded = NSExpandedFontMask,
    TSFontMaskCondensed = NSCondensedFontMask,
    TSFontMaskSmallCaps = NSSmallCapsFontMask,
    TSFontMaskPoster = NSPosterFontMask,
    TSFontMaskCompressed = NSCompressedFontMask,
    TSFontMaskMonoSpace = NSFixedPitchFontMask,
};
#endif

/*
 typedef NS_OPTIONS(uint32_t, TSFontMask) {
 TSFontMaskItalic                    = 1u << 0,
 TSFontMaskBold                      = 1u << 1,
 //TSFontMaskUnbold                    = 1u << 2,
 //TSFontMaskNonStandardCharacterSet   = 1u << 3,
 TSFontMaskNarrow                    = 1u << 4,
 TSFontMaskExpanded                  = 1u << 5,     // expanded and condensed traits are mutually exclusive
 TSFontMaskCondensed                 = 1u << 6,     // expanded and condensed traits are mutually exclusive
 TSFontMaskSmallCaps                 = 1u << 7,
 TSFontMaskPoster                    = 1u << 8,
 TSFontMaskCompressed                = 1u << 9,
 TSFontMaskMonoSpace                 = 1u << 10,    // fixed-pitch
 TSFontMaskVertical                  = 1u << 11,
 TSFontMaskUIOptimized               = 1u << 12,
 TSFontMaskColorGlyphs               = 1u << 13,
 TSFontMaskComposite                 = 1u << 14,
 TSFontMaskTightLeading              = 1u << 15,
 TSFontMaskLooseLeading              = 1u << 16,
 //TSFontMaskUnitalic                  = 1u << 24,
 };
 */

#endif /* TSFontTraitMask_h */
