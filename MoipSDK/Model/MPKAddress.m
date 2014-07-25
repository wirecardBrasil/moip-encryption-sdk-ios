//
//  MPKAddress.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 24/07/14.
//  Copyright (c) 2014 Moip Pagamentos S/A. All rights reserved.
//

#import "MPKAddress.h"

@implementation MPKAddress

- (NSString *) getAddressType
{
    switch (self.type)
    {
        case MPKAddressTypeBilling:
            return @"BILLING";
            break;
        case MPKAddressTypeShipping:
            return @"SHIPPING";
            break;
        default:
            return @"BILLING";
            break;
    }
}

@end
