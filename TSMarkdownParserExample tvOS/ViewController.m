//
//  ViewController.m
//  TSMarkdownParser tvOS
//
//  Created by Antoine Cœur on 3/29/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "ViewController.h"
#import <TSMarkdownStandardParser.h>
#import "UIScrollView+Scrollable.h"


@interface ViewController ()

@property (strong, nonatomic) TSMarkupParser *parser;
@property (weak, nonatomic) IBOutlet UITextView *markdownInput;
@property (weak, nonatomic) IBOutlet UILabel *markdownOutputLabel;
@property (weak, nonatomic) IBOutlet UITextView *markdownOutputTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIScrollView *markdownOutputLabelScrollView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.parser = [TSMarkdownStandardParser new];
    
    _markdownOutputTextView.leftRightPreferredFocusedView = _segmentedControl;
    _markdownOutputLabelScrollView.leftRightPreferredFocusedView = _segmentedControl;
    
    // aligning output
    self.markdownOutputTextView.textContainer.lineFragmentPadding = -20.0;
    // updating output
    [self textViewDidChange:self.markdownInput];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSAttributedString *result = [self.parser attributedStringFromMarkup:textView.text];
    self.markdownOutputLabel.attributedText = result;
    self.markdownOutputTextView.attributedText = result;
    self.markdownOutputLabelScrollView.contentSize = self.markdownOutputLabel.intrinsicContentSize;
}

- (IBAction)switchOutput:(UISegmentedControl *)segmentedControl {
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            self.markdownOutputLabelScrollView.hidden = NO;
            self.markdownOutputTextView.hidden = YES;
            break;
        case 1:
            self.markdownOutputTextView.hidden = NO;
            self.markdownOutputLabelScrollView.hidden = YES;
            break;
    }
}

@end
