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
#import "Utilities.h"

@implementation MoipSDK

#pragma mark -
#pragma mark --> Public Methods
#pragma mark Submit Payment
- (void) submitPayment:(Payment *)payment
{
    NSString *paymentJSON = [self generatePaymentJSON:payment];

    NSString *endpoint = [NSString stringWithFormat:@"/orders/%@/payments", payment.moipOrderId];
    NSString *url = APIURL(endpoint);
    
    MoipHttpResponse *response = [[MoipHttpRequester new] post:url payload:paymentJSON params:nil delegate:nil];
    if (response.httpStatusCode == kHTTPStatusCodeOK)
    {
        [self checkResponseSuccess:response];
    }
    else
    {
        [self checkResponseFailure:response];
    }
}

#pragma mark Check Payment Status
- (void) checkPaymentStatus:(PaymentTransaction *)transaction
{
    PaymentTransaction *transac = [PaymentTransaction new];
    transac.status = PaymentStatusCancelled;
    if ([self.delegate respondsToSelector:@selector(paymentFailed:error:)])
    {
        NSError *er = [NSError errorWithDomain:@"MoipSDK" code:999 userInfo:nil];
        [self.delegate performSelector:@selector(paymentFailed:error:) withObject:transac withObject:er];
    }
}

#pragma mark -
#pragma mark --> Private Methods

#pragma mark Check response after submit payment
- (void) checkResponseSuccess:(MoipHttpResponse *)response
{
    NSLog(@"%@", [[NSString alloc] initWithData:response.content encoding:NSUTF8StringEncoding]);    
}

- (void) checkResponseFailure:(MoipHttpResponse *)response
{
    if (response.httpStatusCode == 0)
    {
        id json = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
        if ([self.delegate respondsToSelector:@selector(paymentFailed:error:)])
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: json[@"ERROR"],
                                       NSLocalizedFailureReasonErrorKey: json[@"ERROR"]};
            NSError *error = [NSError errorWithDomain:@"MoipSDK" code:401 userInfo:userInfo];
            [self.delegate performSelector:@selector(paymentFailed:error:) withObject:nil withObject:error];
        }
    }
    else
    {
        PaymentTransaction *transac = [PaymentTransaction new];
        transac.status = PaymentStatusCancelled;
        
        if ([self.delegate respondsToSelector:@selector(paymentFailed:error:)])
        {
            NSError *er = [NSError errorWithDomain:@"MoipSDK" code:999 userInfo:nil];
            [self.delegate performSelector:@selector(paymentFailed:error:) withObject:transac withObject:er];
        }
    }


}

#pragma mark Parse JSON request
- (NSString *) generatePaymentJSON:(Payment *)payment
{
    NSMutableString *jsonPayment = [NSMutableString new];
    [jsonPayment appendFormat:@"{"];
    [jsonPayment appendFormat:@"        \"installmentCount\": %i,", payment.installmentCount];
    [jsonPayment appendFormat:@"        \"fundingInstrument\": {"];
    [jsonPayment appendFormat:@"            \"method\": \"%@\",", [payment getPaymentMethod]];
    [jsonPayment appendFormat:@"            \"creditCard\": {"];
    [jsonPayment appendFormat:@"                \"expirationMonth\": %i,", payment.creditCard.expirationMonth];
    [jsonPayment appendFormat:@"                \"expirationYear\": %i,", payment.creditCard.expirationYear];
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
