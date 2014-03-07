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
    Initiated,
    Authorized,
    Concluded,
    Cancelled,
    Refunded,
    Reversed,
    Printed,
    InAnalysis
};

@protocol MoipPaymentDelegate <NSObject>
@required
- (void) paymentCreated:(PaymentTransaction *)paymentTransaction;
- (void) paymentFailed:(NSError *)error;

@end

@interface MoipSDK : NSObject

@property id<MoipPaymentDelegate> delegate;

- (void) submitPayment:(Payment *)payment delegate:(id)delegate;
- (void) checkPaymentStatus:(PaymentTransaction *)transaction;



@end