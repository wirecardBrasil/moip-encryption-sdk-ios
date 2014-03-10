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

@interface MoipSDK : NSObject

- (void) submitPayment:(Payment *)payment success:(void (^)(PaymentTransaction *transaction))success failure:(void (^)(PaymentTransaction *transaction, NSError *error))failure;
- (void) checkPaymentStatus:(PaymentTransaction *)transaction;


@end