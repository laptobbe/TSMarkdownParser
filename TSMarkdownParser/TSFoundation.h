//
//  TSFoundation.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/16/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#ifndef TSFoundation_h
#define TSFoundation_h

#import "TargetConditionals.h"

#if TARGET_OS_IPHONE
// iOS, watchOS, tvOS
@import UIKit;
#else
// Compatibility with macOS
@import AppKit;
typedef NSColor UIColor;
typedef NSImage UIImage;
typedef NSFont UIFont;
typedef NSFontDescriptor UIFontDescriptor;
typedef NSFontSymbolicTraits UIFontDescriptorSymbolicTraits;
#endif

#ifndef NSFoundationVersionNumber10_10_Max
// Compatibility with Xcode 7
#define NSFoundationVersionNumber10_10_Max 1199
#endif

#ifndef NS_EXTENSIBLE_STRING_ENUM
// Compatibility with Xcode 7
#define NS_EXTENSIBLE_STRING_ENUM
#endif

// Testing Xcode version (https://stackoverflow.com/a/46927445/1033581)
#if __clang_major__ < 9
// Compatibility with Xcode 8-
typedef NSString * NSAttributedStringKey NS_EXTENSIBLE_STRING_ENUM;
#endif

#endif /* TSFoundation_h */
