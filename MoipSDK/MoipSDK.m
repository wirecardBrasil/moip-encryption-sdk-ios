//
//  MoipSDK.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MoipSDK.h"
#import "MPKUtilities.h"
#import "MPKCreditCard.h"

@implementation MoipSDK

/**
 *  importa a chave publica para criptografia dos dados de cartão e outros dados senseiveis
 *
 *  @param publicKeyPlainText chave publica em plain text
 */
+ (void) importPublicKey:(NSString *)publicKeyPlainText {
    if (publicKeyPlainText != nil && ![publicKeyPlainText isEqualToString:@""]) {
        [MPKUtilities importPublicKey:publicKeyPlainText tag:kPublicKeyName];
    }
}

/**
 *  criptografa os dados do cartão de credito e retorna hash
 *
 *  @param publicKeyPlainText chave publica em plain text
 */
+ (NSString *)encryptCreditCard:(MPKCreditCard*)creditCard {
    
    NSString *valueToEncrypt = [NSString stringWithFormat:@"number=%@&cvc=%@&expirationMonth=%@&expirationYear=%@", creditCard.number, creditCard.cvc, creditCard.expirationMonth, creditCard.expirationYear];
    NSLog(@"%@", valueToEncrypt);
    NSString *encriptedData = [MPKUtilities encryptData:valueToEncrypt keyTag:kPublicKeyName];
    
    if (encriptedData) {
        return encriptedData;
    }
    
    return nil;
}


@end
