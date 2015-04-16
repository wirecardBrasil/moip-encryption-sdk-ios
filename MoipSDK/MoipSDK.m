//
//  MoipSDK.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MoipSDK.h"
#import "MPKUtilities.h"

@implementation MoipSDK

/**
 *  importa a chave publica para criptografia dos dados de cartão e outros dados senseiveis
 *
 *  @param publicKeyPlainText chave publica em plain text
 */
+ (void) importPublicKey:(NSString *)publicKeyPlainText
{
    if (publicKeyPlainText != nil && ![publicKeyPlainText isEqualToString:@""])
    {
        [MPKUtilities importPublicKey:publicKeyPlainText tag:kPublicKeyName];
    }
}

@end
