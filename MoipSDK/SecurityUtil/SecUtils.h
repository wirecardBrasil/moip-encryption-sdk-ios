//
//  SecUtils.h
//  SecurityExample
//
//  Created by 淼 赵 on 12-11-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// openssl genrsa -out privatekey.pem 1024
// openssl rsa  -in privatekey.pem -pubout -out publickey.pem 

@interface SecUtils : NSObject

+(NSString*)encryptRSA:(NSString *)plainText keyTag:(NSString *)key;
+(NSString*)decryptRSA:(NSString* )cipher keyTag:(NSString*)key;

+(NSString*)encryptRSA:(NSString*)plainText withPrivateKey:(NSString*)key;
+(NSString*)decryptRSA:(NSString*)cipher withPubKey:(NSString*)pubKey;

+(void)generateKeyPairWithPublicTag:(NSString*)publicTagString privateTag:(NSString*)privateTagString;
+(void)setPrivateKey:(NSString*)pemPrivateKeyString tag:(NSString*)tag;
+(void)setPublicKey:(NSString*)pemPublicKeyString tag:(NSString*)tag;
+(void)removeKey:(NSString*)tag;

+(NSString*)getX509FormattedPublicKey:(NSString*)tag;
+(NSString*)getPEMFormattedPrivateKey:(NSString*)tag;

@end


