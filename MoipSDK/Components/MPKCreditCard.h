//
//  CreditCard.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKCardType.h"

@interface MPKCreditCard : NSObject

@property NSString *number;
@property NSString *cvc;
@property NSString *expirationMonth;
@property NSString *expirationYear;

- (BOOL) isNumberValid;
- (BOOL) isSecurityCodeValid;
- (BOOL) isExpiryDateValid;
- (MPKCardType) cardType;

@end
