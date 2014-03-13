# Moip SDK - iOS

With the Moip SDK, you can process payments using Moip from your application with security and easy integration.

```objective-c

    MoipSDK *sdk = [MoipSDK startWithAuthorization:@"your authorization"];
    
    MPKCardHolder *holder = [MPKCardHolder new];
    holder.fullname = @"Fernando Nazario Sousa";
    holder.birthdate = @"1988-04-27";
    holder.documentType = MPKCardHolderDocumentTypeCPF;
    holder.documentNumber = @"36006363099";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"995547052";
    
    MPKCreditCard *card = [MPKCreditCard new];
    card.expirationMonth = 06;
    card.expirationYear = 18;
    card.number = @"credit card encrypted with you public key";
    card.cvv = @"cvv encrypted with you public key";
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

```