# Moip SDK Beta - iOS

Com o MoipSDK você pode receber pagamentos no seu aplicativo sem se preocupar com criptografia dos dados, formulário de pagamento e etc.

Veja abaixo como integrar o seu app com o Moip.

### Usando o checkout moip

MyViewController.h
```objective-c
#import <MoipSDK/MoipSDK.h>
#import <MoipSDK/MPKCheckoutViewController.h>
#import <MoipSDK/MPKConfiguration.h>


@interface MoipCheckoutViewController : UIViewController <MPKCheckoutDelegate>

@end
```
MyViewController.m
```
@implementation MyCheckoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"publicKey" ofType:@"pem"];
    NSString *publicKeyText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [MoipSDK startSessionWithToken:@"TOKEN_MOIP" // Ver nota 1
                               key:@"CHAVE_MOIP"
                         publicKey:publicKeyText
                       environment:MPKEnvironmentSANDBOX];
}

- (IBAction)btnBuyTouched:(id)sender
{    
    MPKConfiguration *config = [MPKConfiguration new];
    config.titleView = @"Pagamento";
    config.textFieldColor = [UIColor blackColor];
    config.textFieldFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
    config.showErrorFeedback = YES;  // Ver nota 2
    config.showSuccessFeedback = YES;  // Ver nota 3

    MPKCheckoutViewController *paymentViewController = [[MPKCheckoutViewController alloc] initWithConfiguration:config];
    paymentViewController.delegate = self;
    paymentViewController.moipOrderId = @"MOIP_ORDER_ID";  // Ver nota 4
    [self presentViewController:paymentViewController animated:YES completion:nil];
  
}

#pragma mark -
#pragma mark Moip Checkout delegate
- (void)paymentTransactionSuccess:(MPKPaymentTransaction *)transaction
{
    if (transaction.status == MPKPaymentStatusAuthorized)
    {
        NSLog(@"Yeah! Pagamento autorizado!");
    }
}

- (void)paymentTransactionFailure:(NSArray *)errorList
{
    NSLog(@"errors: %@", errorList);	
}

@end
```

### Notas

1. Acesse sua conta moip para ver o Token e chave
2. Quando a flag showErrorFeedback for YES, o proprio checkout exibirá uma mensagem amigável para erros no formulário de checkout ou erros no pagamento.
3. Quando a flag showSuccessFeedback for YES, o proprio checkout exibirá uma mensagem amigável para sucesso no pagamento.
4. O MOIP_ORDER_ID é o id do pedido já criado no moip. Se você ainda não fez isso, veja na documentação da API.