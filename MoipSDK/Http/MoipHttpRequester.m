//
//  MoipHttpRequester.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MoipHttpRequester.h"
#import "MoipHttpResponse.h"
#import "HTTPStatusCodes.h"
#import "MPKUtilities.h"

@interface MoipHttpRequester ()

@property NSString *basicAuth;

@end

@implementation MoipHttpRequester

NSMutableDictionary *headers;

- (id)init
{
    headers = [NSMutableDictionary new];
    self.basicAuth = nil;
    [self setDefaultHeaders];
    return self;
}

- (id)initWithAuth:(NSString *)auth;
{
    headers = [NSMutableDictionary new];
    self.basicAuth = auth;
    [self setDefaultHeaders];
    return self;
}

+ (MoipHttpRequester *) requesterWithBasicAuthorization:(NSString *)authorization
{
    MoipHttpRequester *requester = [[MoipHttpRequester alloc] initWithAuth:authorization];
    return requester;
}

- (void) setDefaultHeaders
{
//    [headers setValue:@"Moip-SDK-iOS/1.0" forKey:@"User-Agent"];
    [headers setValue:@"application/json" forKey:@"Content-Type"];
    if (self.basicAuth != nil)
    {
        [headers setValue:self.basicAuth forKey:@"Authorization"];
    }
}

- (void) addHeaders:(NSDictionary *)additionalHeaders
{
    for(NSString *h in [additionalHeaders allKeys])
    {
        [headers setValue:additionalHeaders[h] forKey:h];
    }
}

- (MoipHttpResponse *) get:(NSString *)url params:(NSDictionary *)params
{
    url = [MPKUtilities addQueryStringToUrlString:url withDictionary:params];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    
    for (NSString *key in [headers allKeys])
    {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [NSError new];
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    MoipHttpResponse *newResponse = [MoipHttpResponse new];
    newResponse.httpStatusCode = response.statusCode;
    newResponse.content = result;
    
    return newResponse;
}

- (void)post:(NSString *)url payload:(id)payload completation:(void (^)(MoipHttpResponse *))completation
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    for (NSString *key in [headers allKeys])
    {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    [request setTimeoutInterval:60];
    
    if (payload != nil && [payload isKindOfClass:[NSString class]])
    {
        [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if ([payload isKindOfClass:[NSData class]])
    {
        [request setHTTPBody:payload];
    }
    else if([payload isKindOfClass:[NSInputStream class]])
    {
        [request setHTTPBodyStream:payload];
        [request setTimeoutInterval:0];
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        MoipHttpResponse *newResponse = [MoipHttpResponse new];
        newResponse.content = data;
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]])
        {
            newResponse.httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
        }
        else
        {
            newResponse.urlErrorCode = connectionError.code;
        }
        
        completation(newResponse);
    }];
}

- (MoipHttpResponse *) post:(NSString *)url payload:(id)payload params:(NSDictionary * )params delegate:(id)postDelegate
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    for (NSString *key in [headers allKeys])
    {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    [request setTimeoutInterval:60];
    
    if (payload != nil && [payload isKindOfClass:[NSString class]])
    {
        [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if ([payload isKindOfClass:[NSData class]])
    {
        [request setHTTPBody:payload];
    }
    else if([payload isKindOfClass:[NSInputStream class]])
    {
        [request setHTTPBodyStream:payload];
        [request setTimeoutInterval:0];
    }
    
    NSURLResponse *response = nil;
    NSError *error = [NSError new];
    
    if(postDelegate != nil)
    {
        delegate = postDelegate;
        [NSURLConnection connectionWithRequest:request delegate:self];
        return nil;
    }
    else
    {
        @try
        {
            
            NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            MoipHttpResponse *newResponse = [MoipHttpResponse new];
            newResponse.content = result;
            
            if ([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                newResponse.httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
            }
            else
            {
                newResponse.urlErrorCode = error.code;
            }

            return newResponse;
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            return nil;
        }
    }
}

- (MoipHttpResponse *) put:(NSString *)url payload:(id)payload params:(NSDictionary * )params
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    request.timeoutInterval = 60;
    
    for (NSString *key in [headers allKeys])
    {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    if (payload != nil && [payload isKindOfClass:[NSString class]])
    {
        [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if ([payload isKindOfClass:[NSData class]])
    {
        [request setHTTPBody:payload];
    }
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [NSError new];
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    MoipHttpResponse *newResponse = [MoipHttpResponse new];
    newResponse.httpStatusCode = response.statusCode;
    newResponse.content = result;
    
    if (error.code == NSURLErrorTimedOut)
    {
        newResponse.httpStatusCode = NSURLErrorTimedOut;
    }
    
    return newResponse;
}

- (MoipHttpResponse *) delete:(NSString *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"DELETE";
    
    for (NSString *key in [headers allKeys])
    {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    NSHTTPURLResponse *response = nil;
    NSError *error = [NSError new];
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    MoipHttpResponse *newResponse = [MoipHttpResponse new];
    newResponse.httpStatusCode = response.statusCode;
    newResponse.content = result;
    return newResponse;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#pragma mark Upload Support
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(didReceivedError:)])
    {
        [delegate performSelector:@selector(didReceivedError:) withObject:error];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSNumber *expected = [NSNumber numberWithDouble:totalBytesExpectedToWrite];
    NSNumber *written = [NSNumber numberWithDouble:totalBytesWritten];
    
    float bSended = ([written floatValue]/[expected floatValue]);
    NSNumber *bytesSended = [NSNumber numberWithFloat:bSended];
    
    if ([delegate respondsToSelector:@selector(uploadSendData:)])
    {
        [delegate performSelector:@selector(uploadSendData:) withObject:bytesSended];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([delegate respondsToSelector:@selector(uploadCompleted:)])
    {
        [delegate performSelector:@selector(uploadCompleted:) withObject:@(YES)];
    }
}
#pragma clang diagnostic pop

@end
