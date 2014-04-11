//
//  MPKError.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPKError : NSError

@property NSUInteger httpStatusCode;
@property NSString *apiErrorCode;
@property NSString *errorDescription;

@end
