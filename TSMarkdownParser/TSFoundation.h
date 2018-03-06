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
// macOS
@import AppKit;
typedef NSColor UIColor;
typedef NSImage UIImage;
typedef NSFont UIFont;
typedef NSFontDescriptor UIFontDescriptor;
typedef NSFontSymbolicTraits UIFontDescriptorSymbolicTraits;
#endif

#endif /* TSFoundation_h */
