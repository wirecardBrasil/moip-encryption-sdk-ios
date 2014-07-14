//
//  MoipSDK.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MoipSDK.h"
//#import "ClisitefAsync.h"
#import "MoipHttpRequester.h"
#import "MoipHttpResponse.h"
#import "HTTPStatusCodes.h"
#import "MPKUtilities.h"

NSString* IPSitef = @"192.168.0.5";
NSString* Loja = @"00000000";
NSString* Terminal = @"IP000001";

@interface MoipSDK () //<ClisitefiDelegates>

@property NSString *auth;
@property MPKEnvironment environment;
//@property ClisitefAsync *clisitef;

@end

@implementation MoipSDK

static MoipSDK *sharedSingleton;

#pragma mark -
#pragma Start SDK
/**
 *  Inicia o SDK para iniciar as transações
 *
 *  @param token     Token (acesse sua conta no moip para ver seu token)
 *  @param key       Key (acesse sua conta no moip para ver seu token)
 *  @param publicKey Chave publica em plain text
 *  @param env       Ambiente que deseja utilizar o SDK
 *
 *  @return MoipSDK
 */
+ (MoipSDK *) startSessionWithToken:(NSString *)token
                                key:(NSString *)key
                          publicKey:(NSString *)publicKey
                        environment:(MPKEnvironment)env
{
    @synchronized(self)
    {
        if (!sharedSingleton)
        {
            NSData *encodedLoginData = [[NSString stringWithFormat:@"%@:%@", token, key] dataUsingEncoding:NSUTF8StringEncoding];
            sharedSingleton = [[MoipSDK alloc] init];
            sharedSingleton.auth = [NSString stringWithFormat:@"Basic %@",  [encodedLoginData base64EncodedStringWithOptions:NSUTF8StringEncoding]];
            sharedSingleton.environment = env;
            [sharedSingleton importPublicKey:publicKey];
        }
        return sharedSingleton;
    }
}

- (id) init
{
    self = [super init];
    if (self)
    {
//        self.clisitef = [[ClisitefAsync alloc] init];
//        [self.clisitef SetDelegates:self];
    }

    return self;
}

/**
 *  Retorna a sessão
 *
 *  @return MoipSDK
 */
+ (MoipSDK *) session
{
    return sharedSingleton;
}

/**
 *  importa a chave publica para criptografia dos dados de cartão e outros dados senseiveis
 *
 *  @param publicKeyPlainText chave publica em plain text
 */
- (void) importPublicKey:(NSString *)publicKeyPlainText
{
    if (publicKeyPlainText != nil && ![publicKeyPlainText isEqualToString:@""])
    {
        [MPKUtilities importPublicKey:publicKeyPlainText];
    }
}

#pragma mark -
#pragma mark Tef
- (void) configureSitef
{
//    [self.clisitef ConfiguraIntSiTefInterativo:IPSitef
//                                   pCodigoLoja:Loja
//                               pNumeroTerminal:Terminal ConfiguraResultado:0
//                         pParametrosAdicionais:@""];
}

#pragma mark -
#pragma mark Clisitef delegates
- (void) respostaConfigura:(int)pResposta
{
    NSLog(@"%i", pResposta);
}

#pragma mark -
#pragma mark Submit Payment
/**
 *  Cria um pagamento no moip
 *
 *  @param payment Dados do pagamento, como cartão de credito, parcelas...
 *  @param success Block de sucesso que retorna um MPKPaymentTransaction com o status do pagamento @see checkMPKPaymentStatus:
 *  @param failure Block de erro
 */
- (void)submitPayment:(MPKPayment *)payment success:(void (^)(MPKPaymentTransaction *))success failure:(void (^)(NSArray *))failure
{
    NSString *paymentJSON = [self generatePaymentJSON:payment];
    
    NSString *endpoint = [NSString stringWithFormat:@"/orders/%@/payments", payment.moipOrderId];
    NSString *url = [MPKUtilities urlWithEnv:self.environment endpoint:endpoint];
    
    MoipHttpRequester *requester = [MoipHttpRequester requesterWithBasicAuthorization:self.auth];
//    MoipHttpResponse *response = [requester post:url payload:paymentJSON params:nil delegate:nil];
//    if (response.httpStatusCode == kHTTPStatusCodeCreated || response.httpStatusCode == kHTTPStatusCodeOK)
//    {
//        [self checkResponseSuccess:response successBlock:success];
//    }
//    else
//    {
//        [self checkResponseFailure:response failureBlock:failure];
//    }
//    
    
    [requester post:url payload:paymentJSON completation:^(MoipHttpResponse *response) {
        if (response.httpStatusCode == kHTTPStatusCodeCreated || response.httpStatusCode == kHTTPStatusCodeOK)
        {
            [self checkResponseSuccess:response successBlock:success];
        }
        else
        {
            [self checkResponseFailure:response failureBlock:failure];
        }
    }];
}


#pragma mark Check Payment Status
/**
 *  Verifica o status do pagamento
 *
 *  @param transaction MPKPaymentTransaction retornado no metodo submitPayment
 */
- (void) checkMPKPaymentStatus:(MPKPaymentTransaction *)transaction
{

}

#pragma mark -
#pragma mark Check response after submit payment
- (void) checkResponseSuccess:(MoipHttpResponse *)response successBlock:(void (^)(MPKPaymentTransaction *))successBlock
{
    MPKPaymentTransaction *transac = [[MPKPaymentTransaction new] transactionWithJSON:response.content];
    successBlock(transac);
}

- (void) checkResponseFailure:(MoipHttpResponse *)response failureBlock:(void (^)(NSArray *))failureBlock
{
    NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
    NSArray *errorList = errorDict[@"errors"];
    if (errorList.count > 0)
    {
        NSMutableArray *errors = [NSMutableArray new];
        for (NSDictionary *error in errorList)
        {
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: error[@"description"]};
            
            MPKError *err = [[MPKError alloc] initWithDomain:@"MPKPaymentError" code:[error[@"code"] intValue] userInfo:userInfo];
            err.httpStatusCode = response.httpStatusCode;
            err.apiErrorCode = error[@"code"];
            err.errorDescription = error[@"description"];
            
            [errors addObject:err];
        }
        
        failureBlock(errors);
    }
    else
    {
        NSString *errorDescription = errorDict[@"ERROR"];

        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: errorDescription};
        
        MPKError *err = [[MPKError alloc] initWithDomain:@"MPKPaymentError" code:response.httpStatusCode userInfo:userInfo];
        err.httpStatusCode = response.httpStatusCode;
        err.apiErrorCode = nil;
        err.errorDescription = errorDescription;
        
        failureBlock(@[err]);
    }
}

#pragma mark Parse JSON request
- (NSString *) generatePaymentJSON:(MPKPayment *)payment
{
    NSMutableString *jsonPayment = [NSMutableString new];
    [jsonPayment appendFormat:@"{"];
    [jsonPayment appendFormat:@"        \"installmentCount\": %li,", (long)payment.installmentCount];
    [jsonPayment appendFormat:@"        \"fundingInstrument\": {"];
    [jsonPayment appendFormat:@"            \"method\": \"%@\",", [payment getMPKPaymentMethod]];
    [jsonPayment appendFormat:@"            \"creditCard\": {"];
    [jsonPayment appendFormat:@"                \"expirationMonth\": %lu,", (unsigned long)payment.creditCard.expirationMonth];
    [jsonPayment appendFormat:@"                \"expirationYear\": %lu,", (unsigned long)payment.creditCard.expirationYear];
    [jsonPayment appendFormat:@"                \"number\": \"%@\",", payment.creditCard.number];
    [jsonPayment appendFormat:@"                \"cvc\": \"%@\",", payment.creditCard.cvv];
    [jsonPayment appendFormat:@"                \"holder\": {"];
    [jsonPayment appendFormat:@"                    \"fullname\": \"%@\",", payment.creditCard.cardholder.fullname];
    [jsonPayment appendFormat:@"                    \"birthdate\": \"%@\",", payment.creditCard.cardholder.birthdate];
    [jsonPayment appendFormat:@"                    \"taxDocument\": {"];
    [jsonPayment appendFormat:@"                        \"type\": \"%@\",", [payment.creditCard.cardholder getDocumentType]];
    [jsonPayment appendFormat:@"                        \"number\": \"%@\"", payment.creditCard.cardholder.documentNumber];
    [jsonPayment appendFormat:@"                    },"];
    [jsonPayment appendFormat:@"                    \"phone\": {"];
    [jsonPayment appendFormat:@"                        \"countryCode\": \"%@\",", payment.creditCard.cardholder.phoneCountryCode];
    [jsonPayment appendFormat:@"                        \"areaCode\": \"%@\",", payment.creditCard.cardholder.phoneAreaCode];
    [jsonPayment appendFormat:@"                        \"number\": \"%@\"", payment.creditCard.cardholder.phoneNumber];
    [jsonPayment appendFormat:@"                    }"];
    [jsonPayment appendFormat:@"                }"];
    [jsonPayment appendFormat:@"            }"];
    [jsonPayment appendFormat:@"        }"];
    [jsonPayment appendFormat:@"    }"];
    
    return jsonPayment;
}

@end
