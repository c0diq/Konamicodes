//
//  ViewController.m
//  Konamicodes
//
//  Created by Sylvain Rebaud on 12/28/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveCocoa;

#import "ViewModel.h"

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic) ViewModel *viewModel;
@property (readonly, nonatomic) NSCharacterSet *validCharacterSet;

@property (weak, nonatomic) IBOutlet UITextField *codeEntry;
@property (weak, nonatomic) IBOutlet UILabel *cheat;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _viewModel = [[ViewModel alloc] initWithCodes:@{
        @"Small Cheat": @[ @"A", @"B", @"A", @"B"],
        @"Medium Cheat": @[ @"A", @"B", @"A", @"A", @"B"],
        @"Big Cheat": @[ @"A", @"B", @"A", @"A", @"B", @"B", @"B"]
    }];
    
    NSString *validCharacterSetString = @"abAB";
    _validCharacterSet = [NSCharacterSet characterSetWithCharactersInString:validCharacterSetString];
    
    _codeEntry.delegate = self;
    [_codeEntry becomeFirstResponder];
    
    RACChannelTo(self.viewModel, sequence) = self.codeEntry.rac_newTextChannel;
    RAC(self, cheat.text) = [RACObserve(self.viewModel, cheat) deliverOnMainThread];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark AUTPINEntryField <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Calculate the string that results from performing this operation
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Ensure the characters are from the valid set of characters
    return ([resultingString rangeOfCharacterFromSet:self.validCharacterSet.invertedSet].location == NSNotFound);
}

@end

NS_ASSUME_NONNULL_END
