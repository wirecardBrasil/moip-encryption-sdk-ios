//
//  MoipSDKTests.m
//  MoipSDKTests
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MoipSDK.h"

@interface MoipSDKTests : XCTestCase

@property NSString *authorization;

@end

@implementation MoipSDKTests

- (void)setUp
{
    [super setUp];
    self.authorization = @"Basic N1hKTzFXVUE3Qk1JVlpUT1ZCOTBZTkpISk5QQ05YSEQ6N0dXSjJBNVNYSDI4UkNXRDVZQ0ozQlVIUldYRzRIT1BPWlBRMEJNSA==";
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
