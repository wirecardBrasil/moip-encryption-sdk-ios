//
//  PaymentTransaction.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payment.h"
#import "Fee.h"
#import "Event.h"
#import "FundingInstrument.h"

@interface PaymentTransaction : NSObject

@property NSString *paymenteId;
@property PaymentStatus status;
@property Amount *amount;
@property Payment *payment;
@property FundingInstrument *fundingInstrument;
@property NSArray *fees;
@property NSArray *events;
@property NSDate *createdAt;
@property NSDate *updatedAt;

- (PaymentTransaction *) transactionWithJSON:(NSData *)jsonData;

@end
