//
//  ScrollableTextView.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 6/16/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "ScrollableTextView.h"
#import "UIScrollView+Scrollable.h"


@implementation ScrollableTextView

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.selectable = YES;
    [self makeScrollable];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.selectable = YES;
    [self makeScrollable];
    return self;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
    
    if (context.nextFocusedView == self) {
        [self addLeftRightFocusGuides];
    } else {
        [self removeLeftRightFocusGuides];
    }
}

@end
