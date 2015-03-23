//
//  MoipSDK.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MoipSDK.h"
#import "MoipHttpRequester.h"
#import "MoipHttpResponse.h"
#import "HTTPStatusCodes.h"
#import "MPKUtilities.h"

@interface MoipSDK ()

@property NSString *auth;
@property MPKEnvironment environment;

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
        [MPKUtilities importPublicKey:publicKeyPlainText tag:kPublicKeyName];
    }
}

#pragma mark -
#pragma mark Submit Payment
/**
 *  Cria um pedido no moip
 *
 *  @param order Dados do pedido
 *  @param success Block de sucesso
 *  @param failure Block de erro
 */
- (void) createOrder:(NSMutableURLRequest *)request
               order:(MPKOrder *)order
             success:(void (^)(MPKOrder *order, NSString *moipOrderId))success
             failure:(void (^)(NSArray *errorList))failure
{
    NSString *orderJson = [order buildJson];
    [request setHTTPBody:[orderJson dataUsingEncoding:NSUTF8StringEncoding]];
    
    MoipHttpRequester *requester = [MoipHttpRequester requesterWithBasicAuthorization:self.auth];
    [requester request:request completation:^(MoipHttpResponse *response) {
        if (response.httpStatusCode == kHTTPStatusCodeCreated || response.httpStatusCode == kHTTPStatusCodeOK)
        {
            NSDictionary *orderCreated = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
            NSString *moipOrder = orderCreated[@"id"];
            
            order.moipOrderId = moipOrder;
            success(order, moipOrder);
        }
        else
        {
            [self checkResponseFailure:response failureBlock:failure];
        }
    }];
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
    NSString *paymentJSON = [payment buildJson];
    
    NSString *endpoint = [NSString stringWithFormat:@"/orders/%@/payments", payment.moipOrderId];
    NSString *url = [MPKUtilities urlWithEnv:self.environment endpoint:endpoint];
    
    MoipHttpRequester *requester = [MoipHttpRequester requesterWithBasicAuthorization:self.auth];
    [requester post:url payload:paymentJSON completation:^(MoipHttpResponse *response) {
        if (response.httpStatusCode == kHTTPStatusCodeCreated || response.httpStatusCode == kHTTPStatusCodeOK)
        {
            MPKPaymentTransaction *transac = [[MPKPaymentTransaction new] transactionWithJSON:response.content];
            success(transac);
        }
        else
        {
            [self checkResponseFailure:response failureBlock:failure];
        }
    }];
}

- (void) createCustomer:(MPKCustomer *)customer
                success:(void (^)(MPKCustomer *customer, NSString *moipCustomerId, NSString *moipCreditCardId))success
                failure:(void (^)(NSArray *errorList))failure;
{
    NSString *jsonCustomer = [customer buildJson];
    
    NSString *endpoint = [NSString stringWithFormat:@"/customers"];
    NSString *url = [MPKUtilities urlWithEnv:self.environment endpoint:endpoint];
    
    MoipHttpRequester *requester = [MoipHttpRequester requesterWithBasicAuthorization:self.auth];
    [requester post:url payload:jsonCustomer completation:^(MoipHttpResponse *response) {
        if (response.httpStatusCode == kHTTPStatusCodeCreated || response.httpStatusCode == kHTTPStatusCodeOK)
        {
            NSDictionary *customerCreated = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
            if (customerCreated != nil)
            {
                NSString *moipCustomerId = customerCreated[@"id"];
                NSString *moipCreditCardId = customerCreated[@"fundingInstrument"][@"creditCard"][@"id"];
                
                customer.moipCustomerId = moipCustomerId;
                customer.fundingInstrument.creditCard.moipCreditCardId = moipCreditCardId;
                success(customer, moipCustomerId, moipCreditCardId);
            }
        }
        else
        {
            [self checkResponseFailure:response failureBlock:failure];
        }
    }];
    
}

#pragma mark -
#pragma mark Check response when failure
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
        
        MPKError *err = [[MPKError alloc] initWithDomain:@"MoipSDK" code:response.httpStatusCode userInfo:userInfo];
        err.httpStatusCode = response.httpStatusCode;
        err.apiErrorCode = nil;
        err.errorDescription = errorDescription;
        
        failureBlock(@[err]);
    }
}

@end
