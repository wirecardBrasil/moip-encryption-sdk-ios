//
//  MPKItem.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 25/07/14.
//  Copyright (c) 2014 Moip Pagamentos S/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPKItem : NSObject

@property NSString *product;
@property NSInteger quantity;
@property NSString *detail;
@property NSInteger price;

@end
