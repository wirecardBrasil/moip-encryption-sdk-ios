//
//  PaymentTransaction.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKEnums.h"
#import "MPKPayment.h"
#import "MPKFee.h"
#import "MPKEvent.h"
#import "MPKFundingInstrument.h"

@interface MPKPaymentTransaction : NSObject

@property NSString *paymentId;
@property MPKPaymentStatus status;
@property MPKAmount *amount;
@property MPKPayment *payment;
@property MPKFundingInstrument *fundingInstrument;
@property NSArray *fees;
@property NSArray *events;
@property NSDate *createdAt;
@property NSDate *updatedAt;

- (MPKPaymentTransaction *) transactionWithJSON:(NSData *)jsonData;

@end
