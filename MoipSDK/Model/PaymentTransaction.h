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

@property Payment *payment;
@property NSUInteger installmentCount;
@property FundingInstrument *fundingInstrument;
@property NSArray *fees;
@property NSArray *events;


- (PaymentTransaction *) parseResponse:(NSData *)jsonData;

@end
