//
//  MoipSDK.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKCardHolder.h"
#import "MPKCreditCard.h"
#import "MPKView.h"
#import "MPKPayment.h"
#import "MPKPaymentTransaction.h"
#import "MPKError.h"
#import "MPKEnvironment.h"
#import "MPKCustomer.h"
#import "MPKOrder.h"

@interface MoipSDK : NSObject

#pragma mark - Init
+ (MoipSDK *) session;
+ (MoipSDK *) startSessionWithToken:(NSString *)token
                                key:(NSString *)key
                          publicKey:(NSString *)publicKey
                        environment:(MPKEnvironment)env;

#pragma mark - Methods
- (void) configureSitef;

- (void) createOrder:(NSURLRequest *)request
               order:(MPKOrder *)order
             success:(void (^)(MPKOrder *order, NSString *moipOrderId))success
             failure:(void (^)(NSArray *errorList))failure;

- (void) submitPayment:(MPKPayment *)payment
               success:(void (^)(MPKPaymentTransaction *transaction))success
               failure:(void (^)(NSArray *errorList))failure;

- (void) createCustomer:(MPKCustomer *)customer
                success:(void (^)(MPKCustomer *customer, NSString *moipCustomerId, NSString *moipCreditCardId))success
                failure:(void (^)(NSArray *errorList))failure;

@end