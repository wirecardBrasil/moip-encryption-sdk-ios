//
//  PKCardCVC.h
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKCardType.h"
#import "MPKComponent.h"

@interface MPKCardCVC : MPKComponent

@property (nonatomic, readonly) NSString *string;

+ (instancetype)cardCVCWithString:(NSString *)string;
- (BOOL)isValidWithType:(MPKCardType)type;
- (BOOL)isPartiallyValidWithType:(MPKCardType)type;

@end
