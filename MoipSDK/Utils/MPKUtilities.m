//
//  Utilities.m
//  Moip-SDK
//
//  Created by Fernando Sousa on 1/4/12.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKUtilities.h"
#import "SecUtils.h"
#import "Constants.h"

@implementation MPKUtilities

+ (void) importPublicKey:(NSString *)publicKeyText tag:(NSString *)tag;
{
    [SecUtils setPublicKey:publicKeyText tag:tag];
}

+ (void) importPrivateKey:(NSString *)privateKeyText tag:(NSString *)tag;
{
    [SecUtils setPrivateKey:privateKeyText tag:tag];
}

+ (BOOL) setPublicKey:(NSString *)publicKeyText
{
    return [SecUtils setPublicKey:publicKeyText keyTag:kPublicKeyName];
}

+ (void) removeKey:(NSString *)tag
{
    [SecUtils removeKey:tag];
}

+ (NSString *) encryptData:(NSString *)plainText keyTag:(NSString *)tag;
{
    NSString *encryptedData = [SecUtils encryptRSA:plainText keyTag:tag];
    return encryptedData;
}

+ (NSString *) decryptData:(NSString *)plainText keyTag:(NSString *)tag;
{
    return [SecUtils decryptRSA:plainText keyTag:tag];
}

@end