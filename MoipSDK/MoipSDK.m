//
//  MoipSDK.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MoipSDK.h"

@implementation MoipSDK

- (void) submitPayment:(Payment *)payment
{
    PaymentTransaction *transac = [PaymentTransaction new];
    transac.status = PaymentStatusCancelled;
    if ([self.delegate respondsToSelector:@selector(paymentCreated:)])
    {
        [self.delegate performSelector:@selector(paymentCreated:) withObject:transac];
    }
}

- (void) checkPaymentStatus:(PaymentTransaction *)transaction
{
    PaymentTransaction *transac = [PaymentTransaction new];
    transac.status = PaymentStatusCancelled;
    if ([self.delegate respondsToSelector:@selector(paymentFailed:error:)])
    {
        NSError *er = [NSError errorWithDomain:@"MoipSDK" code:999 userInfo:nil];
        [self.delegate performSelector:@selector(paymentFailed:error:) withObject:transac withObject:er];
    }
}

@end
