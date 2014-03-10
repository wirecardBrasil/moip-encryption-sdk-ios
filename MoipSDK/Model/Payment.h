//
//  Payment.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreditCard.h"
#import "Amount.h"

@interface Payment : NSObject

@property NSString *moipOrderId;
@property NSString *paymenteId;
@property PaymentStatus status;
@property Amount *amount;
@property int installmentCount;
@property PaymentMethod method;
@property CreditCard *creditCard;
@property NSDate *createdAt;
@property NSDate *updatedAt;

- (NSString *) getPaymentMethod;
- (PaymentMethod) getPaymentMethodFromString:(NSString *)method;

- (NSString *) getPaymentStatus;
- (PaymentStatus) getPaymentStatusFromString:(NSString *)method;

- (NSString *) getCurrency;
- (Currency) getCurrencyFromString:(NSString *)currency;


@end
