//
//  FundingInstrument.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKEnums.h"
#import "MPKMethodType.h"
#import "MPKCreditCard.h"

@interface MPKFundingInstrument : NSObject

@property MPKMethodType method;
@property MPKBrand institution;
@property MPKCreditCard *creditCard;

- (NSString *) buildJson;
- (NSString *) getMethodTypeString;
- (MPKMethodType) getMethodTypeFromString:(NSString *)method;

@end
