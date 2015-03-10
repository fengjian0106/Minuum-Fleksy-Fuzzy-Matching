//
//  ViewController.m
//  classifyWords
//
//  Created by fengjian on 15/2/3.
//  Copyright (c) 2015年 ziipin. All rights reserved.
//

#import "ViewController.h"
#import "FullKeyboardFuzzyMatchEngine.h"

@interface ViewController ()
@property(nonatomic, strong) FullKeyboardFuzzyMatchEngine *fuzzyMatchEngine;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)textFieldEditingChanged:(id)sender;
@end

@implementation ViewController
- (void)commonInit {
  _fuzzyMatchEngine = [FullKeyboardFuzzyMatchEngine new];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldEditingChanged:(id)sender {
  NSString *input = [((UITextField *)sender) text];
  NSLog(@"%s, %@", __FUNCTION__, input);

  NSArray *r = [self.fuzzyMatchEngine searchWithString:input];
  NSMutableString *text = [@"" mutableCopy];
  for (NSString *str in r) {
    [text appendString:str];
    [text appendString:@"\n"];
  }

  [self.textView setText:text];
}

@end
