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

@end

@implementation MoipSDK

#pragma mark -
#pragma mark --> Public Methods
#pragma Start SDK
+ (MoipSDK *) startWithAuthorization:(NSString *)auth
{
    MoipSDK *sdkInstance = [MoipSDK new];
    sdkInstance.auth = auth;
    return sdkInstance;
}

//- (SecKeyRef) publicKey
//{
//    return self.publicKeyRef;
//}

#pragma mark Submit Payment
- (void)submitPayment:(MPKPayment *)payment success:(void (^)(MPKPaymentTransaction *))success failure:(void (^)(MPKPaymentTransaction *, NSError *))failure
{
    NSString *paymentJSON = [self generatePaymentJSON:payment];

    NSString *endpoint = [NSString stringWithFormat:@"/orders/%@/payments", payment.moipOrderId];
    NSString *url = APIURL(endpoint);

    MoipHttpRequester *requester = [MoipHttpRequester requesterWithBasicAuthorization:self.auth];
    MoipHttpResponse *response = [requester post:url payload:paymentJSON params:nil delegate:nil];
    if (response.httpStatusCode == kHTTPStatusCodeCreated || response.httpStatusCode == kHTTPStatusCodeOK)
    {
        [self checkResponseSuccess:response successBlock:success];
    }
    else
    {
        [self checkResponseFailure:response failureBlock:failure];
    }
}

- (NSString *) getMoipOrderId
{
    NSString *orderJSON = [self generateOrderJSON];
    NSString *url = APIURL(@"/orders");
    
    MoipHttpRequester *requester = [MoipHttpRequester requesterWithBasicAuthorization:self.auth];
    MoipHttpResponse *response = [requester post:url payload:orderJSON params:nil delegate:nil];
    if (response.httpStatusCode == kHTTPStatusCodeCreated)
    {
        id order = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
        return order[@"id"];
    }
    else
    {
        id error = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", error);
    }
    return nil;
}

#pragma mark Check Payment Status
- (void) checkMPKPaymentStatus:(MPKPaymentTransaction *)transaction
{

}

#pragma mark -
#pragma mark --> Private Methods

#pragma mark Check response after submit payment
- (void) checkResponseSuccess:(MoipHttpResponse *)response successBlock:(void (^)(MPKPaymentTransaction *))successBlock
{
    MPKPaymentTransaction *transac = [[MPKPaymentTransaction new] transactionWithJSON:response.content];
    successBlock(transac);
}

- (void) checkResponseFailure:(MoipHttpResponse *)response failureBlock:(void (^)(MPKPaymentTransaction *, NSError *))failureBlock
{
    id json = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
    if (response.httpStatusCode != 0)
    {
        MPKPaymentTransaction *transac = [MPKPaymentTransaction new];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: json[@"ERROR"], NSLocalizedFailureReasonErrorKey: json[@"ERROR"]};
        NSError *error = [NSError errorWithDomain:@"MoipSDK" code:response.httpStatusCode userInfo:userInfo];
        failureBlock(transac, error);
    }
    else
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: json[@"ERROR"], NSLocalizedFailureReasonErrorKey: json[@"ERROR"]};
        NSError *error = [NSError errorWithDomain:@"MoipSDK" code:response.urlErrorCode userInfo:userInfo];
        failureBlock(nil, error);
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

- (NSString *)generateOrderJSON
{
    NSMutableString *jsonOrder = [NSMutableString new];
    [jsonOrder appendFormat:@"{"];
    [jsonOrder appendFormat:@"  \"ownId\": \"id_proprio\","];
    [jsonOrder appendFormat:@"  \"amount\": {"];
    [jsonOrder appendFormat:@"    \"MPKCurrency\": \"BRL\""];
    [jsonOrder appendFormat:@"  },"];
    [jsonOrder appendFormat:@"  \"items\": ["];
    [jsonOrder appendFormat:@"    {"];
    [jsonOrder appendFormat:@"      \"product\": \"Bicicleta Specialized Tarmac 26 Shimano Alivio\","];
    [jsonOrder appendFormat:@"      \"quantity\": 1,"];
    [jsonOrder appendFormat:@"      \"detail\": \"uma linda bicicleta\","];
    [jsonOrder appendFormat:@"      \"price\": 10000"];
    [jsonOrder appendFormat:@"    }"];
    [jsonOrder appendFormat:@"  ],"];
    [jsonOrder appendFormat:@"  \"customer\": {"];
    [jsonOrder appendFormat:@"    \"ownId\": \"meu_id_de_cliente\","];
    [jsonOrder appendFormat:@"    \"fullname\": \"Jose Silva\","];
    [jsonOrder appendFormat:@"    \"email\": \"josedasilva@email.com\","];
    [jsonOrder appendFormat:@"    \"birthDate\": \"1988-12-30\","];
    [jsonOrder appendFormat:@"    \"taxDocument\": {"];
    [jsonOrder appendFormat:@"      \"type\": \"CPF\","];
    [jsonOrder appendFormat:@"      \"number\": \"22222222222\""];
    [jsonOrder appendFormat:@"    },"];
    [jsonOrder appendFormat:@"    \"phone\": {"];
    [jsonOrder appendFormat:@"      \"countryCode\": \"55\","];
    [jsonOrder appendFormat:@"      \"areaCode\": \"11\","];
    [jsonOrder appendFormat:@"      \"number\": \"66778899\""];
    [jsonOrder appendFormat:@"    },"];
    [jsonOrder appendFormat:@"    \"addresses\": ["];
    [jsonOrder appendFormat:@"      {"];
    [jsonOrder appendFormat:@"        \"type\": \"BILLING\","];
    [jsonOrder appendFormat:@"        \"street\": \"Avenida Faria Lima\","];
    [jsonOrder appendFormat:@"        \"streetNumber\": 2927,"];
    [jsonOrder appendFormat:@"        \"complement\": 8,"];
    [jsonOrder appendFormat:@"        \"district\": \"Itaim\","];
    [jsonOrder appendFormat:@"        \"city\": \"Sao Paulo\","];
    [jsonOrder appendFormat:@"        \"state\": \"SP\","];
    [jsonOrder appendFormat:@"        \"country\": \"BRA\","];
    [jsonOrder appendFormat:@"        \"zipCode\": \"01234000\""];
    [jsonOrder appendFormat:@"      }"];
    [jsonOrder appendFormat:@"    ]"];
    [jsonOrder appendFormat:@"  }"];
    [jsonOrder appendFormat:@"}"];
    
    return jsonOrder;
}

@end
