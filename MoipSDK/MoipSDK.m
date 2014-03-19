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
#import "MPKError.h"

@interface MoipSDK ()

@property NSString *auth;

@end

@implementation MoipSDK

#pragma mark -
#pragma mark --> Public Methods
#pragma Start SDK
- (id) initWithAuthorization:(NSString *)auth publicKey:(NSString *)publicKeyPlainText
{
    if (self = [super init])
    {
        self.auth = auth;
        if (publicKeyPlainText != nil && ![publicKeyPlainText isEqualToString:@""])
        {
            [self importPublicKey:publicKeyPlainText];
        }
    }
    return self;
}

- (void) importPublicKey:(NSString *)publicKeyText
{
    [MPKUtilities importPublicKey:publicKeyText];
}

#pragma mark Submit Payment
- (void)submitPayment:(MPKPayment *)payment success:(void (^)(MPKPaymentTransaction *))success failure:(void (^)(NSArray *))failure
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

- (void) checkResponseFailure:(MoipHttpResponse *)response failureBlock:(void (^)(NSArray *))failureBlock
{
    NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
    NSArray *errorList = errorDict[@"errors"];
    if (errorList.count > 0)
    {
        NSMutableArray *errors = [NSMutableArray new];
        for (NSDictionary *error in errorList)
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: error[@"path"],
                                       NSLocalizedFailureReasonErrorKey: error[@"description"]};
            
            MPKError *err = [[MPKError alloc] initWithDomain:@"MPKPaymentError" code:[error[@"code"] intValue] userInfo:userInfo];
            err.httpStatusCode = response.httpStatusCode;
            err.apiErrorCode = error[@"code"];
            err.errorPath = error[@"path"];
            err.errorDescription = error[@"description"];
            
            [errors addObject:err];
        }
        
        failureBlock(errors);
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
