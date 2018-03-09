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
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
// iOS 6 support
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
// iOS 7+, watchOS, tvOS
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
// macOS
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

#endif /* TSFontTraitMask_h */
