//
//  Payment.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "Payment.h"

@implementation Payment

- (NSString *) getPaymentMethod
{
    switch (self.method)
    {
        case PaymentMethodCreditCard:
            return @"CREDIT_CARD";
            break;
            
        default:
            return @"CREDIT_CARD";
            break;
    }
}

@end
