//
//  MPKOrder.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 25/07/14.
//  Copyright (c) 2014 Moip Pagamentos S/A. All rights reserved.
//

#import "MPKOrder.h"

@implementation MPKOrder

- (NSString *) buildJson
{
    NSMutableString *orderJson = [NSMutableString new];
    [orderJson appendFormat:@"{"];
    [orderJson appendFormat:@"    \"ownId\": \"180879\","];
    [orderJson appendFormat:@"    \"amount\": %@,", [self.amount buildJson]];
    [orderJson appendFormat:@"    \"items\": ["];

    for (int i = 0; i < self.items.count; i++)
    {
        MPKItem *item = self.items[i];
        [orderJson appendFormat:@"    {"];
        [orderJson appendFormat:@"      \"product\": \"%@\",", item.product];
        [orderJson appendFormat:@"      \"quantity\": \"%ld\",", (long)item.quantity];
        [orderJson appendFormat:@"      \"detail\": \"%@\",", item.detail];
        [orderJson appendFormat:@"      \"price\": \"%ld\"", (long)item.price];
        
        if (self.items.count > 1 && i < self.items.count-1)
        {
            [orderJson appendFormat:@"    },"];
        }
        else
        {
            [orderJson appendFormat:@"    }"];
        }
    }
    
    [orderJson appendFormat:@"      ],"];
    [orderJson appendFormat:@"    \"customer\": %@", [self.customer buildJson]];
    [orderJson appendFormat:@"}"];
    
    return orderJson;
    
}

@end
