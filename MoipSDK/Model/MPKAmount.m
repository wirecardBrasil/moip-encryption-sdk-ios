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
    [amountJson appendFormat:@"     \"shipping\": %li,", self.shipping];
    [amountJson appendFormat:@"     \"addition\": %li,", self.addition];
    [amountJson appendFormat:@"     \"discount\": %li", self.discount];
    [amountJson appendFormat:@" }"];
    [amountJson appendFormat:@"}"];
    
    return amountJson;
}

@end
