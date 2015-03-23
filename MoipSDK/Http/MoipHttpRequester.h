//
//  MoipHttpRequester.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#ifndef MoipHttpRequester_h
#define MoipHttpRequester_h

#import <Foundation/Foundation.h>

@class MoipHttpResponse;

@interface MoipHttpRequester : NSObject <NSURLConnectionDelegate>
{
    id delegate;
}

+ (MoipHttpRequester *) requesterWithBasicAuthorization:(NSString *)authorization;
- (void) setDefaultHeaders;
- (void) addHeaders:(NSDictionary *)additionalHeaders;
- (MoipHttpResponse *) get:(NSString *)url params:(NSDictionary * )params;
- (MoipHttpResponse *) post:(NSString *)url payload:(id)payload params:(NSDictionary * )params delegate:(id)delegate;
- (void) post:(NSString *)url payload:(id)payload completation:(void (^)(MoipHttpResponse *response))completation;
- (MoipHttpResponse *) put:(NSString *)url payload:(id)payload params:(NSDictionary * )params;
- (MoipHttpResponse *) delete:(NSString *)url;
- (void)request:(NSMutableURLRequest *)request completation:(void (^)(MoipHttpResponse *))completation;

@end
#endif