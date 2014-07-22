//
//  PKCardCVC.m
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import "MPKCardCVC.h"
#import "MPKUtilities.h"

@implementation MPKCardCVC {
@private
    NSString *_cvc;
}

+ (instancetype)cardCVCWithString:(NSString *)string
{
    return [[self alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString *)string
{
   if (self = [super init]) {
        // Strip non-digits
        if (string) {
            _cvc = [string stringByReplacingOccurrencesOfString:@"\\D"
                                                     withString:@""
                                                        options:NSRegularExpressionSearch
                                                          range:NSMakeRange(0, string.length)];
        } else {
            _cvc = [NSString string];
        }
    }
    return self;
}

- (NSString *)string
{
#warning FIX THIS BUG
//    return [MPKUtilities encryptData:_cvc keyTag:kPublicKeyName];
    return _cvc;
}

- (BOOL)isValid
{
    return _cvc.length >= 3 && _cvc.length <= 4;
}

- (BOOL)isValidWithType:(MPKCardType)type
{
    if (type == MPKCardTypeAmex) {
        return _cvc.length == 4;
    } else {
        return _cvc.length == 3;
    }
}

- (BOOL)isPartiallyValid
{
    return _cvc.length <= 4;
}

- (BOOL)isPartiallyValidWithType:(MPKCardType)type
{
    if (type == MPKCardTypeAmex) {
        return _cvc.length <= 4;
    } else {
        return _cvc.length <= 3;
    }
}

- (NSString *)formattedString
{
    return _cvc;
}

@end
