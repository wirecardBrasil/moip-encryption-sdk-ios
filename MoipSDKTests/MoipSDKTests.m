//
//  MoipSDKTests.m
//  MoipSDKTests
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#define MOIPTOKENTESTS @"01010101010101010101010101010101"
#define MOIPKEYTESTS @"ABABABABABABABABABABABABABABABABABABABAB"

#define kMoipOrderIdKey @"SavedMoipOrderIdUnitTests"
#define kMoipCustomerIdKey @"SavedCustomerIdUnitTests"
#define kMoipCreditCardIdKey @"SavedCreditCardIdUnitTests"

#define SaveValue(VALUE,KEY) [[NSUserDefaults standardUserDefaults] setValue:VALUE forKey:KEY]
#define GetValue(KEY) [[NSUserDefaults standardUserDefaults] valueForKey:KEY]

#import <XCTest/XCTest.h>
#import "MoipSDK.h"
#import "MPKCustomer.h"
#import "MPKUtilities.h"
#import "MoipHttpRequester.h"
#import "MoipHttpResponse.h"
#import "HTTPStatusCodes.h"

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
    
    NSLog(@"public key:\n%@", publicKeyTests);
    [MoipSDK startSessionWithToken:MOIPTOKENTESTS
                               key:MOIPKEYTESTS
                         publicKey:publicKeyTests
                       environment:MPKEnvironmentSANDBOX];
}

- (void)tearDown
{
    [super tearDown];
}

- (void) test01ShouldEncryptData
{
    NSString *cryptData = [MPKUtilities encryptData:@"4111111111111111" keyTag:kPublicKeyName];
    XCTAssertNotNil(cryptData, @"");
}

- (void) test02ShouldCreateMoipOrderId
{
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
    
    MPKCustomer *customer = [MPKCustomer new];
    customer.ownId = @"idNovoCustomer";
    customer.fullname = @"Fernando Nazario Sousa";
    customer.email = @"fnazarios@gmail.com";
    customer.phoneAreaCode = 11;
    customer.phoneNumber = 975902554;
    customer.birthDate = [NSDate date];
    customer.documentType = MPKDocumentTypeCPF;
    customer.documentNumber = @"36021561848";
    customer.addresses = @[address];
    
    MPKAmount *amount = [MPKAmount new];
    amount.shipping = 1000;
    amount.addition = 0;
    amount.discount = 0;
    
    MPKItem *item = [MPKItem new];
    item.quantity = 1;
    item.product = @"Macbook Pro Unibody Late 2011";
    item.detail = @"Macbook Pro Unibody Late 2011 c/ SSD e 8 GB de memoria";
    item.price = 10000;
    
    MPKOrder *newOrder = [MPKOrder new];
    newOrder.ownId = @"sandbox_OrderID_xxx";
    newOrder.amount = amount;
    newOrder.items = @[item];
    newOrder.customer = customer;
    
    NSMutableURLRequest *rq = [NSMutableURLRequest new];
    rq.HTTPMethod = @"POST";
    rq.URL = [NSURL URLWithString:@"https://test.moip.com.br/v2/orders"];
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] createOrder:rq order:newOrder success:^(MPKOrder *order, NSString *moipOrderId) {
        
        waitingForBlock = NO;
        NSLog(@">>>>>>>> %@", moipOrderId);
        SaveValue(moipOrderId, kMoipOrderIdKey);
        
        XCTAssertNotNil(moipOrderId, @"");
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

- (void)test03ShouldCreatePaymentInMoip
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
    card.expirationYear = 2018;
    card.number = [MPKUtilities encryptData:@"4111111111111111" keyTag:kPublicKeyName];
    card.cvv = [MPKUtilities encryptData:@"999" keyTag:kPublicKeyName];
    card.cardholder = holder;
    
    MPKFundingInstrument *instrument = [MPKFundingInstrument new];
    instrument.creditCard = card;
    instrument.method = MPKMethodTypeCreditCard;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = GetValue(kMoipOrderIdKey);
    payment.installmentCount = 1;
    payment.fundingInstrument = instrument;
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] submitPayment:payment success:^(MPKPaymentTransaction *transaction) {

        NSLog(@">>>>>>>> %@", transaction.paymentId);
        
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

- (void) test04ShouldCreateCustomerWithCreditCard
{
    __block BOOL waitingForBlock = YES;
    
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
    card.number = @"4111111111111111";//[MPKUtilities encryptData:@"4111111111111111" keyTag:kPublicKeyName];
    card.cvv = @"999"; //[MPKUtilities encryptData:@"999" keyTag:kPublicKeyName];
    card.cardholder = holder;
    
    MPKFundingInstrument *fundingInstrument = [MPKFundingInstrument new];
    fundingInstrument.creditCard = card;
    fundingInstrument.method = MPKMethodTypeCreditCard;
    
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
    
    MPKCustomer *customer = [MPKCustomer new];
    customer.ownId = @"idNovoCustomer1";
    customer.fullname = @"Fernando Nazario Sousa";
    customer.email = @"fnazarios@gmail.com";
    customer.phoneAreaCode = 11;
    customer.phoneNumber = 975902554;
    customer.birthDate = [NSDate date];
    customer.documentType = MPKDocumentTypeCPF;
    customer.documentNumber = @"36021561848";
    customer.addresses = @[address, address2];
    customer.fundingInstrument = fundingInstrument;
    
    [[MoipSDK session] createCustomer:customer success:^(MPKCustomer *customer, NSString *moipCustomerId, NSString *moipCreditCardId) {
        waitingForBlock = NO;
        
        NSLog(@">>>>>>>> %@", moipCustomerId);
        NSLog(@">>>>>>>> %@", moipCreditCardId);
        
        SaveValue(moipCustomerId, kMoipCustomerIdKey);
        SaveValue(moipCreditCardId, kMoipCreditCardIdKey);
        
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

- (void) test05ShouldCreateOrderWithSavedCustomer
{
    MPKCustomer *customer = [MPKCustomer new];
    customer.moipCustomerId = GetValue(kMoipCustomerIdKey);
    
    MPKAmount *amount = [MPKAmount new];
    amount.shipping = 1000;
    amount.addition = 0;
    amount.discount = 0;
    
    MPKItem *item = [MPKItem new];
    item.quantity = 1;
    item.product = @"Macbook Pro Unibody Late 2011";
    item.detail = @"Macbook Pro Unibody Late 2011 c/ SSD e 8 GB de memoria";
    item.price = 10000;
    
    MPKOrder *newOrder = [MPKOrder new];
    newOrder.ownId = @"sandbox_OrderID_xxx";
    newOrder.amount = amount;
    newOrder.items = @[item];
    newOrder.customer = customer;
    
    NSMutableURLRequest *rq = [NSMutableURLRequest new];
    rq.HTTPMethod = @"POST";
    rq.URL = [NSURL URLWithString:@"https://test.moip.com.br/v2/orders"];
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] createOrder:rq order:newOrder success:^(MPKOrder *order, NSString *moipOrderId) {
        
        waitingForBlock = NO;
        
        NSLog(@">>>>>>>> %@", moipOrderId);
        SaveValue(moipOrderId, kMoipOrderIdKey);
        
        XCTAssertNotNil(moipOrderId, @"");
        
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

- (void) test06ShouldCreatePaymentWithSavedCreditCard
{
    MPKCreditCard *card = [MPKCreditCard new];
    card.moipCreditCardId = GetValue(kMoipCreditCardIdKey);
    card.cvv = @"999";
    
    MPKFundingInstrument *instrument = [MPKFundingInstrument new];
    instrument.creditCard = card;
    instrument.method = MPKMethodTypeCreditCard;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = GetValue(kMoipOrderIdKey);
    payment.installmentCount = 1;
    payment.fundingInstrument = instrument;
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] submitPayment:payment success:^(MPKPaymentTransaction *transaction) {
        
        NSLog(@">>>>>>>> %@", transaction.paymentId);
        
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

- (void) test07ShouldCreateMoipOrderIdWihtoutShippingAddress
{
    MPKCustomer *customer = [MPKCustomer new];
    customer.ownId = @"idNovoCustomer";
    customer.fullname = @"Fernando Nazario Sousa";
    customer.email = @"fnazarios@gmail.com";
    customer.phoneAreaCode = 11;
    customer.phoneNumber = 975902554;
    customer.birthDate = [NSDate date];
    customer.documentType = MPKDocumentTypeCPF;
    customer.documentNumber = @"36021561848";
    
    MPKAmount *amount = [MPKAmount new];
    amount.shipping = 1000;
    amount.addition = 0;
    amount.discount = 0;
    
    MPKItem *item = [MPKItem new];
    item.quantity = 1;
    item.product = @"Macbook Pro Unibody Late 2011";
    item.detail = @"Macbook Pro Unibody Late 2011 c/ SSD e 8 GB de memoria";
    item.price = 10000;
    
    MPKOrder *newOrder = [MPKOrder new];
    newOrder.ownId = @"sandbox_OrderID_xxx";
    newOrder.amount = amount;
    newOrder.items = @[item];
    newOrder.customer = customer;
    
    NSMutableURLRequest *rq = [NSMutableURLRequest new];
    rq.HTTPMethod = @"POST";
    rq.URL = [NSURL URLWithString:@"https://test.moip.com.br/v2/orders"];
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] createOrder:rq order:newOrder success:^(MPKOrder *order, NSString *moipOrderId) {
        
        waitingForBlock = NO;
        NSLog(@">>>>>>>> %@", moipOrderId);
        SaveValue(moipOrderId, kMoipOrderIdKey);
        
        XCTAssertNotNil(moipOrderId, @"");
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
 
@end
