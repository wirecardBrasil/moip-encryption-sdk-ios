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
    
    
    NSMutableString *json = [NSMutableString new];
    [json appendFormat:@"{"];
    [json appendFormat:@"  \"ownId\": \"%@\",", self.ownId];
    [json appendFormat:@"  \"fullname\": \"%@\",", self.fullname];
    [json appendFormat:@"  \"email\": \"%@\",", self.email];
    [json appendFormat:@"  \"phone\": {"];
    [json appendFormat:@"    \"areaCode\": \"%li\",", (long)self.phoneAreaCode];
    [json appendFormat:@"    \"number\": \"%li\"", (long)self.phoneNumber];
    [json appendFormat:@"  },"];
    [json appendFormat:@"  \"birthDate\": \"1988-12-30\","];
    [json appendFormat:@"  \"taxDocument\": {"];
    [json appendFormat:@"    \"type\": \"CPF\","];
    [json appendFormat:@"    \"number\": \"22222222222\""];
    [json appendFormat:@"  },"];
    [json appendFormat:@"  \"addresses\": ["];
    [json appendFormat:@"    {"];
    [json appendFormat:@"      \"type\": \"BILLING\","];
    [json appendFormat:@"      \"street\": \"Avenida Faria Lima\","];
    [json appendFormat:@"      \"streetNumber\": \"2927\","];
    [json appendFormat:@"      \"complement\": \"8\","];
    [json appendFormat:@"      \"district\": \"Itaim\","];
    [json appendFormat:@"      \"city\": \"Sao Paulo\","];
    [json appendFormat:@"      \"state\": \"SP\","];
    [json appendFormat:@"      \"country\": \"BRA\","];
    [json appendFormat:@"      \"zipCode\": \"01234000\""];
    [json appendFormat:@"    }"];
    [json appendFormat:@"  ],"];
    [json appendFormat:@"  %@", [self.fundingInstrument buildJson]];
    [json appendFormat:@"  }"];
    [json appendFormat:@"}"];
    return json;
}

@end
