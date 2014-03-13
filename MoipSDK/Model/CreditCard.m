//
//  CreditCard.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "CreditCard.h"

@implementation CreditCard

- (NSString *) getBrand
{
    switch (self.brand)
    {
        case BrandVisa:
            return @"VISA";
            break;
        case BrandMasterCard:
            return @"MASTER";
            break;
        case BrandAmex:
            return @"AMEX";
            break;
        case BrandDinersClub:
            return @"DINERS";
            break;
        case BrandHipercard:
            return @"HIPERCARD";
            break;
        case BrandDiscover:
            return @"DISCOVER";
            break;
        case BrandUnknown:
            return @"UNKNOWN";
            break;
        default:
            return @"UNKNOWN";
            break;
    }
}

- (Brand) getBrandFromString:(NSString *)method
{
    if ([method isEqualToString:@"VISA"])
    {
        return BrandVisa;
    }
    
    return BrandUnknown;
}

@end
