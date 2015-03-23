//
//  MPKMethodType.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 24/07/14.
//  Copyright (c) 2014 Moip Pagamentos S/A. All rights reserved.
//

#ifndef MoipSDK_MPKMethodType_h
#define MoipSDK_MPKMethodType_h

typedef NS_ENUM (NSUInteger, MPKMethodType) {
    MPKMethodTypeCreditCard,
    MPKMethodTypeBoleto,
    MPKMethodTypeOnlineDebit,
    MPKMethodTypeWallet
};

#endif
