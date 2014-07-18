//
//  SecUtils.m
//  SecurityExample
//
//  Created by 淼 赵 on 12-11-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SecUtils.h"

#import <CommonCrypto/CommonCryptor.h>

//
// Mapping from 6 bit pattern to ASCII character.
//
static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

//
// Definition for "masked-out" areas of the base64DecodeLookup mapping
//
#define xx 65

//
// Mapping from ASCII character to 6 bit pattern.
//
static unsigned char base64DecodeLookup[256] =
{
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, xx, xx, xx,
    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx,
    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
};

//
// Fundamental sizes of the binary and base64 encode/decode units in bytes
//
#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4

//
// NewBase64Decode
//
// Decodes the base64 ASCII string in the inputBuffer to a newly malloced
// output buffer.
//
//  inputBuffer - the source ASCII string for the decode
//	length - the length of the string or -1 (to specify strlen should be used)
//	outputLength - if not-NULL, on output will contain the decoded length
//
// returns the decoded buffer. Must be free'd by caller. Length is given by
//	outputLength.
//
void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength)
{
	if (length == -1)
	{
		length = strlen(inputBuffer);
	}
	
	size_t outputBufferSize =
    ((length+BASE64_UNIT_SIZE-1) / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
	unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
	
	size_t i = 0;
	size_t j = 0;
	while (i < length)
	{
		//
		// Accumulate 4 valid characters (ignore everything else)
		//
		unsigned char accumulated[BASE64_UNIT_SIZE];
		size_t accumulateIndex = 0;
		while (i < length)
		{
			unsigned char decode = base64DecodeLookup[inputBuffer[i++]];
			if (decode != xx)
			{
				accumulated[accumulateIndex] = decode;
				accumulateIndex++;
				
				if (accumulateIndex == BASE64_UNIT_SIZE)
				{
					break;
				}
			}
		}
		
		//
		// Store the 6 bits from each of the 4 characters as 3 bytes
		//
		// (Uses improved bounds checking suggested by Alexandre Colucci)
		//
		if(accumulateIndex >= 2)
			outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
		if(accumulateIndex >= 3)
			outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);
		if(accumulateIndex >= 4)
			outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
		j += accumulateIndex - 1;
	}
	
	if (outputLength)
	{
		*outputLength = j;
	}
	return outputBuffer;
}

//
// NewBase64Encode
//
// Encodes the arbitrary data in the inputBuffer as base64 into a newly malloced
// output buffer.
//
//  inputBuffer - the source data for the encode
//	length - the length of the input in bytes
//  separateLines - if zero, no CR/LF characters will be added. Otherwise
//		a CR/LF pair will be added every 64 encoded chars.
//	outputLength - if not-NULL, on output will contain the encoded length
//		(not including terminating 0 char)
//
// returns the encoded buffer. Must be free'd by caller. Length is given by
//	outputLength.
//
char *NewBase64Encode(
                      const void *buffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength)
{
	const unsigned char *inputBuffer = (const unsigned char *)buffer;
	
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
	
	//
	// Byte accurate calculation of final buffer size
	//
	size_t outputBufferSize =
    ((length / BINARY_UNIT_SIZE)
     + ((length % BINARY_UNIT_SIZE) ? 1 : 0))
    * BASE64_UNIT_SIZE;
	if (separateLines)
	{
		outputBufferSize +=
        (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
	}
	
	//
	// Include space for a terminating zero
	//
	outputBufferSize += 1;
    
	//
	// Allocate the output buffer
	//
	char *outputBuffer = (char *)malloc(outputBufferSize);
	if (!outputBuffer)
	{
		return NULL;
	}
    
	size_t i = 0;
	size_t j = 0;
	const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
	size_t lineEnd = lineLength;
	
	while (true)
	{
		if (lineEnd > length)
		{
			lineEnd = length;
		}
        
		for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE)
		{
			//
			// Inner loop: turn 48 bytes into 64 base64 characters
			//
			outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
			outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                                   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
			outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                                                   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
			outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
		}
		
		if (lineEnd == length)
		{
			break;
		}
		
		//
		// Add the newline
		//
		outputBuffer[j++] = '\r';
		outputBuffer[j++] = '\n';
		lineEnd += lineLength;
	}
	
	if (i + 1 < length)
	{
		//
		// Handle the single '=' case
		//
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                               | ((inputBuffer[i + 1] & 0xF0) >> 4)];
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
		outputBuffer[j++] =	'=';
	}
	else if (i < length)
	{
		//
		// Handle the double '=' case
		//
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
		outputBuffer[j++] = '=';
		outputBuffer[j++] = '=';
	}
	outputBuffer[j] = 0;
	
	//
	// Set the output length and return the buffer
	//
	if (outputLength)
	{
		*outputLength = j;
	}
	return outputBuffer;
}

@interface SecUtils()

size_t encodeLength(unsigned char *buf, size_t length);

@end


static unsigned char oidSequence[] = {0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7,0x0d,0x01,0x01,0x01,0x05,0x00};

static NSString* x509PublicHeader =@"-----BEGIN PUBLIC KEY-----";
static NSString* x509PublicFooter = @"-----END PUBLIC KEY-----";
static NSString* pKCS1PublicHeader=@"-----BEGIN RSA PUBLIC KEY-----";
static NSString* pKCS1PublicFooter = @"-----END RSA PUBLIC KEY-----";
static NSString* pemPrivateHeader=@"-----BEGIN RSA PRIVATE KEY-----";
static NSString* pemPrivateFooter =  @"-----END RSA PRIVATE KEY-----";


@implementation SecUtils

#pragma mark - Encryption/Decryption Methods
+(NSString*)encryptRSA:(NSString *)plainText withPrivateKey:(NSString *)key
{
    NSString *privateKeyIdentifier = [NSString stringWithFormat:@"%@.privatekey", [[NSBundle mainBundle] bundleIdentifier]];
    SecKeyRef privateKey = NULL;
    NSData *privateTag = [privateKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *queryRrivateKey = [[NSMutableDictionary alloc] init];
    [queryRrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryRrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryRrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryRrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecItemCopyMatching((__bridge CFDictionaryRef)queryRrivateKey, (CFTypeRef*)&privateKey);
    if(!privateKey)
    {
        if(privateKey) CFRelease(privateKey);
        //
        NSLog(@"read public key failed");
    }
    

    size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize);
    
    uint8_t *nonce = (uint8_t*)[plainText UTF8String];
    if(cipherBufferSize < sizeof(nonce))
    {
        if(privateKey) CFRelease(privateKey);
        //
        NSLog(@"too long to encrypt");
        free(cipherBuffer);
    }
    
    SecKeyEncrypt(privateKey, kSecPaddingPKCS1, nonce, strlen((char*)nonce) + 1, &cipherBuffer[0], &cipherBufferSize);
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    if(privateKey) CFRelease(privateKey);
    free(cipherBuffer);
    
    return [self base64EncodedString:encryptedData];
    
}

+ (NSString*) decryptRSA:(NSString *)cipher withPubKey:(NSString *)key
{
    NSString *pubKeyIdentifier = [NSString stringWithFormat:@"%@.publickey", [[NSBundle mainBundle] bundleIdentifier]];
    [SecUtils setPublicKey:key tag:pubKeyIdentifier];
    
    size_t plainBufferSize;
    uint8_t *plainBuffer;
    
    SecKeyRef pubKey = NULL;
    NSData *pubKeyTag = [pubKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:pubKeyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef*)&pubKey);
    
    if(!pubKey)
    {
        if(pubKey) CFRelease(pubKey);
    }
    
    plainBufferSize = SecKeyGetBlockSize(pubKey);
    plainBuffer = malloc(plainBufferSize);
    
    NSData* incomingData = [self dataFromBase64String:cipher];
    uint8_t *cipherBuffer = (uint8_t*)[incomingData bytes];
    size_t cipherBufferSize = SecKeyGetBlockSize(pubKey);
    
    if(plainBufferSize < cipherBufferSize)
    {
        //
    }
    
    OSStatus status = SecKeyDecrypt(pubKey, kSecPaddingPKCS1, cipherBuffer, cipherBufferSize, plainBuffer, &plainBufferSize);
    if(status ==noErr){
        NSLog(@"no err");
    }else{
        NSLog(@"error:%d", (int)status);
    }
    
    NSData *decryptedData = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
    NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    if(pubKey) CFRelease(pubKey);
    
    return decryptedString;
    
}

+(NSString*)decryptRSA:(NSString *)cipher keyTag:(NSString *)key
{
    NSString *privateKeyIdentifier = key;

    size_t plainBufferSize;
    uint8_t *plainBuffer;
    
    SecKeyRef privateKey = NULL;
    NSData *privateTag = [privateKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef*)&privateKey);
    
    if(!privateKey)
    {
        if(privateKey) CFRelease(privateKey);
    }
    
    plainBufferSize = SecKeyGetBlockSize(privateKey);
    plainBuffer = malloc(plainBufferSize);
    
    NSData* incomingData = [self dataFromBase64String:cipher];
    uint8_t *cipherBuffer = (uint8_t*)[incomingData bytes];
    size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
    
    if(plainBufferSize < cipherBufferSize)
    {
        //
    }
    
    SecKeyDecrypt(privateKey, kSecPaddingPKCS1, cipherBuffer, cipherBufferSize, plainBuffer, &plainBufferSize);
    
    NSData *decryptedData = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
    NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    if(privateKey) CFRelease(privateKey);
    
    const char* decryptedStr = [decryptedString UTF8String];
    return [[NSString alloc] initWithUTF8String:decryptedStr];
}

+(NSString*)encryptRSA:(NSString *)plainText keyTag:(NSString *)key
{
    NSString *publicKeyIdentifier = key;
    
    SecKeyRef publicKey = NULL;
    NSData *publicTag = [publicKeyIdentifier dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef*)&publicKey);
    if(!publicKey)
    {
        if(publicKey) CFRelease(publicKey);
        //
        NSLog(@"read public key failed");
        return nil;
    }
    else
    {
        size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
        uint8_t *cipherBuffer = malloc(cipherBufferSize);
        uint8_t *nonce = (uint8_t *)[plainText UTF8String];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingOAEP,
                                        nonce,
                                        strlen( (char*)nonce ),
                                        &cipherBuffer[0],
                                        &cipherBufferSize);
        
        NSLog(@"%d", (int)status);
        
        NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
        return [self base64EncodedString:encryptedData];
//        size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
//        uint8_t *cipherBuffer = malloc(cipherBufferSize);
//        
//        uint8_t *nonce = (uint8_t*)[plainText UTF8String];
//        if(cipherBufferSize < sizeof(nonce))
//        {
//            if(publicKey) CFRelease(publicKey);
//            //
//            NSLog(@"too long to encrypt");
//            free(cipherBuffer);
//        }
//        
//        SecKeyEncrypt(publicKey, kSecPaddingPKCS1, nonce, strlen((char*)nonce) + 1, &cipherBuffer[0], &cipherBufferSize);
//        NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
//        
//        if(publicKey) CFRelease(publicKey);
//        free(cipherBuffer);
//        
//        return [self base64EncodedString:encryptedData];
    }
}

#pragma mark - Public/Private Key Import Methods:
+(void)setPrivateKey:(NSString *)pemPrivateKeyString tag:(NSString *)tag
{
    NSData *privateTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    [privateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKey);
    
    NSString *strippedKey = nil;
    if(([pemPrivateKeyString rangeOfString:pemPrivateHeader].location != NSNotFound) && ([pemPrivateKeyString rangeOfString:pemPrivateFooter].location != NSNotFound)){
        strippedKey = [[pemPrivateKeyString stringByReplacingOccurrencesOfString:pemPrivateHeader withString:@""] stringByReplacingOccurrencesOfString:pemPrivateFooter withString:@""];
        strippedKey = [[strippedKey stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
    }else {
        // error
        NSLog(@"can't not retrieve private key");
    }
    
    NSData *strippedPrivateKeyData = [self dataFromBase64String:strippedKey];
    
    CFTypeRef persistKey = nil;
    
    [privateKey setObject:strippedPrivateKeyData forKey:(__bridge id)kSecValueData];
    [privateKey setObject:(__bridge id)kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    if(persistKey != nil) CFRelease(persistKey);
    if((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        // error to add sec item
    }
    
    SecKeyRef keyRef = nil;
    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef*)&keyRef);
    
    if(!keyRef)
    {
        // error
        NSLog(@"could not set private key");
    }
    
    if(keyRef) CFRelease(keyRef);
}

+(void)setPublicKey:(NSString *)pemPublicKeyString tag:(NSString *)tag
{
    NSData *publicTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    BOOL isX509 = NO;
    NSString *strippedKey = nil;

    if(([pemPublicKeyString rangeOfString:x509PublicHeader].location != NSNotFound) && [pemPublicKeyString rangeOfString:x509PublicFooter].location != NSNotFound){
        strippedKey = [[pemPublicKeyString stringByReplacingOccurrencesOfString:x509PublicHeader withString:@""] stringByReplacingOccurrencesOfString:x509PublicFooter withString:@""];
        strippedKey = [[strippedKey stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        isX509 = YES;
    }
    else if(([pemPublicKeyString rangeOfString:pKCS1PublicHeader].location != NSNotFound) && ([pemPublicKeyString rangeOfString:pKCS1PublicFooter].location != NSNotFound))
    {
        strippedKey = [[pemPublicKeyString stringByReplacingOccurrencesOfString:pKCS1PublicHeader withString:@""] stringByReplacingOccurrencesOfString:pKCS1PublicFooter withString:@""];
        strippedKey = [[strippedKey stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        isX509 = NO;
    }
    else {
        // error
        NSLog(@"unknown security type");
    }
    
    NSData *strippedPublicKeyData = [self dataFromBase64String:strippedKey];
    
    if(isX509)
    {
        unsigned char *bytes = (unsigned char*)[strippedPublicKeyData bytes];
        size_t bytesLen = [strippedPublicKeyData length];
        
        size_t i = 0;
        if (bytes[i++] != 0x30)
        {
            NSLog(@"linenum: %d,Could not set public key",__LINE__);
        }
        
        if(bytes[i] > 0x80)
        {
            i+= bytes[i] - 0x80 + 1;
        }else
        {
            i++;
        }
        
        if(i >= bytesLen)
        {
            
            NSLog(@"linenum: %d,Could not set public key",__LINE__);
            
        }
        
        if(bytes[i] != 0x30)
        {
            NSLog(@"linenum: %d,Could not set public key",__LINE__);
        }
        
        // Skip OID
        i+=15;
        
        if(i >= bytesLen - 2)
        {
            NSLog(@"linenum: %d,Could not set public key",__LINE__);
        }
        
        if(bytes[i++] != 0x03)
        {
            NSLog(@"linenum: %d,Could not set public key",__LINE__);
        }
        
        if(bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else {
            i++;
        }
        
        if(i >= bytesLen)
        {
            NSLog(@"linenum: %d,Could not set public key",__LINE__);
        }
        
        if(bytes[i++] != 0x00)
        {
            NSLog(@"linenum: %d,Could not set public key",__LINE__);
        }
        
        if(i >= bytesLen)
        {
            NSLog(@"linenum: %d,Could not set public key",__LINE__);
        }
        
        strippedPublicKeyData = [NSData dataWithBytes:&bytes[i] length:bytesLen - i];
        
    }
    
    if(strippedPublicKeyData == nil)
    {
        NSLog(@"linenum: %d,Could not set public key",__LINE__);
    }
    
    CFTypeRef persistKey = nil;
    [publicKey setObject:strippedPublicKeyData forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    
    if((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        NSLog(@"linenum: %d,Could not set public key",__LINE__);
    }
    
    SecKeyRef keyRef = nil;
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef*)&keyRef);
    
    if(!keyRef)
    {
        NSLog(@"linenum: %d,Could not set public key",__LINE__);
    }
    
    if(keyRef) CFRelease(keyRef);
}

+(void)removeKey:(NSString *)tag
{
    NSData *keyTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    [privateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKey setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    OSStatus secStatus = SecItemDelete((__bridge CFDictionaryRef)privateKey);
    
    if((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        NSLog(@"Could not remove key");
    }
}

#pragma mark - Key pair generation method:
+(void)generateKeyPairWithPublicTag:(NSString *)publicTagString privateTag:(NSString *)privateTagString
{
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init ];
    NSMutableDictionary *publicKeyAttr= [[NSMutableDictionary alloc] init ];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init ];
    
    NSData *publicTag = [publicTagString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *privateTag = [privateTagString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *privateKeyDictionary = [[NSMutableDictionary alloc] init ];
    [privateKeyDictionary setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKeyDictionary setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKeyDictionary setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKeyDictionary);
    
    NSMutableDictionary *publicKeyDictionary = [[NSMutableDictionary alloc] init ];
    [publicKeyDictionary setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKeyDictionary setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKeyDictionary setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKeyDictionary);
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:1024] forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
    OSStatus osStatus = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey);
    
    if(osStatus != noErr)
    {
        NSLog(@"Could not generate key pair!");
        
    }
}

+(NSString*)getPEMFormattedPrivateKey:(NSString *)tag
{
    NSData *privateTag= [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    NSData *privateKeyBits;
    CFTypeRef privateKeyBitsInTypeRef = (__bridge CFTypeRef)privateKeyBits;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef*)&privateKeyBitsInTypeRef);
    if(status != noErr)
    {
        NSLog(@"Could not get private key , tag may be bad");
    }
    
    NSMutableData *encKey = [[NSMutableData alloc] init];
    [encKey appendData:(__bridge NSData *)(privateKeyBitsInTypeRef)];
    
    NSString *returnString = [NSString stringWithFormat:@"%@\n", pemPrivateHeader];
    returnString = [returnString stringByAppendingString: [self base64EncodedString:encKey]];
    returnString = [returnString stringByAppendingFormat:@"\n%@", pemPrivateFooter];
    
    return returnString;
}

+(NSString*)getX509FormattedPublicKey:(NSString *)tag
{
    NSData *publicTag = [tag dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    NSData *publicKeyBits;
    CFTypeRef publicKeyBitsInTypeRef = (__bridge CFTypeRef)publicKeyBits;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKeyBitsInTypeRef);
    if(status != noErr)
    {
        NSLog(@"Could not get public key ");
    }
    
    unsigned char builder[15];
    NSMutableData *encKey= [[NSMutableData alloc] init ];
    NSUInteger bitsStringEncLength;
    if([(__bridge NSData *)(publicKeyBitsInTypeRef) length] + 1 < 128)
    {
        bitsStringEncLength = 1;
    }
    else {
        bitsStringEncLength = (([(__bridge NSData *)(publicKeyBitsInTypeRef) length] + 1)/256) + 2;
    }
    
    builder[0] = 0x30;
    size_t i = sizeof(oidSequence) + 2 + bitsStringEncLength + [(__bridge NSData *)(publicKeyBitsInTypeRef) length];
    size_t j = encodeLength(&builder[1], i);
    [encKey appendBytes:builder length:j+1];
    [encKey appendBytes:oidSequence length:sizeof(oidSequence)];
    
    builder[0] = 0x03;
    j = encodeLength(&builder[1], [(__bridge NSData *)(publicKeyBitsInTypeRef) length] + 1);
    builder[j+1]=0x00;
    [encKey appendBytes:builder length:j+2];
    [encKey appendData:(__bridge NSData *)(publicKeyBitsInTypeRef)];
    
    NSString *returnString = [NSString stringWithFormat:@"%@\n%@\n%@", x509PublicHeader, [self base64EncodedString:encKey], x509PublicFooter];
    
    return returnString;
}

+ (NSData *)dataFromBase64String:(NSString *)aString
{
    aString = [[[aString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSData *data = [aString dataUsingEncoding:NSASCIIStringEncoding];
	size_t outputLength;
	void *outputBuffer = NewBase64Decode([data bytes], [data length], &outputLength);
	NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
	free(outputBuffer);
	return result;
}

+ (NSString *)base64EncodedString:(NSData *)data
{
	size_t outputLength;
	char *outputBuffer =
    NewBase64Encode([data bytes], [data length], true, &outputLength);
	
	NSString *result = [[NSString alloc]
                        initWithBytes:outputBuffer
                        length:outputLength
                        encoding:NSASCIIStringEncoding];
//    NSString *result = [[NSString alloc]
//                        initWithBytes:outputBuffer
//                        length:outputLength
//                        encoding:NSUTF8StringEncoding];
	free(outputBuffer);
    
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return result;
}

#pragma mark - Public Key Import/Export convenience method
size_t encodeLength(unsigned char *buf, size_t length)
{
    if(length < 128)
    {
        buf[0] = length;
        return 1;
    }
    
    size_t i = (length/256) + 1;
    buf[0] = i+ 0x80;
    for(size_t j = 0; j < i; j++)
    {
        buf[i-j] = length & 0xFF;
        length = length >> 8;
    }
    
    return i +1;
}





@end

