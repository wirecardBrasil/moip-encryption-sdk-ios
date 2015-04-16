//
//  Utilities.h
//  tcf-sdk-ios
//
//  Created by Fernando Sousa on 1/4/12.
//  Copyright (c) 2012 Titans Group. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CommonCrypto/CommonDigest.h>
#import "Constants.h"

@interface MPKUtilities : NSObject

+ (void) importPrivateKey:(NSString *)privateKeyText tag:(NSString *)tag;
+ (void) importPublicKey:(NSString *)publicKeyText tag:(NSString *)tag;
+ (void) removeKey:(NSString *)tag;
+ (NSString *) encryptData:(NSString *)plainText keyTag:(NSString *)tag;
+ (NSString *) decryptData:(NSString *)plainText keyTag:(NSString *)tag;

@end