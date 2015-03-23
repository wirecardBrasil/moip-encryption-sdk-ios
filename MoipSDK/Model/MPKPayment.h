//
//  Payment.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKEnums.h"
#import "MPKCreditCard.h"
#import "MPKAmount.h"
#import "MPKFundingInstrument.h"

@interface MPKPayment : NSObject

@property NSString *moipOrderId;
@property NSInteger installmentCount;
@property MPKFundingInstrument *fundingInstrument;

- (NSString *) buildJson;

@end
