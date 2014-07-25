//
//  MPKAddress.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 24/07/14.
//  Copyright (c) 2014 Moip Pagamentos S/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKAddressType.h"

@interface MPKAddress : NSObject

@property MPKAddressType type;
@property NSString *street;
@property NSString *streetNumber;
@property NSString *complement;
@property NSString *district;
@property NSString *city;
@property NSString *state;
@property NSString *country;
@property NSString *zipCode;

- (NSString *) getAddressType;

@end
