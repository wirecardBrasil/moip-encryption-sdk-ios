//
//  Payment.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKPayment.h"

@implementation MPKPayment

- (NSString *) getMPKPaymentMethod
{
    switch (self.method)
    {
        case MPKPaymentMethodCreditCard:
            return @"CREDIT_CARD";
            break;
            
        default:
            return @"CREDIT_CARD";
            break;
    }
}

- (MPKPaymentMethod) getMPKPaymentMethodFromString:(NSString *)method
{
    if ([method isEqualToString:@"CREDIT_CARD"])
    {
        return MPKPaymentMethodCreditCard;
    }
    return MPKPaymentMethodCreditCard;
}

@end
