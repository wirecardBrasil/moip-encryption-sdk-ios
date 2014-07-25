//
//  FundingInstrument.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKFundingInstrument.h"

@implementation MPKFundingInstrument

- (NSString *) getMethodTypeString
{
    switch (self.method)
    {
        case MPKMethodTypeCreditCard:
            return @"CREDIT_CARD";
            break;
            
        case MPKMethodTypeBoleto:
            return @"BOLETO";
            break;
            
        case MPKMethodTypeOnlineDebit:
            return @"ONLINE_DEBIT";
            break;
            
        case MPKMethodTypeWallet:
            return @"WALLET";
            break;
            
        default:
            return @"CREDIT_CARD";
            break;
    }
}

- (MPKMethodType) getMethodTypeFromString:(NSString *)method
{
    if ([method isEqualToString:@"CREDIT_CARD"])
    {
        return MPKMethodTypeCreditCard;
    }
    else if ([method isEqualToString:@"BOLETO"])
    {
        return MPKMethodTypeBoleto;
    }
    else if ([method isEqualToString:@"ONLINE_DEBIT"])
    {
        return MPKMethodTypeOnlineDebit;
    }
    
    return MPKMethodTypeCreditCard;
}

- (NSString *) buildJson
{
    NSMutableString *jsonInstrument = [NSMutableString new];
    [jsonInstrument appendFormat:@"{"];
    [jsonInstrument appendFormat:@"\"method\": \"%@\",", [self getMethodTypeString]];
    [jsonInstrument appendFormat:@"\"creditCard\": {"];
    
    if (self.creditCard.moipCreditCardId != nil)
    {
        [jsonInstrument appendFormat:@"     \"id\": \"%@\",", self.creditCard.moipCreditCardId];
        [jsonInstrument appendFormat:@"     \"cvc\": \"%@\"", self.creditCard.cvv];
    }
    else
    {
        [jsonInstrument appendFormat:@"     \"expirationMonth\": %lu,", (unsigned long)self.creditCard.expirationMonth];
        [jsonInstrument appendFormat:@"     \"expirationYear\": %lu,", (unsigned long)self.creditCard.expirationYear];
        [jsonInstrument appendFormat:@"     \"number\": \"%@\",", self.creditCard.number];
        [jsonInstrument appendFormat:@"     \"cvc\": \"%@\",", self.creditCard.cvv];
        [jsonInstrument appendFormat:@"     \"holder\": {"];
        [jsonInstrument appendFormat:@"             \"fullname\": \"%@\",", self.creditCard.cardholder.fullname];
        [jsonInstrument appendFormat:@"             \"birthdate\": \"%@\",", self.creditCard.cardholder.birthdate];
        [jsonInstrument appendFormat:@"             \"taxDocument\": {"];
        [jsonInstrument appendFormat:@"             \"type\": \"%@\",", [self.creditCard.cardholder getDocumentType]];
        [jsonInstrument appendFormat:@"             \"number\": \"%@\"", self.creditCard.cardholder.documentNumber];
        [jsonInstrument appendFormat:@"         },"];
        [jsonInstrument appendFormat:@"         \"phone\": {"];
        [jsonInstrument appendFormat:@"             \"countryCode\": \"%@\",", self.creditCard.cardholder.phoneCountryCode];
        [jsonInstrument appendFormat:@"             \"areaCode\": \"%@\",", self.creditCard.cardholder.phoneAreaCode];
        [jsonInstrument appendFormat:@"             \"number\": \"%@\"", self.creditCard.cardholder.phoneNumber];
        [jsonInstrument appendFormat:@"         }"];
        [jsonInstrument appendFormat:@"     }"];
    }
    
    [jsonInstrument appendFormat:@"}"];
    [jsonInstrument appendFormat:@"}"];

    return jsonInstrument;
}

@end
