//
//  CardHolder.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, CardHolderDocumentType)
{
    CNPJ,
    CPF,
    RG
};

@interface CardHolder : NSObject

@property NSString *fullname;
@property NSString *birthdate;
@property CardHolderDocumentType *documentType;
@property NSString *documentNumber;
@property NSUInteger phoneCountryCode;
@property NSUInteger phoneAreaCode;
@property NSUInteger phoneNumber;

@end
