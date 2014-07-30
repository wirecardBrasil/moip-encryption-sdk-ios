# Moip SDK Beta - iOS

Com o MoipSDK você pode receber pagamentos no seu aplicativo sem se preocupar com criptografia e de uma maneira fácil e simples.

Veja abaixo como integrar o seu app com o Moip.

### Iniciar o SDK

O primeiro passo iniciar o SDK passando seu Token, Key, Chave Publica RSA e o endpoint para criação da order do seu ecommerce.

```objective-c
    NSString *path = [[NSBundle mainBundle] pathForResource:@"myPublicKey" ofType:@"txt"];
    NSString *publicKeyText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [MoipSDK startSessionWithToken:MOIPTOKEN
                               key:MOIPKEY
                         publicKey:publicKeyText
                       environment:MPKEnvironmentSANDBOX];
```

### Criar um pedido (ORDER)

```objective-c
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
    customer.fullname = @"José da silva";
    customer.email = @"josedasilva@email.com";
    customer.phoneAreaCode = 11;
    customer.phoneNumber = 999999999;
    customer.birthDate = [NSDate date];
    customer.documentType = MPKDocumentTypeCPF;
    customer.documentNumber = 39999999399;
    customer.addresses = @[address];
    
    MPKAmount *amount = [MPKAmount new];
    amount.shipping = 1000;
    
    MPKItem *item = [MPKItem new];
    item.quantity = 1;
    item.product = @"Macbook Pro Unibody Late 2011";
    item.detail = @"Macbook Pro Unibody Late 2011 c/ SSD e 8 GB de memoria";
    item.price = 10000;
    
    MPKOrder *newOrder = [MPKOrder new];
    newOrder.ownId = @"seuID";
    newOrder.amount = amount;
    newOrder.items = @[item];
    newOrder.customer = customer;
    
    __block BOOL waitingForBlock = YES;
    [[MoipSDK session] createOrder:newOrder success:^(MPKOrder *order, NSString *moipOrderId) {
        NSLog(@"---->>>>>>>>%@", moipOrderId);
        
    } failure:^(NSArray *errorList) {
        
        NSLog(@"%@", errorList);
    }];
```


### Criar um pagamento (Payment)

```objective-c
	
```