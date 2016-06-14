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

@property (strong, nonatomic) TSMarkdownParser *parser;
@property (weak, nonatomic) IBOutlet UITextView *markdownInput;
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
    NSAttributedString *result = [self.parser attributedStringFromMarkdown:textView.text];
    self.markdownOutputLabel.attributedText = result;
    self.markdownOutputTextView.attributedText = result;
}

- (IBAction)switchOutput:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.markdownOutputLabel.hidden = NO;
        self.markdownOutputTextView.hidden = YES;
    } else {
        self.markdownOutputLabel.hidden = YES;
        self.markdownOutputTextView.hidden = NO;
    }
}

@end
