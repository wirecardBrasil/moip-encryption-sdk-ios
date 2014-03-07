//
//  PaymentTransaction.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface PaymentTransaction : NSObject

@property NSString *moipOrderId;
@property PaymentStatus status;

@end
