//
//  MoipSDK.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKPayment.h"
#import "MPKPaymentTransaction.h"
#import "MPKCreditCardTextField.h"
#import "MPKError.h"

@interface MoipSDK : NSObject

- (id) initWithAuthorization:(NSString *)auth publicKey:(NSString *)publicKeyPlainText;
- (void) submitPayment:(MPKPayment *)payment success:(void (^)(MPKPaymentTransaction *transaction))success failure:(void (^)(NSArray *errorList))failure;

@end