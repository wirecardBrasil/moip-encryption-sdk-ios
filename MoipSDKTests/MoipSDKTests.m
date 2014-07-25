//
//  MoipSDKTests.m
//  MoipSDKTests
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#define MOIPTOKENTESTS @"01010101010101010101010101010101"
#define MOIPKEYTESTS @"ABABABABABABABABABABABABABABABABABABABAB"

#import <XCTest/XCTest.h>
#import "MoipSDK.h"
#import "MPKCustomer.h"
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

- (void)testShouldCreatePaymentInMoip
{
    MPKCardHolder *holder = [MPKCardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = MPKDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    MPKCreditCard *card = [MPKCreditCard new];
    card.expirationMonth = 05;
    card.expirationYear = 18;
    card.number = [MPKUtilities encryptData:@"4111111111111111" keyTag:kPublicKeyName];
    card.cvv = [MPKUtilities encryptData:@"999" keyTag:kPublicKeyName];
    card.cardholder = holder;
    
    MPKFundingInstrument *instrument = [MPKFundingInstrument new];
    instrument.creditCard = card;
    instrument.method = MPKMethodTypeCreditCard;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = [self getMoipOrderId];
    payment.installmentCount = 1;
    payment.fundingInstrument = instrument;
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] submitPayment:payment success:^(MPKPaymentTransaction *transaction) {

        NSLog(@"%@", transaction.paymentId);
        
        waitingForBlock = NO;
        XCTAssertNotNil(transaction, @"payment transaction is nil");
        
    } failure:^(NSArray *errorList) {
        
        NSLog(@"%@", errorList);
        
        waitingForBlock = NO;
        XCTAssertNil(errorList, @"");
    }];
    
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void) testShouldCreateCustomerWithCreditCard
{
    __block BOOL waitingForBlock = YES;
    
    MPKAddress *address = [MPKAddress new];
    address.type = MPKAddressTypeBilling;
    address.street = @"Rua Francisco Antunes";
    address.streetNumber = @"437";
    address.complement = @"apt 33 bl 1";
    address.district = @"Vila Augusta";
    address.city = @"Guarulhos";
    address.state = @"São Paulo";
    address.country = @"BRA";
    address.zipCode = @"07040010";
    
    MPKAddress *address2 = [MPKAddress new];
    address2.type = MPKAddressTypeShipping;
    address2.street = @"Rua Francisco Antunes";
    address2.streetNumber = @"437";
    address2.complement = @"apt 33 bl 1";
    address2.district = @"Vila Augusta";
    address2.city = @"Guarulhos";
    address2.state = @"São Paulo";
    address2.country = @"BRA";
    address2.zipCode = @"07040010";
    
    MPKCardHolder *holder = [MPKCardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = MPKDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    MPKCreditCard *card = [MPKCreditCard new];
    card.expirationMonth = 06;
    card.expirationYear = 17;
#warning Fix this with PUBLIC KEY for integracao@labs.moip.com.br account
//    card.number = [MPKUtilities encryptData:@"5224460508980328" keyTag:kPublicKeyName];
//    card.cvv = [MPKUtilities encryptData:@"999" keyTag:kPublicKeyName];
    card.number = @"5224460508980328";
    card.cvv = @"473";
    card.cardholder = holder;
    
    MPKFundingInstrument *fundingInstrument = [MPKFundingInstrument new];
    fundingInstrument.creditCard = card;
    fundingInstrument.method = MPKMethodTypeCreditCard;
    
    MPKCustomer *customer = [MPKCustomer new];
    customer.ownId = @"idNovoCustomer";
    customer.fullname = @"Fernando Nazario Sousa";
    customer.email = @"fnazarios@gmail.com";
    customer.phoneAreaCode = 11;
    customer.phoneNumber = 975902554;
    customer.birthDate = [NSDate date];
    customer.documentType = MPKDocumentTypeCPF;
    customer.documentNumber = 36021561848;
    customer.addresses = @[address, address2];
    customer.fundingInstrument = fundingInstrument;
    
    [[MoipSDK session] createCustomer:customer success:^(MPKCustomer *customer, NSString *moipCustomerId, NSString *moipCreditCardId) {
        waitingForBlock = NO;
        
        NSLog(@"---------------------------------------------------------------->>>>>>>>%@", moipCustomerId);
        NSLog(@"---------------------------------------------------------------->>>>>>>>%@", moipCreditCardId);
        XCTAssertNotNil(customer.moipCustomerId, @"");
        XCTAssertNotNil(customer.fundingInstrument.creditCard.moipCreditCardId, @"");
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

- (void) testShouldCreatePaymentWithSavedCreditCard
{
    //CRC-JO5TKHG1UMAN
    MPKCardHolder *holder = [MPKCardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = MPKDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    MPKCreditCard *card = [MPKCreditCard new];
    card.moipCreditCardId = @"CRC-JO5TKHG1UMAN";
    card.cvv = @"999";
    
    MPKFundingInstrument *instrument = [MPKFundingInstrument new];
    instrument.creditCard = card;
    instrument.method = MPKMethodTypeCreditCard;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = [self getMoipOrderId];
    payment.installmentCount = 1;
    payment.fundingInstrument = instrument;
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] submitPayment:payment success:^(MPKPaymentTransaction *transaction) {
        
        NSLog(@"%@", transaction.paymentId);
        
        waitingForBlock = NO;
        XCTAssertNotNil(transaction, @"payment transaction is nil");
        
    } failure:^(NSArray *errorList) {
        
        NSLog(@"%@", errorList);
        
        waitingForBlock = NO;
        XCTAssertNil(errorList, @"");
    }];
    
    while(waitingForBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
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
