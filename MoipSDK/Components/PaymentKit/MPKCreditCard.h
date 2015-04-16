//
//  CreditCard.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPKCreditCard : NSObject

@property NSString *number;
@property NSString *cvv;
@property NSString *expirationMonth;
@property NSString *expirationYear;

@end
