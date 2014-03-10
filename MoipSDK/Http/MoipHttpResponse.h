//
//  MoipHttpResponse.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#ifndef MoipHttpResponse_h
#define MoipHttpResponse_h

#import <Foundation/Foundation.h>

@interface MoipHttpResponse : NSObject

/**
 Http status code
 */
@property int httpStatusCode;

/**
 Response content.
 */
@property NSData *content;

@end
#endif
