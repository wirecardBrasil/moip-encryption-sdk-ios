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
//    [pk appendFormat:@"-----BEGIN PUBLIC KEY-----\n"];
//    [pk appendFormat:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoBttaXwRoI1Fbcond5mS\n"];
//    [pk appendFormat:@"7QOb7X2lykY5hvvDeLJelvFhpeLnS4YDwkrnziM3W00UNH1yiSDU+3JhfHu5G387\n"];
//    [pk appendFormat:@"O6uN9rIHXvL+TRzkVfa5iIjG+ap2N0/toPzy5ekpgxBicjtyPHEgoU6dRzdszEF4\n"];
//    [pk appendFormat:@"ItimGk5ACx/lMOvctncS5j3uWBaTPwyn0hshmtDwClf6dEZgQvm/dNaIkxHKV+9j\n"];
//    [pk appendFormat:@"Mn3ZfK/liT8A3xwaVvRzzuxf09xJTXrAd9v5VQbeWGxwFcW05oJulSFjmJA9Hcmb\n"];
//    [pk appendFormat:@"DYHJT+sG2mlZDEruCGAzCVubJwGY1aRlcs9AQc1jIm/l8JwH7le2kpk3QoX+gz0w\n"];
//    [pk appendFormat:@"WwIDAQAB\n"];
//    [pk appendFormat:@"-----END PUBLIC KEY-----"];
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

- (void) testShouldFucking
{
    NSString *cryptData = [MPKUtilities encryptData:@"4111111111111111"];
    
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
    card.number = @"4111111111111111";//[MPKUtilities encryptData:@"4111111111111111"];
    card.cvv = @"999";//[MPKUtilities encryptData:@"999"];
    card.cardholder = holder;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = [self getMoipOrderId];
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
    [MPKUtilities removeKey:kPublicKeyName];
    [MPKUtilities removeKey:kPrivateKeyName];
    
    NSMutableString *privatekey = [NSMutableString new];
    [privatekey appendFormat:@"-----BEGIN RSA PRIVATE KEY-----"];
    [privatekey appendFormat:@"MIICXQIBAAKBgQDLnyIfrrqmbrTpBtPOuMmuZZzE22E4OP5fNRP8xS8wl/cGSX+4"];
    [privatekey appendFormat:@"sYRWouu0vxIOfq7mNavycxHRXtsF2R6y5hhSkE4ji5xsQB6ZOvzNDfeflnzuJYVH"];
    [privatekey appendFormat:@"OSPAFXG37CIJBELYnSoUVx5wPezAN0I6mFukMWBf7rOQ9qlHAw4oIuWK5wIDAQAB"];
    [privatekey appendFormat:@"AoGBAJed+4u50FOjNWQaaFaSM+J+2PegHsj9bzM3U5Wwwc2eKhrtWYQN8muMTpQ8"];
    [privatekey appendFormat:@"fdZ7MAJMzqbuVcMfrViybfBp8osbNCDCsiF+fFx5/b4StmxQLPTbShv9wC/hrxBf"];
    [privatekey appendFormat:@"H4IR11eQC6HB17KIwNZX74dGQU1/vZ5bpQq4CYgYI2utGp+ZAkEA8pBX8nj19L7x"];
    [privatekey appendFormat:@"YyGRbxy2faMBX34LqjMchh7PSYSdXDc0fqREdzPHRJvwQMhWHISEDAnuT3LMCpZC"];
    [privatekey appendFormat:@"CzVluDCsOwJBANbmkp3xxrEIFY5unSrtG9q0pC7oGfKqavITNMZZ81plqm2a8v/c"];
    [privatekey appendFormat:@"yaIX9KIzHhSwtdiCXj9HyVbBfZCtDlA2bUUCQFwow4F4u9pVgdksM9mHiz6I5Ein"];
    [privatekey appendFormat:@"1z6/VKMQqalBHZif0O4c83Zm0dsbdFjoxO7o2lLIoybEcwnCtS0VCKTGuWkCQGbu"];
    [privatekey appendFormat:@"HT+ldEOK2bhU5taOpw7EAvesl/ERCxRTeq2em96qX00MMGO4vqLy0mt2DGxgj1ja"];
    [privatekey appendFormat:@"aIXqvlbdamUHXpmw1/kCQQCNRjrNfEhA+QE4VOsmaNCVe49it2n1hEoIu6sV7Jmw"];
    [privatekey appendFormat:@"rAWnIqIRmFei3aMvmm/bqoHuMwRwKj9bFCKMuGtAb2+Y"];
    [privatekey appendFormat:@"-----END RSA PRIVATE KEY-----"];
    
    
    NSMutableString *pk = [NSMutableString new];
    [pk appendFormat:@"-----BEGIN PUBLIC KEY-----"];
    [pk appendFormat:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDLnyIfrrqmbrTpBtPOuMmuZZzE"];
    [pk appendFormat:@"22E4OP5fNRP8xS8wl/cGSX+4sYRWouu0vxIOfq7mNavycxHRXtsF2R6y5hhSkE4j"];
    [pk appendFormat:@"i5xsQB6ZOvzNDfeflnzuJYVHOSPAFXG37CIJBELYnSoUVx5wPezAN0I6mFukMWBf"];
    [pk appendFormat:@"7rOQ9qlHAw4oIuWK5wIDAQAB"];
    [pk appendFormat:@"-----END PUBLIC KEY-----"];
    
    [MPKUtilities importPublicKey:pk];
    [MPKUtilities importPrivateKey:privatekey];
    
    NSString *creditCardNumber = @"4903762433566341";
    NSString *encryptedCreditCard = [MPKUtilities encryptData:creditCardNumber];
    NSString *decryptedCreditCard = [MPKUtilities decryptData:encryptedCreditCard];
    
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
