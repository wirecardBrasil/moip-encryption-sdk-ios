//
//  MoipSDK.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payment.h"
#import "PaymentTransaction.h"

typedef NS_ENUM(NSUInteger, PaymentStatus)
{
    PaymentStatusInitiated,
    PaymentStatusAuthorized,
    PaymentStatusConcluded,
    PaymentStatusCancelled,
    PaymentStatusRefunded,
    PaymentStatusReversed,
    PaymentStatusPrinted,
    PaymentStatusInAnalysis
};

@protocol MoipPaymentDelegate <NSObject>
@required
- (void) paymentCreated:(PaymentTransaction *)paymentTransaction;
- (void) paymentFailed:(PaymentTransaction *)paymentTransaction error:(NSError *)error;

@end

@interface MoipSDK : NSObject

@property id<MoipPaymentDelegate> delegate;

- (void) submitPayment:(Payment *)payment;
- (void) checkPaymentStatus:(PaymentTransaction *)transaction;



@end