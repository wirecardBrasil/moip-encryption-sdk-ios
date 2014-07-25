//
//  MPKCustomer.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 24/07/14.
//  Copyright (c) 2014 Moip Pagamentos S/A. All rights reserved.
//

#import "MPKCustomer.h"

@implementation MPKCustomer

- (NSString *) builJson
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.birthDate];
    
    NSMutableString *json = [NSMutableString new];
    [json appendFormat:@"{"];
    [json appendFormat:@"  \"ownId\": \"%@\",", self.ownId];
    [json appendFormat:@"  \"fullname\": \"%@\",", self.fullname];
    [json appendFormat:@"  \"email\": \"%@\",", self.email];
    [json appendFormat:@"  \"phone\": {"];
    [json appendFormat:@"    \"areaCode\": \"%li\",", (long)self.phoneAreaCode];
    [json appendFormat:@"    \"number\": \"%li\"", (long)self.phoneNumber];
    [json appendFormat:@"  },"];
    [json appendFormat:@"  \"birthDate\": \"%ld-%ld-%ld\",", (long)components.year, (long)components.month, (long)components.day];
    [json appendFormat:@"  \"taxDocument\": {"];
    [json appendFormat:@"    \"type\": \"%@\",", [self getDocumentType]];
    [json appendFormat:@"    \"number\": \"%li\"", (long)self.documentNumber];
    [json appendFormat:@"  },"];
    [json appendFormat:@"  \"addresses\": ["];
    
    for (int i = 0; i < self.addresses.count; i++)
    {
        MPKAddress *address = self.addresses[i];
        [json appendFormat:@"    {"];
        [json appendFormat:@"      \"type\": \"%@\",", [address getAddressType]];
        [json appendFormat:@"      \"street\": \"%@\",", address.street];
        [json appendFormat:@"      \"streetNumber\": \"%@\",", address.streetNumber];
        [json appendFormat:@"      \"complement\": \"%@\",", address.complement];
        [json appendFormat:@"      \"district\": \"%@\",", address.district];
        [json appendFormat:@"      \"city\": \"%@\",", address.city];
        [json appendFormat:@"      \"state\": \"%@\",", address.state];
        [json appendFormat:@"      \"country\": \"%@\",", address.country];
        [json appendFormat:@"      \"zipCode\": \"%@\"", address.zipCode];
        
        if (self.addresses.count > 1 && i < self.addresses.count-1)
        {
            [json appendFormat:@"    },"];
        }
        else
        {
            [json appendFormat:@"    }"];
        }
    }
    
    [json appendFormat:@"  ],"];
    [json appendFormat:@"   \"fundingInstrument\": %@", [self.fundingInstrument buildJson]];
    [json appendFormat:@"  }"];
//    [json appendFormat:@"}"];
    return json;
}

- (NSString *) getDocumentType
{
    switch (self.documentType)
    {
        case MPKDocumentTypeCNPJ:
            return @"CNPJ";
            break;
        case MPKDocumentTypeCPF:
            return @"CPF";
            break;
        case MPKDocumentTypeRG:
            return @"RG";
            break;
        default:
            return @"UNKNOW";
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

@end
