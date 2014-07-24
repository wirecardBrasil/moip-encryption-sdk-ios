//
//  MoipSDKTests.m
//  MoipSDKTests
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#define MOIPTOKENTESTS @"TDY93LUSD6NSOXMBKHMROFV7G0FSXPUA"
#define MOIPKEYTESTS @"DM1ARXOGDXYXSDJYNULSAZ2JLI5J2XUTLVUYCXN6"

#import <XCTest/XCTest.h>
#import "MoipSDK.h"
#import "MPKUtilities.h"
#import "MoipHttpRequester.h"
#import "MoipHttpResponse.h"
#import "HTTPStatusCodes.h"

@interface MoipSDKTests : XCTestCase
{
    NSMutableString *publicKeyTests;
}
@end

@implementation MoipSDKTests

- (void)setUp
{
    [super setUp];

    publicKeyTests = [NSMutableString new];
    [publicKeyTests appendFormat:@"-----BEGIN PUBLIC KEY-----\n"];
    [publicKeyTests appendFormat:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAi3UDmdCJ4LVJAs+2EqwY\n"];
    [publicKeyTests appendFormat:@"0q3fw6N+++KdxfSJbBbprSc0J3+NKiQjd+jERsDMJFzrjdndHn3z1grQ5D6p5ghp\n"];
    [publicKeyTests appendFormat:@"KyIAxbc/i7Td0lY3mYEiWcFO+N59ORFIFH4y1jJ+KBywvwZk7KDNNGkAReJFQmqU\n"];
    [publicKeyTests appendFormat:@"FMoc4THAgRg25GjSncN+nnaK+dbwkeG5fTL8vNJwn95v8ZLA531Vv8XzIPKIxUld\n"];
    [publicKeyTests appendFormat:@"wzdZh/+4hsRYoLaKbV7T/yCcoiNLzsf9eHOauAafB3UIar8PKwSL7VCf1nW6Y39K\n"];
    [publicKeyTests appendFormat:@"twjjp53Svu7KnWq0xOj4dAQgUcYBg7F6ZlIMqxXgzDckOYwsOBC3fkqKJTzK8dWn\n"];
    [publicKeyTests appendFormat:@"swIDAQAB\n"];
    [publicKeyTests appendFormat:@"-----END PUBLIC KEY-----"];
    
    [MoipSDK startSessionWithToken:MOIPTOKENTESTS
                               key:MOIPKEYTESTS
                         publicKey:publicKeyTests
                       environment:MPKEnvironmentSANDBOX];
}

- (void)tearDown
{
    [super tearDown];

}

- (void) testShouldEncryptData
{
    NSString *cryptData = [MPKUtilities encryptData:@"4111111111111111" keyTag:kPublicKeyName];
    
    XCTAssertNotNil(cryptData, @"");
}

- (void) testShouldCreateMoipOrderId
{
    NSString *orderid = [self getMoipOrderId];
    NSLog(@"-------------------------------------------------------------------:::::::: %@", orderid);
    
    XCTAssertNotNil(orderid, @"");
}

- (void)testShouldCreateAPaymentInMoip
{
    MPKCardHolder *holder = [MPKCardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = MPKCardHolderDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    MPKCreditCard *card = [MPKCreditCard new];
    card.expirationMonth = 05;
    card.expirationYear = 18;
//    card.number = @"4111111111111111";
//    card.cvv = @"999";
    card.number = [MPKUtilities encryptData:@"4111111111111111" keyTag:kPublicKeyName];
    card.cvv = [MPKUtilities encryptData:@"999" keyTag:kPublicKeyName];
    card.cardholder = holder;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = [self getMoipOrderId];
    NSLog(@"%@", payment.moipOrderId);
    payment.installmentCount = 1;
    payment.method = MPKPaymentMethodCreditCard;
    payment.creditCard = card;
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] submitPayment:payment success:^(MPKPaymentTransaction *transaction) {

        waitingForBlock = NO;
        XCTAssertNotNil(transaction, @"payment transaction is nil");
        
    } failure:^(NSArray *errorList) {
        waitingForBlock = NO;
        NSLog(@"%@", errorList);
        XCTAssertNil(errorList, @"");
    }];
    
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void) testShouldEncryptAndDecryptACreditCardNumber
{
    NSMutableString *pk = [NSMutableString new];
    [pk appendFormat:@"-----BEGIN PUBLIC KEY-----\n"];
    [pk appendFormat:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAi3UDmdCJ4LVJAs+2EqwY\n"];
    [pk appendFormat:@"0q3fw6N+++KdxfSJbBbprSc0J3+NKiQjd+jERsDMJFzrjdndHn3z1grQ5D6p5ghp\n"];
    [pk appendFormat:@"KyIAxbc/i7Td0lY3mYEiWcFO+N59ORFIFH4y1jJ+KBywvwZk7KDNNGkAReJFQmqU\n"];
    [pk appendFormat:@"FMoc4THAgRg25GjSncN+nnaK+dbwkeG5fTL8vNJwn95v8ZLA531Vv8XzIPKIxUld\n"];
    [pk appendFormat:@"wzdZh/+4hsRYoLaKbV7T/yCcoiNLzsf9eHOauAafB3UIar8PKwSL7VCf1nW6Y39K\n"];
    [pk appendFormat:@"twjjp53Svu7KnWq0xOj4dAQgUcYBg7F6ZlIMqxXgzDckOYwsOBC3fkqKJTzK8dWn\n"];
    [pk appendFormat:@"swIDAQAB\n"];
    [pk appendFormat:@"-----END PUBLIC KEY-----"];
    
    NSMutableString *privatekey = [NSMutableString new];
    [privatekey appendFormat:@"-----BEGIN RSA PRIVATE KEY-----\n"];
    [privatekey appendFormat:@"MIIEpAIBAAKCAQEAi3UDmdCJ4LVJAs+2EqwY0q3fw6N+++KdxfSJbBbprSc0J3+N\n"];
    [privatekey appendFormat:@"KiQjd+jERsDMJFzrjdndHn3z1grQ5D6p5ghpKyIAxbc/i7Td0lY3mYEiWcFO+N59\n"];
    [privatekey appendFormat:@"ORFIFH4y1jJ+KBywvwZk7KDNNGkAReJFQmqUFMoc4THAgRg25GjSncN+nnaK+dbw\n"];
    [privatekey appendFormat:@"keG5fTL8vNJwn95v8ZLA531Vv8XzIPKIxUldwzdZh/+4hsRYoLaKbV7T/yCcoiNL\n"];
    [privatekey appendFormat:@"zsf9eHOauAafB3UIar8PKwSL7VCf1nW6Y39Ktwjjp53Svu7KnWq0xOj4dAQgUcYB\n"];
    [privatekey appendFormat:@"g7F6ZlIMqxXgzDckOYwsOBC3fkqKJTzK8dWnswIDAQABAoIBAEL4yebnSB+az9pC\n"];
    [privatekey appendFormat:@"yAyFi1I54BkC/muWs/Ap9IjtJAFcr2Y8kh1nx4TBSukzk5Xu7cxskQ0graXgAdtq\n"];
    [privatekey appendFormat:@"4IqxBViKdtZ8n07HaDOn5gGZC1cRR4yqxHZQf04gIOfOzdkTlinWt0cQHhwKRPBK\n"];
    [privatekey appendFormat:@"rrorlru5KE9ZZjpY15uvX14WUUtlpOxJQz7qDuaefrO0BhJyav5f8ijl3NuyYukh\n"];
    [privatekey appendFormat:@"0mJdj68N7/8InuDg9wZMp7mxY7YdZyQQ5kVgYbD+aNzU4IimGXhj71Nbzu6W52Gr\n"];
    [privatekey appendFormat:@"PvKVjl0llfhQosM4Q0QO9v22E2SdI3lx7gIcwOkQ6c79wfiGEE4HkbdNNSdvjblO\n"];
    [privatekey appendFormat:@"KB/BBrECgYEA9FMghF9Y/pD9tgWksuJWupPZL0DH/ydPMIcVamatZg/Dv+zoteeP\n"];
    [privatekey appendFormat:@"FuAZZmcMmkuWWdzASIKOJVEMLlIMxGKeGJ9SnT5PavD4vFHSbAnqf95YlAzMAXsn\n"];
    [privatekey appendFormat:@"VGGhBn8w7oC8/BDTCBocvjkSdH5zmTMZatvAy8wXOZIbI4AHqW182PkCgYEAkh8F\n"];
    [privatekey appendFormat:@"Omydv/O8p7pFlWiK5LUZrv3dDvBhwNssZ3vy6TnFSfdr6cbYmHl3/iRb5LSc4rBe\n"];
    [privatekey appendFormat:@"SMitpZ1WYDYzAieF0NdHlZC0CVp0W5pqYS5xWFKgEQXdnG2Bkim2WI8xQA9V8dfE\n"];
    [privatekey appendFormat:@"AU9mVKYzp6EwWxW0IWYf6CNMXXRqP7N7zaotPQsCgYEAxHuVSt7i0tYHMrqXGMSs\n"];
    [privatekey appendFormat:@"up7rqfSO4cLbDEuWDVtFVy6WXWJIQwFVMTBHPPLiT7M51kqQ178mURw8j4OsgMJO\n"];
    [privatekey appendFormat:@"Ib7+0TWq6HWhktC6R+gxjWNiGK2x4f8IQfPBa1geIa+mS4+8JmfZdaCwFr8ad7mA\n"];
    [privatekey appendFormat:@"V08iXMJkawf0izgK8VX7cQECgYEAkYvCimpsSym9zZgV/XePebYGKi8GBP5dcFsg\n"];
    [privatekey appendFormat:@"BMgKslLv9/gyjj6Zum6rngKbYdihuI8Sqw7xIFjzE4yJDGlPujDlRc5H9lUaN7A8\n"];
    [privatekey appendFormat:@"rCY1klNiyvH7xvewq2VPEzE2Tme4JNfVjbSH6mNOand9Eg0xSl9OAs0+IIx31JG0\n"];
    [privatekey appendFormat:@"DKyouPcCgYB3WULlZu5z6td0b89dbMBGtznxTQI0ARxNYxdNZM3GG7/MLgFfw/jW\n"];
    [privatekey appendFormat:@"2r2EOspQihRQVwsYL+0ETXaFhFhzpxQB/mDlzGJm6TfaiAjjhggCyVAwSWD+EjKL\n"];
    [privatekey appendFormat:@"kyNJA97ccMNGyqpCz1tkTzvAcNLDJeM6oKFIUTVOntFFPe8icEKMVw==\n"];
    [privatekey appendFormat:@"-----END RSA PRIVATE KEY-----"];

    NSString *keyTagPublic = @"br.com.moip.labs.moipsdktests.publickey";
    NSString *keyTagPrivate = @"br.com.moip.labs.moipsdktests.privatekey";
    
    [MPKUtilities importPublicKey:pk tag:keyTagPublic];
    [MPKUtilities importPrivateKey:privatekey tag:keyTagPrivate];
    
    NSString *creditCardNumber = @"4111111111111111";
    NSString *encryptedCreditCard = [MPKUtilities encryptData:creditCardNumber keyTag:keyTagPublic];
    NSString *decryptedCreditCard = [MPKUtilities decryptData:encryptedCreditCard keyTag:keyTagPrivate];
    
    XCTAssertEqualObjects(creditCardNumber, decryptedCreditCard, @"%@ %@", creditCardNumber, decryptedCreditCard);
}

- (void) testShouldCheckIfCertificateIsTrust
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://test.moip.com.br/"]];
    request.HTTPMethod = @"POST";
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [NSError new];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    XCTAssertNotEqual(error.code, kCFURLErrorServerCertificateUntrusted, @"SSL Certificate Untrusted");
}

#pragma mark - Methods Helper
- (NSString *) getMoipOrderId
{
    NSString *orderJSON = [self generateOrderJSON];
    NSString *url = [MPKUtilities urlWithEnv:MPKEnvironmentSANDBOX endpoint:@"/orders"];
    
    NSString *tokenAndKey = [NSString stringWithFormat:@"%@:%@", MOIPTOKENTESTS, MOIPKEYTESTS];
    NSData *encodedLoginData = [tokenAndKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth = [NSString stringWithFormat:@"Basic %@",  [encodedLoginData base64EncodedStringWithOptions:NSUTF8StringEncoding]];
    
    MoipHttpRequester *requester = [MoipHttpRequester requesterWithBasicAuthorization:auth];
    MoipHttpResponse *response = [requester post:url payload:orderJSON params:nil delegate:nil];
    if (response.httpStatusCode == kHTTPStatusCodeCreated)
    {
        id order = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
        return order[@"id"];
    }
    else if (response.urlErrorCode == kCFURLErrorServerCertificateUntrusted)
    {
        NSLog(@"SSL Certificate Untrusted");
    }
    else
    {
        id error = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", error);
    }
    return nil;
}

- (NSString *)generateOrderJSON
{
    NSMutableString *jsonOrder = [NSMutableString new];
    [jsonOrder appendFormat:@"{"];
    [jsonOrder appendFormat:@"  \"ownId\": \"id_proprio\","];
    [jsonOrder appendFormat:@"  \"amount\": {"];
    [jsonOrder appendFormat:@"    \"currency\": \"BRL\","];
    [jsonOrder appendFormat:@"    \"subtotals\": {"];
    [jsonOrder appendFormat:@"        \"shipping\": 200,"];
    [jsonOrder appendFormat:@"        \"addition\": 1000,"];
    [jsonOrder appendFormat:@"        \"discount\": 80"];
    [jsonOrder appendFormat:@"    }"];
    [jsonOrder appendFormat:@"  },"];
    [jsonOrder appendFormat:@"  \"items\": ["];
    [jsonOrder appendFormat:@"    {"];
    [jsonOrder appendFormat:@"      \"product\": \"Bicicleta Specialized Tarmac 26 Shimano Alivio\","];
    [jsonOrder appendFormat:@"      \"quantity\": 1,"];
    [jsonOrder appendFormat:@"      \"detail\": \"uma linda bicicleta\","];
    [jsonOrder appendFormat:@"      \"price\": 10000"];
    [jsonOrder appendFormat:@"    }"];
    [jsonOrder appendFormat:@"  ],"];
    [jsonOrder appendFormat:@"  \"customer\": {"];
    [jsonOrder appendFormat:@"    \"ownId\": \"teste\","];
    [jsonOrder appendFormat:@"    \"fullname\": \"Jose Silva\","];
    [jsonOrder appendFormat:@"    \"email\": \"josedasilva@email.com\","];
    [jsonOrder appendFormat:@"    \"birthDate\": \"1988-12-30\","];
    [jsonOrder appendFormat:@"    \"taxDocument\": {"];
    [jsonOrder appendFormat:@"      \"type\": \"CPF\","];
    [jsonOrder appendFormat:@"      \"number\": \"22222222222\""];
    [jsonOrder appendFormat:@"    },"];
    [jsonOrder appendFormat:@"    \"phone\": {"];
    [jsonOrder appendFormat:@"      \"countryCode\": \"55\","];
    [jsonOrder appendFormat:@"      \"areaCode\": \"11\","];
    [jsonOrder appendFormat:@"      \"number\": \"66778899\""];
    [jsonOrder appendFormat:@"    },"];
    [jsonOrder appendFormat:@"    \"addresses\": ["];
    [jsonOrder appendFormat:@"      {"];
    [jsonOrder appendFormat:@"        \"type\": \"BILLING\","];
    [jsonOrder appendFormat:@"        \"street\": \"Avenida Faria Lima\","];
    [jsonOrder appendFormat:@"        \"streetNumber\": 2927,"];
    [jsonOrder appendFormat:@"        \"complement\": 8,"];
    [jsonOrder appendFormat:@"        \"district\": \"Itaim\","];
    [jsonOrder appendFormat:@"        \"city\": \"Sao Paulo\","];
    [jsonOrder appendFormat:@"        \"state\": \"SP\","];
    [jsonOrder appendFormat:@"        \"country\": \"BRA\","];
    [jsonOrder appendFormat:@"        \"zipCode\": \"01234000\""];
    [jsonOrder appendFormat:@"      }"];
    [jsonOrder appendFormat:@"    ]"];
    [jsonOrder appendFormat:@"  }"];
    [jsonOrder appendFormat:@"}"];
    
    return jsonOrder;
}


@end
