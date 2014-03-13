//
//  Fee.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKEnums.h"

@interface MPKFee : NSObject

@property MPKFeeType type;
@property NSUInteger amount;

@end
