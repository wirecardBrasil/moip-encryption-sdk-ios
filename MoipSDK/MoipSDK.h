//
//  MoipSDK.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKCreditCard.h"

@interface MoipSDK : NSObject

+ (void) importPublicKey:(NSString *)publicKeyPlainText;
+ (NSString *)encryptCreditCard:(MPKCreditCard*)creditCard;

@end