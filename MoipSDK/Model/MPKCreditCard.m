//
//  CreditCard.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKCreditCard.h"

@implementation MPKCreditCard

- (NSString *) getMPKBrand
{
    switch (self.brand)
    {
        case MPKBrandVisa:
            return @"VISA";
            break;
        case MPKBrandMasterCard:
            return @"MASTER";
            break;
        case MPKBrandAmex:
            return @"AMEX";
            break;
        case MPKBrandDinersClub:
            return @"DINERS";
            break;
        case MPKBrandHipercard:
            return @"HIPERCARD";
            break;
        case MPKBrandDiscover:
            return @"DISCOVER";
            break;
        case MPKBrandUnknown:
            return @"UNKNOWN";
            break;
        default:
            return @"UNKNOWN";
            break;
    }
}

- (MPKBrand) getMPKBrandFromString:(NSString *)method
{
    if ([method isEqualToString:@"VISA"])
    {
        return MPKBrandVisa;
    }
    
    return MPKBrandUnknown;
}

@end
