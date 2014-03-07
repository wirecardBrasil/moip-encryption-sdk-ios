//
//  MoipSDKTests.m
//  MoipSDKTests
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MoipSDK.h"

@interface MoipSDKTests : XCTestCase <MoipPaymentDelegate>

@property BOOL executingAsyncTest;

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
    self.executingAsyncTest = YES;
    
    CardHolder *holder = [CardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = CPF;
    holder.documentNumber = @"99999999999";
    holder.phoneCountryCode = 55;
    holder.phoneAreaCode = 11;
    holder.phoneNumber = 975902554;
    
    CreditCard *card = [CreditCard new];
    card.expirationMonth = 06;
    card.expirationYear = 2018;
    card.number = @"9999999999999999";
    card.cvv = @"999";
    card.cardholder = holder;
    
    Payment *payment = [Payment new];
    payment.moipOrderId = @"ORD_123";
    payment.installmentCount = 2;
    payment.method = CREDIT_CARD;
    payment.creditCard = card;
    
    MoipSDK *moip = [MoipSDK new];
    moip.delegate = self;
    [moip submitPayment:payment];
    
    while (self.executingAsyncTest);
}


#pragma mark - MoipSDK
- (void) paymentCreated:(PaymentTransaction *)paymentTransaction
{
    self.executingAsyncTest = NO;
    XCTAssertEqual(paymentTransaction.status, PaymentStatusInAnalysis, @"");
}

- (void) paymentFailed:(PaymentTransaction *)paymentTransaction error:(NSError *)error
{
    self.executingAsyncTest = NO;
    XCTAssertEqual(paymentTransaction.status, PaymentStatusCancelled, @"");
}

@end
