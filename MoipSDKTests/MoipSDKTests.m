//
//  MoipSDKTests.m
//  MoipSDKTests
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MoipSDK.h"
#import "MPKUtilities.h"


@interface MoipSDKTests : XCTestCase

@end

@implementation MoipSDKTests

- (void)setUp
{
    [super setUp];
    
    NSMutableString *publicKeyTests = [NSMutableString new];
    [publicKeyTests appendFormat:@"-----BEGIN PUBLIC KEY-----\n"];
    [publicKeyTests appendFormat:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoBttaXwRoI1Fbcond5mS\n"];
    [publicKeyTests appendFormat:@"7QOb7X2lykY5hvvDeLJelvFhpeLnS4YDwkrnziM3W00UNH1yiSDU+3JhfHu5G387\n"];
    [publicKeyTests appendFormat:@"O6uN9rIHXvL+TRzkVfa5iIjG+ap2N0/toPzy5ekpgxBicjtyPHEgoU6dRzdszEF4\n"];
    [publicKeyTests appendFormat:@"ItimGk5ACx/lMOvctncS5j3uWBaTPwyn0hshmtDwClf6dEZgQvm/dNaIkxHKV+9j\n"];
    [publicKeyTests appendFormat:@"Mn3ZfK/liT8A3xwaVvRzzuxf09xJTXrAd9v5VQbeWGxwFcW05oJulSFjmJA9Hcmb\n"];
    [publicKeyTests appendFormat:@"DYHJT+sG2mlZDEruCGAzCVubJwGY1aRlcs9AQc1jIm/l8JwH7le2kpk3QoX+gz0w\n"];
    [publicKeyTests appendFormat:@"WwIDAQAB\n"];
    [publicKeyTests appendFormat:@"-----END PUBLIC KEY-----"];
    
    [MoipSDK importPublicKey:publicKeyTests];
}

- (void)tearDown
{
    [super tearDown];
}

- (void) test01ShouldEncryptData
{
    NSString *cryptData = [MPKUtilities encryptData:@"4111111111111111" keyTag:kPublicKeyName];
    
    NSLog(@"test01ShouldEncryptData:\n%@", cryptData);
    XCTAssertNotNil(cryptData, @"");
}
 
@end
