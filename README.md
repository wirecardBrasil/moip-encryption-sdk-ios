Veja abaixo como integrar o seu app com o Moip.


### 1. Importar o SDK

```#import <MoipSDK/MoipSDK.h>```

### 2. Criar o seu cartão de credito

```objective-c
NSString *myPublicKey = @"";
[MoipSDK importPublicKey:myPublicKey];
```

### 3. Criptografar os dados com base no seu MPKCreditCard
```
MPKCreditCard *creditCard = [MPKCreditCard new];
creditCard.number = @"4111111111111111";
creditCard.cvc = @"999";
creditCard.expirationMonth = @"07";
creditCard.expirationYear = @"15";
    
NSString * cryptData = [MoipSDK encryptCreditCard:creditCard];
```