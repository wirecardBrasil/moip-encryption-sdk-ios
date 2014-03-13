# Moip SDK - iOS

With the Moip SDK, you can process payments using Moip from your application with security and easy integration.

To receive payment in your app without concern with encrypt data and with traffic credit card data, you can use the MoipPaymentKit (MPK).

See below how can integrate in your app.

### Using custom UITextField to Credit Card

```objective-c

MyViewController.h
@interface MyCheckoutViewController : UIViewController

@property (strong, nonatomic) MPKCreditCardTextField *txtCreditCard;

@end

MyViewController.m
@implementation MyCheckoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.txtCreditCard = [[MPKCreditCardTextField alloc] initWithFrame:CGRectMake(20, 180, 280, 30)];
    self.txtCreditCard.delegate = self;
    [self.txtCreditCard setBorderStyle:UITextBorderStyleRoundedRect];
    
    [self.view addSubview:self.txtCreditCard];
}

//... My code

@end
```

Now, just use this field to get credit card number, already encrypted.


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
    card.number = self.txtCreditCard.text; //credit card encrypted with you public key
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
