//
//  Payment.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreditCard.h"

typedef NS_ENUM(int, PaymentMethod)
{
    PaymentMethodCreditCard
};

@interface Payment : NSObject

@property NSString *moipOrderId;
@property int installmentCount;
@property PaymentMethod method;
@property CreditCard *creditCard;

@end
