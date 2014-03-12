//
//  Event.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"

@interface Event : NSObject

@property EventType type;
@property NSDate *createdAt;
@property NSString *description;

@end
