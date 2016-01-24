//
// Created by Tobias Sundstrand on 14-08-31.
// Copyright (c) 2014 Computertalk Sweden. All rights reserved.
//

#import "UIImage+Tests.h"
#import <objc/runtime.h>

@implementation UIImage (Tests)

+ (void)load {
    [self swizzleClassMethod];
}

+ (void)swizzleClassMethod {
    SEL originalSelector = @selector(imageNamed:);
    SEL newSelector = @selector(swizzled_imageNamed:);
    Method origMethod = class_getClassMethod([UIImage class], originalSelector);
    Method newMethod = class_getClassMethod([UIImage class], newSelector);
    Class class = object_getClass([UIImage class]);
    if (class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

+ (UIImage *)swizzled_imageNamed:(NSString *)imageName {
    return [self imageNamed:imageName extension:@"png"];
}

+ (UIImage *)imageNamed:(NSString *)imageName extension:(NSString *)extension {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"se.computertalk.TSMarkdownParser"];
    NSString *imagePath = [bundle pathForResource:imageName ofType:extension];
    return [UIImage imageWithContentsOfFile:imagePath];
}

@end