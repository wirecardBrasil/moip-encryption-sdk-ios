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

- (PaymentMethod) getPaymentMethodFromString:(NSString *)method
{
    if ([method isEqualToString:@"CREDIT_CARD"])
    {
        return PaymentMethodCreditCard;
    }
    return PaymentMethodCreditCard;
}

- (NSString *) getPaymentStatus
{
    switch (self.status)
    {
        case PaymentStatusAuthorized:
            return @"AUTHORIZED";
            break;
            
        default:
            return @"UNKNOWN";
            break;
    }
}

- (PaymentStatus) getPaymentStatusFromString:(NSString *)method
{
    if ([method isEqualToString:@"AUTHORIZED"])
    {
        return PaymentStatusAuthorized;
    }
    else if ([method isEqualToString:@"IN_ANALYSIS"])
    {
        return PaymentStatusInAnalysis;
    }
    else if ([method isEqualToString:@"CONCLUED"])
    {
        return PaymentStatusConcluded;
    }
    else if ([method isEqualToString:@"CANCELLED"])
    {
        return PaymentStatusCancelled;
    }
    else if ([method isEqualToString:@"REFUNDED"])
    {
        return PaymentStatusRefunded;
    }
    else if ([method isEqualToString:@"REVERSED"])
    {
        return PaymentStatusReversed;
    }
    else if ([method isEqualToString:@"INITIATED"])
    {
        return PaymentStatusInitiated;
    }
    else if ([method isEqualToString:@"PRINTED"])
    {
        return PaymentStatusPrinted;
    }
    return PaymentStatusInAnalysis;
}

- (NSString *) getCurrency
{
    return @"";
}

- (Currency) getCurrencyFromString:(NSString *)currency
{
    return BRL;
}

@end
