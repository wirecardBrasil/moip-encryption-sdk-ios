//
//  MPKCheckoutNavigationController.h
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 ThinkMob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPKConfiguration;

@interface MPKCheckoutNavigationController : UINavigationController

@property NSString *publicKey;
@property NSString *authorization;

- (instancetype) initWithOrderId:(NSString *)moipOrderId configuration:(MPKConfiguration *)configuration;

@end
