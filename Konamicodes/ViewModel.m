//
//  ViewModel.m
//  Konamicodes
//
//  Created by Sylvain Rebaud on 12/28/15.
//  Copyright © 2015 Automatic Labs. All rights reserved.
//

@import ReactiveCocoa;

#import "ViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewModel ()

@property (nonatomic) NSDictionary *tree;
@property (nonatomic) NSString *cheat;

@end

@implementation ViewModel

#pragma mark - Lifecycle

- (instancetype)initWithCodes:(NSDictionary *)codes {
    self  = [super init];
    
    _tree = [self treeForCodes:codes];
    
    // Sends a dictionary
    [[[[[RACObserve(self, sequence)
        ignore:nil]
        doNext:^(id x) {
            self.cheat = @"";
        }]
        map:^(NSString *sequence) {
            return [[[[[self codeForSequence:sequence]
                doNext:^(NSDictionary *value) {
                    // reset sequence immediately if no known path in the tree
                    if (value == nil) self.sequence = nil;
                }]
                ignore:nil]
                map:^(NSDictionary *value) {
                    return value[@"code"];
                }]
                // Wait 300 ms for next character in case a longer sequence
                // exists.
                // Note: Entering an extra character when a valid code was detected
                // would invalidate it.
                delay:0.3];
        }]
        switchToLatest]
        subscribeNext:^(NSString *code) {
            // Send code if any was found
            if (code != nil) {
                self.cheat = code;
            }
            
            // reset sequence
            self.sequence = nil;
        }];
    
    return self;
}

#pragma mark - Private

/// A signal that returns a dictionary that may contain a cheat name as a
/// NSString encoded value for key @"code" if the sequence matched a valid
/// cheat.
- (RACSignal *)codeForSequence:(NSString *)sequence {
    return [RACSignal defer:^RACSignal *{
        NSDictionary *dictionary = [sequence.rac_sequence
            foldLeftWithStart:self.tree reduce:^(NSDictionary *accumulator, NSString *character) {
                return accumulator[character.uppercaseString];
            }];
        
        return [RACSignal return:dictionary];
    }];
}

- (NSDictionary *)combineSequence:(NSArray *)sequence code:(NSString *)code withRoot:(NSMutableDictionary *)root {
    NSMutableDictionary *leaf = [sequence.rac_sequence
        foldLeftWithStart:root reduce:^(NSMutableDictionary *accumulator, NSString *value) {
            // Look for an existing subtree with value for root
            NSDictionary *subTree = accumulator[value.uppercaseString];
            if (subTree == nil) {
                subTree = [NSMutableDictionary dictionary];
                accumulator[value.uppercaseString] = subTree;
            }
            
            return subTree;
        }];
    
    // Insert code into last leaf dictionary
    NSParameterAssert(leaf[@"code"] == nil);
    leaf[@"code"] = code;
    
    // Return root
    return root;
}

/// Create a tree representing all the sequences and codes encoded such that
/// the code value is associated to the NSString key "code" in the dictionary of
/// the leaf representing the last character of the sequence.
///
/// For example, the two following sequences
/// "foo": ["A", "B", "A"] & "bar": ["A", "B", "C"]
/// would yield the following tree
/// @{ "A": @{"B": @{"A": @{@"code": @"foo"}, "C": @{"code": @"bar"}}}}
- (NSDictionary *)treeForCodes:(NSDictionary *)codes {
    NSMutableDictionary *tree = [NSMutableDictionary dictionary];
    [[[codes.rac_sequence signalWithScheduler:[RACScheduler immediateScheduler]]
        map:^(RACTuple *codeAndSequence) {
            RACTupleUnpack(NSString *code, NSArray *sequence) = codeAndSequence;
            return [self combineSequence:sequence code:code withRoot:tree];
        }]
        subscribeCompleted:^{}];
    
    return tree;
}

@end

NS_ASSUME_NONNULL_END
