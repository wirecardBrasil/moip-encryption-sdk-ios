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
@property NSInteger installmentCount;
@property PaymentMethod method;
@property CreditCard *creditCard;

- (NSString *) getPaymentMethod;
- (PaymentMethod) getPaymentMethodFromString:(NSString *)method;


@end
