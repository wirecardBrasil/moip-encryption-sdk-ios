//
//  Payment.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKPayment.h"

@implementation MPKPayment

- (NSString *) buildJson
{
    NSMutableString *jsonPayment = [NSMutableString new];
    [jsonPayment appendFormat:@"{"];
    [jsonPayment appendFormat:@"\"installmentCount\": %li,", (long)self.installmentCount];
    [jsonPayment appendFormat:@"\"fundingInstrument\": %@", [self.fundingInstrument buildJson]];
    [jsonPayment appendFormat:@"}"];
    
    return jsonPayment;
}

@end
