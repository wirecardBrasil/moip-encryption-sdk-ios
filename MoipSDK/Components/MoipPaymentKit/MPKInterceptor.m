//
//  MPKInterceptor.m
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 12/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKInterceptor.h"

@implementation MPKInterceptor

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.middleMan respondsToSelector:aSelector])
    {
        return self.middleMan;
    }
    
    if ([self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([[self.middleMan superclass] instancesRespondToSelector:aSelector]) return NO;
    
    if ([self.middleMan respondsToSelector:aSelector])
    {
        return YES;
    }
    
    if ([self.receiver respondsToSelector:aSelector])
    {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

@end
