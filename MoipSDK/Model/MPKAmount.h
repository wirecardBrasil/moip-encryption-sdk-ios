//
//  Amount.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKEnums.h"

@interface MPKAmount : NSObject

@property NSUInteger total;
@property NSUInteger fees;
@property NSUInteger refunds;
@property NSUInteger liquid;
@property NSUInteger shipping;
@property NSUInteger addition;
@property NSUInteger discount;
@property MPKCurrency MPKCurrency;

- (NSString *)buildJson;

@end
