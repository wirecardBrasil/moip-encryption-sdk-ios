//
//  MoipSDK.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 05/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MoipSDK.h"
#import "Utilities.h"

@implementation MoipSDK

- (void) submitPayment:(Payment *)payment
{
    NSString *paymentJSON = [self generatePaymentJSON:payment];

    NSString *endpoint = [NSString stringWithFormat:@"/orders/%@/payments", payment.moipOrderId];
    NSString *url = APIURL(endpoint);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[paymentJSON dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    NSLog(@"statusCode: %i", response.statusCode);
    NSLog(@"%@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
    
    PaymentTransaction *transac = [PaymentTransaction new];
    transac.status = PaymentStatusCancelled;
    if ([self.delegate respondsToSelector:@selector(paymentCreated:)])
    {
        [self.delegate performSelector:@selector(paymentCreated:) withObject:transac];
    }
}

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

- (NSString *) generatePaymentJSON:(Payment *)payment
{
    NSMutableString *jsonPayment = [NSMutableString new];
    [jsonPayment appendFormat:@"{"];
    [jsonPayment appendFormat:@"        \"installmentCount\": %i,", payment.installmentCount];
    [jsonPayment appendFormat:@"        \"fundingInstrument\": {"];
    [jsonPayment appendFormat:@"            \"method\": \"%@\",", [Utilities getMethodPayment:payment.method]];
    [jsonPayment appendFormat:@"            \"creditCard\": {"];
    [jsonPayment appendFormat:@"                \"expirationMonth\": %i,", payment.creditCard.expirationMonth];
    [jsonPayment appendFormat:@"                \"expirationYear\": %i,", payment.creditCard.expirationYear];
    [jsonPayment appendFormat:@"                \"number\": \"%@\",", payment.creditCard.number];
    [jsonPayment appendFormat:@"                \"cvc\": \"%@\",", payment.creditCard.cvv];
    [jsonPayment appendFormat:@"                \"holder\": {"];
    [jsonPayment appendFormat:@"                    \"fullname\": \"%@\",", payment.creditCard.cardholder.fullname];
    [jsonPayment appendFormat:@"                    \"birthdate\": \"%@\",", payment.creditCard.cardholder.birthdate];
    [jsonPayment appendFormat:@"                    \"taxDocument\": {"];
    [jsonPayment appendFormat:@"                        \"type\": \"%@\",", [Utilities getTypeDocument:payment.creditCard.cardholder.documentType]];
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
