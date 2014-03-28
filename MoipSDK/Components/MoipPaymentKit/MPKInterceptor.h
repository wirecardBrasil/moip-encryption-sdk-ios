//
//  MPKInterceptor.h
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 12/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPKInterceptor : NSObject

@property (strong, nonatomic) id receiver;
@property (strong, nonatomic) id middleMan;

@end
