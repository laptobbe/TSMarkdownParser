//
//  TSHelper.h
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 03/05/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

@import Foundation;
#import "TSFoundation.h"
#import "TSFontTraitMask.h"

NS_ASSUME_NONNULL_BEGIN

NS_ROOT_CLASS
@interface TSHelper

+ (UIFont *)convertFont:(UIFont *)font toHaveTrait:(TSFontTraitMask)traits;
+ (UIFont *)convertFont:(UIFont *)font toNotHaveTrait:(TSFontTraitMask)traits;
+ (UIFont *)monospaceFontOfSize:(CGFloat)fontSize;

+ (nullable NSURL *)URLWithStringByAddingPercentEncoding:(NSString *)URLString;

/// Not thread safe on iOS 7/8 (see [UIImage imageNamed:] and [UIImage imageNamed:inBundle:compatibleWithTraitCollection:])
/// `resourceBundle` is unsupported on watchOS, iOS 7 or without <UIKit/UITraitCollection.h>
+ (nullable UIImage *)imageForResource:(NSString *)name bundle:(nullable NSBundle *)resourceBundle NS_AVAILABLE(10_7, 7_0);

@end

NS_ASSUME_NONNULL_END
