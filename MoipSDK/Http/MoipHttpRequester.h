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
//#import "ApiStatusCodes.h"

@class MoipHttpResponse;

@interface MoipHttpRequester : NSObject <NSURLConnectionDelegate>
{
    /**
     * Upload delegate
     */
    id delegate;
}

/*!
 * MoipHttpRequester constructor.
 * \param token - Used to make the request.
 * \returns id.
 */
- (id) MoipHttpRequester:(NSString *)token;

/*!
 * MoipHttpRequester.
 * \param token - Used to make the request.
 * \param customHeaders - Aditional headers.
 * \returns id.
 */
- (id) MoipHttpRequester:(NSString *)token header:(NSDictionary *)customHeaders;

/*!
 * Set the default headers. (Accept, User-Agent, X-API-Version, Content-Type);
 */
- (void) setDefaultHeaders;

/*!
 * Add additional headers
 */
- (void) addHeaders:(NSDictionary *)additionalHeaders;

/*!
 * Make a GET request with default Cache policy. (NSURLRequestReloadRevalidatingCacheData)
 * \param url - URL to request.
 * \param params - Additional params.
 * \returns MoipHttpResponse.
 */
- (MoipHttpResponse *) get:(NSString *)url params:(NSDictionary * )params;

/*!
 * Make a POST request.
 * \param url - URL to request.
 * \param payload - Payload.
 * \param params - Additional params.
 * \param delegate (Optional) -  Upload delegate, used by didFailWithError, didSendBodyData and connectionDidFinishLoading.
 * \returns MoipHttpResponse.
 */
- (MoipHttpResponse *) post:(NSString *)url payload:(id)payload params:(NSDictionary * )params delegate:(id)delegate;

/*!
 * Make a PUT request.
 * \param url - URL to request.
 * \param payload - Payload.
 * \param params - Additional params.
 * \returns MoipHttpResponse.
 */
- (MoipHttpResponse *) put:(NSString *)url payload:(id)payload params:(NSDictionary * )params;

/*!
 * Make a DELETE request.
 * \param url - URL to request.
 * \returns MoipHttpResponse.
 */
- (MoipHttpResponse *) delete:(NSString *)url;

@end
#endif