//
//  ValidatorHelper.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 07/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payment.h"
#import "CardHolder.h"
#import "CreditCard.h"

@interface Utilities : NSObject

+ (NSString *) getMethodPayment:(PaymentMethod)method;
+ (NSString *) getTypeDocument:(CardHolderDocumentType)document;

@end
