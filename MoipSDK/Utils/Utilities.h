//
//  Utilities.h
//  tcf-sdk-ios
//
//  Created by Fernando Sousa on 1/4/12.
//  Copyright (c) 2012 Titans Group. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

@interface Utilities : NSObject

+ (NSString *) returnMD5Hash:(NSString*)concat;
+ (NSString*) computeSHA256DigestForString:(NSString*)input;
+ (NSString*) computeSHA256DigestForData:(NSData *)input;
+ (NSString *) encodeToPercentEscapeString:(NSString *)text;
+ (NSString *) addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary;

@end