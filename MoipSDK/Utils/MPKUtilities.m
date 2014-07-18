//
//  Utilities.m
//  Moip-SDK
//
//  Created by Fernando Sousa on 1/4/12.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import "MPKUtilities.h"
#import "SecUtils.h"

@implementation MPKUtilities

+ (void) importPublicKey:(NSString *)publicKeyText
{
    [SecUtils setPublicKey:publicKeyText tag:kPublicKeyName];
}

+ (void) importPrivateKey:(NSString *)privateKeyText
{
    [SecUtils setPrivateKey:privateKeyText tag:kPrivateKeyName];
}

+ (void) removeKey:(NSString *)tag
{
    [SecUtils removeKey:tag];
}

+ (NSString *) encryptData:(NSString *)plainText
{
    return [SecUtils encryptRSA:plainText keyTag:kPublicKeyName];
}

+ (NSString *) encryptRSA:(NSString *)plainTextString key:(SecKeyRef)publicKey
{
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    uint8_t *nonce = (uint8_t *)[plainTextString UTF8String];
    SecKeyEncrypt(publicKey,
                  kSecPaddingOAEP,
                  nonce,
                  strlen( (char*)nonce ),
                  &cipherBuffer[0],
                  &cipherBufferSize);
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    return [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (NSString *) decryptData:(NSString *)plainText
{
    return [SecUtils decryptRSA:plainText keyTag:kPrivateKeyName];
}

+ (NSString *) returnMD5Hash:(NSString*)concat
{
    const char *concat_str = [concat UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(concat_str, (CC_LONG)strlen(concat_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    
    return [hash lowercaseString];
}

+ (NSString*)computeSHA256DigestForString:(NSString*)input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    
    // Setup our Objective-C output.
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString*)computeSHA256DigestForData:(NSData *)input
{
    NSData *data = [NSData dataWithBytes:input.bytes length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    // Setup our Objective-C output.
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString *)encodeToPercentEscapeString:(NSString *)text
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                     NULL,
                                                                     (__bridge CFStringRef)text,
                                                                     NULL,
                                                                     CFSTR("!*'();:@&=+$,?%#[]"),
                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

+ (NSString *)urlEscapeString:(NSString *)unencodedString
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}

+ (NSString *)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    
    for (id key in dictionary)
    {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound)
        {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
        else
        {
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return urlWithQuerystring;
}

+ (NSString *) urlWithEnv:(MPKEnvironment)env endpoint:(NSString *)endpoint
{
    if (env == MPKEnvironmentPRODUCTION)
        return [NSString stringWithFormat:@"%@%@", BASE_URL_PRODUCTION, endpoint];
    else if (env == MPKEnvironmentSANDBOX)
        return [NSString stringWithFormat:@"%@%@", BASE_URL_SANDBOX, endpoint];
    
    return [NSString stringWithFormat:@"%@%@", BASE_URL_SANDBOX, endpoint];
}

@end