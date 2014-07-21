//
//  Utilities.h
//  tcf-sdk-ios
//
//  Created by Fernando Sousa on 1/4/12.
//  Copyright (c) 2012 Titans Group. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CommonCrypto/CommonDigest.h>
#import "MPKEnvironment.h"
#import "Constants.h"

@interface MPKUtilities : NSObject

+ (void) importPrivateKey:(NSString *)privateKeyText tag:(NSString *)tag;
+ (void) importPublicKey:(NSString *)publicKeyText tag:(NSString *)tag;
+ (void) removeKey:(NSString *)tag;
+ (NSString *) encryptData:(NSString *)plainText keyTag:(NSString *)tag;
+ (NSString *) decryptData:(NSString *)plainText keyTag:(NSString *)tag;
//+ (NSString *) encryptRSA:(NSString *)plainTextString key:(SecKeyRef)publicKey;
//+ (NSString *) returnMD5Hash:(NSString*)concat;
//+ (NSString *) computeSHA256DigestForString:(NSString*)input;
//+ (NSString *) computeSHA256DigestForData:(NSData *)input;
+ (NSString *) encodeToPercentEscapeString:(NSString *)text;
+ (NSString *) addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;

+ (NSString *) urlWithEnv:(MPKEnvironment)env endpoint:(NSString *)endpoint;
@end