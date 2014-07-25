//
//  CreditCard.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKEnums.h"
#import "MPKCardHolder.h"

@interface MPKCreditCard : NSObject

@property NSString *creditCardId;
@property NSString *moipCreditCardId;
@property NSInteger expirationMonth;
@property NSInteger expirationYear;
@property NSString *number;
@property NSString *cvv;
@property MPKCardHolder *cardholder;
@property NSString *customerOwnId;
@property MPKBrand brand;
@property NSString *first6;
@property NSString *last4;

- (NSString *) getMPKBrand;
- (MPKBrand) getMPKBrandFromString:(NSString *)method;

@end
