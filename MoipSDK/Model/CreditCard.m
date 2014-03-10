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
        case BrandMaster:
            return @"MASTER";
            break;
        case BrandAmex:
            return @"AMEX";
            break;
        case BrandDiners:
            return @"DINERS";
            break;
        case BrandHipercard:
            return @"HIPERCARD";
            break;
        default:
            return @"UNKNOW";
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
