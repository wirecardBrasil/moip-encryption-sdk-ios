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

@end

@implementation MoipSDKTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShouldCreateAPaymentInMoip
{
    
    CardHolder *holder = [CardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = CardHolderDocumentTypeCPF;
    holder.documentNumber = @"99999999999";
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
    payment.moipOrderId = @"ORD-S8MIMS4WVKPH";
    payment.installmentCount = 2;
    payment.method = PaymentMethodCreditCard;
    payment.creditCard = card;
    
    [[MoipSDK new] submitPayment:payment success:^(PaymentTransaction *transaction) {
        XCTAssertEqual(transaction.payment.status, PaymentStatusInAnalysis, @"Status equals to InAnalysis");
    } failure:^(PaymentTransaction *transaction, NSError *error) {
        XCTAssertEqual(transaction.payment.status, PaymentStatusInAnalysis, @"Error");
    }];
}


@end
