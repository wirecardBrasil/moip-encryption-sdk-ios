//
//  MPKOrder.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 25/07/14.
//  Copyright (c) 2014 Moip Pagamentos S/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKAmount.h"
#import "MPKCustomer.h"
#import "MPKItem.h"

@interface MPKOrder : NSObject

@property NSString *ownId;
@property NSString *moipOrderId;
@property MPKAmount *amount;
@property NSArray *items;
@property MPKCustomer *customer;

- (NSString *) buildJson;

@end
