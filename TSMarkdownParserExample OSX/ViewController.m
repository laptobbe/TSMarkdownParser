//
//  ViewController.m
//  TSMarkdownParserExample macOS
//
//  Created by Antoine Cœur on 3/29/16.
//  Copyright © 2016 Computertalk Sweden. All rights reserved.
//

#import "ViewController.h"
#import <TSMarkdownStandardParser.h>


@interface ViewController () <NSTextViewDelegate>

@property (strong, nonatomic) TSMarkupParser *parser;
@property (unsafe_unretained) IBOutlet NSTextView *markdownInput;
@property (weak) IBOutlet NSTextField *markdownOutputTextField;
@property (unsafe_unretained) IBOutlet NSTextView *markdownOutputTextView;

@property (weak, nonatomic) IBOutlet NSScrollView *markdownOutputTextFieldScrollView;
@property (weak, nonatomic) IBOutlet NSScrollView *markdownOutputTextViewScrollView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.markdownInput.string = @"# header\n\
###### header\n\
* list, _emphasis_, *emphasis*\n\
++ list, __bold__, **bold**\n\
--- list, `code`, ``code``\n\
> quote\n\
>> quote\n\
\\# \\*escaping\\* \\_escaping\\_ \\`escaping\\`\n\
[link](http://example.net)\n\
http://example.net\n\
![image](markdown)";
    
    self.parser = [TSMarkdownStandardParser new];
    
    // updating output
    [self textViewDidChange:self.markdownInput];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark -

- (void)textDidChange:(NSNotification *)notification
{
    [self textViewDidChange:notification.object];
}

- (void)textViewDidChange:(NSTextView *)textView
{
    NSAttributedString *output = [self.parser attributedStringFromMarkup:textView.string];
    self.markdownOutputTextField.attributedStringValue = output;
    [self.markdownOutputTextView.textStorage setAttributedString:output];
}

- (IBAction)switchOutput:(NSSegmentedControl *)segmentedControl {
    switch (segmentedControl.selectedSegment) {
        case 0:
            self.markdownOutputTextViewScrollView.hidden = NO;
            self.markdownOutputTextFieldScrollView.hidden = YES;
            break;
        case 1:
            self.markdownOutputTextViewScrollView.hidden = YES;
            self.markdownOutputTextFieldScrollView.hidden = NO;
            break;
    }
}

@end
