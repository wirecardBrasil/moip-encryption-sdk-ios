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
    
    CardHolder *holder = [CardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = CardHolderDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    CreditCard *card = [CreditCard new];
    card.expirationMonth = 06;
    card.expirationYear = 18;
    card.number = @"4903762433566341";
    card.cvv = @"751";
    card.cardholder = holder;
    
    Payment *payment = [Payment new];
    payment.moipOrderId = [sdk getMoipOrderId];
    payment.installmentCount = 2;
    payment.method = PaymentMethodCreditCard;
    payment.creditCard = card;
    
    [sdk submitPayment:payment success:^(PaymentTransaction *transaction) {
        XCTAssertEqual(transaction.status, PaymentStatusInAnalysis, @"Status equals to InAnalysis");
    } failure:^(PaymentTransaction *transaction, NSError *error) {
        NSString *descError = error.description;
        XCTAssertEqual(transaction.status, PaymentStatusInAnalysis, @"%@", descError);
    }];
}

- (void) testShouldReturnErrorTokenIsInvalid
{
    MoipSDK *sdk = [MoipSDK startWithAuthorization:@"xxx"];
    
    CardHolder *holder = [CardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = CardHolderDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    CreditCard *card = [CreditCard new];
    card.expirationMonth = 06;
    card.expirationYear = 18;
    card.number = @"4903762433566341";
    card.cvv = @"751";
    card.cardholder = holder;
    
    Payment *payment = [Payment new];
    payment.moipOrderId = [sdk getMoipOrderId];
    payment.installmentCount = 2;
    payment.method = PaymentMethodCreditCard;
    payment.creditCard = card;
    
    [sdk submitPayment:payment success:^(PaymentTransaction *transaction) {
        XCTAssertEqual(transaction.status, PaymentStatusInAnalysis, @"Status equals to InAnalysis");
    } failure:^(PaymentTransaction *transaction, NSError *error) {
        NSString *descError = error.description;
        XCTAssertEqual(error.code, kCFURLErrorUserCancelledAuthentication, @"%@", descError);
    }];
}


@end
