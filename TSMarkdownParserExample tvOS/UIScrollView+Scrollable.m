//
//  UIScrollView+Scrollable.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/16/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "UIScrollView+Scrollable.h"
#import <objc/runtime.h>


@implementation UIScrollView (Scrollable)

@dynamic leftRightPreferredFocusedView;

- (void)makeScrollable
{
    self.panGestureRecognizer.allowedTouchTypes = @[ @(UITouchTypeIndirect) ];
    self.directionalPressGestureRecognizer.enabled = YES;
}

- (void)setLeftRightPreferredFocusedView:(UIView *)leftRightPreferredFocusedView
{
    objc_setAssociatedObject(self, @selector(leftRightPreferredFocusedView), leftRightPreferredFocusedView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)leftRightPreferredFocusedView
{
    return objc_getAssociatedObject(self, @selector(leftRightPreferredFocusedView));
}

static char LEFT_GUIDE;
static char RIGHT_GUIDE;
static char TOP_GUIDE;
static char BOTTOM_GUIDE;
- (void)addLeftRightFocusGuides
{
    UIFocusGuide *leftGuide = [UIFocusGuide new];
    leftGuide.preferredFocusedView = self.leftRightPreferredFocusedView;
    objc_setAssociatedObject(self, &LEFT_GUIDE, leftGuide, OBJC_ASSOCIATION_ASSIGN);
    [self addLayoutGuide:leftGuide];
    [NSLayoutConstraint activateConstraints:@[ [leftGuide.rightAnchor constraintEqualToAnchor:self.leftAnchor],
                                               [leftGuide.heightAnchor constraintEqualToAnchor:self.heightAnchor],
                                               [leftGuide.widthAnchor constraintEqualToConstant:1],
                                               [leftGuide.topAnchor constraintEqualToAnchor:self.topAnchor] ]];
    UIFocusGuide *rightGuide = [UIFocusGuide new];
    rightGuide.preferredFocusedView = self.leftRightPreferredFocusedView;
    objc_setAssociatedObject(self, &RIGHT_GUIDE, rightGuide, OBJC_ASSOCIATION_ASSIGN);
    [self addLayoutGuide:rightGuide];
    [NSLayoutConstraint activateConstraints:@[ [rightGuide.leftAnchor constraintEqualToAnchor:self.rightAnchor],
                                               [rightGuide.heightAnchor constraintEqualToAnchor:self.heightAnchor],
                                               [rightGuide.widthAnchor constraintEqualToConstant:1],
                                               [rightGuide.topAnchor constraintEqualToAnchor:self.topAnchor] ]];
    UIFocusGuide *topGuide = [UIFocusGuide new];
    topGuide.preferredFocusedView = self;
    objc_setAssociatedObject(self, &TOP_GUIDE, topGuide, OBJC_ASSOCIATION_ASSIGN);
    [self.superview addLayoutGuide:topGuide];
    [NSLayoutConstraint activateConstraints:@[ [topGuide.bottomAnchor constraintEqualToAnchor:self.topAnchor],
                                               [topGuide.heightAnchor constraintEqualToConstant:1],
                                               [topGuide.widthAnchor constraintEqualToAnchor:self.widthAnchor],
                                               [topGuide.leftAnchor constraintEqualToAnchor:self.leftAnchor] ]];
    UIFocusGuide *bottomGuide = [UIFocusGuide new];
    bottomGuide.preferredFocusedView = self;
    objc_setAssociatedObject(self, &BOTTOM_GUIDE, bottomGuide, OBJC_ASSOCIATION_ASSIGN);
    [self.superview addLayoutGuide:bottomGuide];
    [NSLayoutConstraint activateConstraints:@[ [bottomGuide.topAnchor constraintEqualToAnchor:self.bottomAnchor],
                                               [topGuide.heightAnchor constraintEqualToConstant:1],
                                               [topGuide.widthAnchor constraintEqualToAnchor:self.widthAnchor],
                                               [bottomGuide.leftAnchor constraintEqualToAnchor:self.leftAnchor] ]];
}

- (void)removeLeftRightFocusGuides
{
    UIFocusGuide *leftGuide = objc_getAssociatedObject(self, &LEFT_GUIDE);
    if (leftGuide)
        [self removeLayoutGuide:leftGuide];
    UIFocusGuide *rightGuide = objc_getAssociatedObject(self, &RIGHT_GUIDE);
    if (rightGuide)
        [self removeLayoutGuide:rightGuide];
    UIFocusGuide *topGuide = objc_getAssociatedObject(self, &TOP_GUIDE);
    if (topGuide)
        [self.superview removeLayoutGuide:topGuide];
    UIFocusGuide *bottomGuide = objc_getAssociatedObject(self, &BOTTOM_GUIDE);
    if (bottomGuide)
        [self.superview removeLayoutGuide:bottomGuide];
}

@end
