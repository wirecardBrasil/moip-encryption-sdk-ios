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

@property NSString *authorization;

@end

@implementation MoipSDKTests

- (void)setUp
{
    [super setUp];
    self.authorization = @"Basic N1hKTzFXVUE3Qk1JVlpUT1ZCOTBZTkpISk5QQ05YSEQ6N0dXSjJBNVNYSDI4UkNXRDVZQ0ozQlVIUldYRzRIT1BPWlBRMEJNSA==";
    
    NSMutableString *pk = [NSMutableString new];
    [pk appendFormat:@"-----BEGIN PUBLIC KEY-----\n"];
    [pk appendFormat:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDce1lVh/ZelksxZaypzs0l+U1g\n"];
    [pk appendFormat:@"lruZD3qnh9PrQQpT2DKh/JeRgOmMfU4fz7ayHnSRRvNWRyIDLBkWJr5KIq7jWgDS\n"];
    [pk appendFormat:@"aGmb+QpAU8xm8iKx5mjepp1wl9guXXlDjQlCRoQfRCZtTSN0IVIlDcAfAhaK/ot8\n"];
    [pk appendFormat:@"+hF+iW+8wgSrjVO+9wIDAQAB\n"];
    [pk appendFormat:@"-----END PUBLIC KEY-----"];
    
    NSMutableString *privatekey = [NSMutableString new];
    [privatekey appendFormat:@"-----BEGIN RSA PRIVATE KEY-----"];
    [privatekey appendFormat:@"MIICXAIBAAKBgQDce1lVh/ZelksxZaypzs0l+U1glruZD3qnh9PrQQpT2DKh/JeR"];
    [privatekey appendFormat:@"gOmMfU4fz7ayHnSRRvNWRyIDLBkWJr5KIq7jWgDSaGmb+QpAU8xm8iKx5mjepp1w"];
    [privatekey appendFormat:@"l9guXXlDjQlCRoQfRCZtTSN0IVIlDcAfAhaK/ot8+hF+iW+8wgSrjVO+9wIDAQAB"];
    [privatekey appendFormat:@"AoGAdkzI1hepnX7OwaZoSoRnlqR5XAYEik+/4/wBPQ0c2Xf7UucQ/EVLCtKBBJiS"];
    [privatekey appendFormat:@"0md87CZBkl2AZmtW2ofXOjf51Yvmu3dvwP3E/hOmFNP55KKeqWxzJzQbuQXPMp3T"];
    [privatekey appendFormat:@"ICBqwFUCamDrbUUlE3MSFCnYHVYJNL2CG+gaPVNp+0dR36ECQQD2zUHUjtnrH5/+"];
    [privatekey appendFormat:@"3wdEVmA1BSP8f2G0PyrTHx8kevzJaOL4gsRLooButgvmHpfIr3412CSVw6rKKbSq"];
    [privatekey appendFormat:@"6bP9K/1NAkEA5LL47inYweWl1LUq1se+Inhnj381Elgf7AV0xiqE1FwyxlV5v3Hh"];
    [privatekey appendFormat:@"b1Lp5A9RnRSk8/wKGHtrep7W3T9gnv+bUwJAdyDoj8NMaPPg9NOO3GudELqkfjK2"];
    [privatekey appendFormat:@"ZJzA/RtemutKraWVOUNVoPSVbdstryxBM7uR/keQkUHbZK3w6TbZjHD5WQJAe/uO"];
    [privatekey appendFormat:@"ukbTbOKb0UHaFJA6wqM1uXSECArgW2rl0JyyYBIPsLgcBa6uQVTY2bt4Skkr192W"];
    [privatekey appendFormat:@"d4lJTjOYVl+KeQgnYwJBALSKPBXdvYWaVqihHn6l/SbawoOUsEC6M0bMupqeUpgU"];
    [privatekey appendFormat:@"7XhyPUraO8WkcHz/WHXiBrtUyqGP0nz9Izc7H7yU5F4="];
    [privatekey appendFormat:@"-----END RSA PRIVATE KEY-----"];
    
    [MPKUtilities importPublicKey:pk];
    [MPKUtilities importPrivateKey:privatekey];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShouldCreateAPaymentInMoip
{
    MoipSDK *sdk = [MoipSDK startWithAuthorization:self.authorization];
    
    MPKCardHolder *holder = [MPKCardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = MPKCardHolderDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    MPKCreditCard *card = [MPKCreditCard new];
    card.expirationMonth = 06;
    card.expirationYear = 18;
    card.number = @"4903762433566341";
    card.cvv = @"751";
    card.cardholder = holder;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = [sdk getMoipOrderId];
    payment.installmentCount = 2;
    payment.method = MPKPaymentMethodCreditCard;
    payment.creditCard = card;
    
    [sdk submitPayment:payment success:^(MPKPaymentTransaction *transaction) {
        XCTAssertEqual(transaction.status, MPKPaymentStatusInAnalysis, @"Status equals to InAnalysis");
    } failure:^(MPKPaymentTransaction *transaction, NSError *error) {
        NSString *descError = error.description;
        XCTAssertEqual(transaction.status, MPKPaymentStatusInAnalysis, @"%@", descError);
    }];
}

- (void) testShouldEncryptAndDecryptACreditCardNumber
{
    NSString *creditCardNumber = @"4903762433566341";
    NSString *encryptedCreditCard = [MPKUtilities encryptData:creditCardNumber];
    NSString *decryptedCreditCard = [MPKUtilities decryptData:encryptedCreditCard];
    
    XCTAssertEqualObjects(creditCardNumber, decryptedCreditCard, @"%@ %@", creditCardNumber, decryptedCreditCard);
}

- (void) testShouldReturnErrorTokenIsInvalid
{
    MoipSDK *sdk = [MoipSDK startWithAuthorization:@"xxx"];
    
    MPKCardHolder *holder = [MPKCardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = MPKCardHolderDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    MPKCreditCard *card = [MPKCreditCard new];
    card.expirationMonth = 06;
    card.expirationYear = 18;
    card.number = @"4903762433566341";
    card.cvv = @"751";
    card.cardholder = holder;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = [sdk getMoipOrderId];
    payment.installmentCount = 2;
    payment.method = MPKPaymentMethodCreditCard;
    payment.creditCard = card;
    
    [sdk submitPayment:payment success:^(MPKPaymentTransaction *transaction) {
        XCTAssertEqual(transaction.status, MPKPaymentStatusInAnalysis, @"Status equals to InAnalysis");
    } failure:^(MPKPaymentTransaction *transaction, NSError *error) {
        NSString *descError = error.description;
        XCTAssertEqual(error.code, kCFURLErrorUserCancelledAuthentication, @"%@", descError);
    }];
}


@end
