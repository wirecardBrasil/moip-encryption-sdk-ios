//
//  MPKCustomer.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 24/07/14.
//  Copyright (c) 2014 Moip Pagamentos S/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPKDocumentType.h"
#import "MPKAddress.h"
#import "MPKFundingInstrument.h"

@class MPKFundingInstrument;
@class MoipHttpResponse;

@interface MPKCustomer : NSObject

@property NSString *ownId;
@property NSString *moipCustomerId;
@property NSString *fullname;
@property NSString *email;
@property NSInteger phoneAreaCode;
@property NSInteger phoneNumber;
@property NSDate *birthDate;
@property MPKDocumentType documentType;
@property NSString *documentNumber;
@property NSArray *addresses;
@property MPKFundingInstrument *fundingInstrument;

- (NSString *) buildJson;
- (NSString *) getDocumentType;

@end
