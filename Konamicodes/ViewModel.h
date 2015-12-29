//
//  ViewModel.h
//  Konamicodes
//
//  Created by Sylvain Rebaud on 12/28/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveViewModel;

@interface ViewModel : RVMViewModel

/// Initializes a view model with Konami codes.
///
/// A code is defined by a sequence of input characters.
///
/// @param codes: A dictionary with the code as key and an array of characters
/// corresponding to the input sequence.
- (instancetype)initWithCodes:(NSDictionary *)codes;

/// The current input sequence
///
/// This property is KVO-compliant.
@property (readwrite, nonatomic, copy) NSString *sequence;

/// The last detected cheat
///
/// This property is KVO-compliant.
@property (readonly, nonatomic, strong) NSString *cheat;

@end
