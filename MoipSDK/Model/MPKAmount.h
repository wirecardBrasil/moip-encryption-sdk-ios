//
//  Amount.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKEnums.h"

@interface MPKAmount : NSObject

@property NSInteger total;
@property NSInteger fees;
@property NSInteger refunds;
@property NSInteger liquid;
@property NSInteger shipping;
@property NSInteger addition;
@property NSInteger discount;
@property MPKCurrency MPKCurrency;

- (NSString *)buildJson;

@end
