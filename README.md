### Usando o MoipSDK

Veja abaixo como integrar o seu app com o Moip.


#### 1. Importar o SDK

```#import <MoipSDK/MoipSDK.h>```

#### 2. Criar o seu cartão de credito

```objective-c
NSString *myPublicKey = @"";
[MoipSDK importPublicKey:myPublicKey];
```

#### 3. Criptografar os dados com base no seu MPKCreditCard
```objective-c
MPKCreditCard *creditCard = [MPKCreditCard new];
creditCard.number = @"4111111111111111";
creditCard.cvc = @"999";
creditCard.expirationMonth = @"07";
creditCard.expirationYear = @"15";
    
NSString * cryptData = [MoipSDK encryptCreditCard:creditCard];
```

### Validações

Usando o MoipSDK, você pode realizar varias verificações para checar se os dados do cartão de credito.

##### Número do cartão
```objective-c
MPKCreditCard *creditCard = [MPKCreditCard new];
creditCard.number = @"4111111111111111";
    
BOOL isValidCreditCard = creditCard.isNumberValid;
```

##### Código de segurança
```objective-c
MPKCreditCard *creditCard = [MPKCreditCard new];
creditCard.cvc = @"123";
    
BOOL isValid = creditCard.isSecurityCodeValid;
```

##### Data de Expiração
```objective-c
MPKCreditCard *creditCard = [MPKCreditCard new];
creditCard.expirationMonth = @"06";
creditCard.expirationYear = @"2018";
    
BOOL isValid = creditCard.isExpiryDateValid;
```
