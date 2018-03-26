//
//  ViewController.m
//  TSMarkdownParser
//
//  Created by Antoine Cœur on 24/01/2016.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "ViewController.h"
#import <TSMarkdownStandardParser.h>


@interface ViewController () <UITextViewDelegate>

@property (strong, nonatomic) TSMarkupParser *parser;
@property (weak, nonatomic) IBOutlet UITextView *markdownInput;
@property (weak, nonatomic) IBOutlet UIScrollView *markdownOutputLabelScrollView;
@property (weak, nonatomic) IBOutlet UILabel *markdownOutputLabel;
@property (weak, nonatomic) IBOutlet UITextView *markdownOutputTextView;

@end


@implementation ViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parser = [TSMarkdownStandardParser new];
    
    // aligning output
    self.markdownOutputTextView.textContainer.lineFragmentPadding = 0.0;
    // required for initial scroll position at 0: https://stackoverflow.com/a/48547604/1033581
    [self.markdownOutputTextView layoutIfNeeded];
    // updating output
    [self textViewDidChange:self.markdownInput];
    
    // accessory view
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.markdownInput action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    self.markdownInput.inputAccessoryView = toolbar;
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
