//
//  Amount.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKAmount.h"

@implementation MPKAmount

- (NSString *)buildJson
{
    NSMutableString *amountJson = [NSMutableString new];
    [amountJson appendFormat:@"{"];
    [amountJson appendFormat:@" \"currency\": \"BRL\","];
    [amountJson appendFormat:@" \"subtotals\": {"];
    [amountJson appendFormat:@"     \"shipping\": %li,", (long)self.shipping];
    [amountJson appendFormat:@"     \"addition\": %li,", (long)self.addition];
    [amountJson appendFormat:@"     \"discount\": %li", (long)self.discount];
    [amountJson appendFormat:@" }"];
    [amountJson appendFormat:@"}"];
    
    return amountJson;
}

@end
