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
@property NSInteger documentNumber;
@property NSArray *addresses;
@property MPKFundingInstrument *fundingInstrument;

- (NSString *) builJson;
- (NSString *) getDocumentType;

@end



/*
 
 {
 "ownId":"meu_id_de_cliente",
 "fullname":"Jose Silva",
 "email":"josedasilva@email.com",
 "phone":{
 "areaCode":"11",
 "number":"66778899"
 },
 "birthDate":"1988-12-30",
 "taxDocument":{
 "type":"CPF",
 "number":"22222222222"
 },
 "addresses":[
 {
 "type":"BILLING",
 "street":"Avenida Faria Lima",
 "streetNumber":"2927",
 "complement":"8",
 "district":"Itaim",
 "city":"Sao Paulo",
 "state":"SP",
 "country":"BRA",
 "zipCode":"01234000"
 }
 ],
 "fundingInstrument":{
 "method":"CREDIT_CARD",
 "creditCard":{
 "expirationMonth":12,
 "expirationYear":15,
 "number":"4073020000000002",
 "holder":{
 "fullname":"Jose Silva",
 "birthdate":"1988-12-30",
 "taxDocument":{
 "type":"CPF",
 "number":"22222222222"
 },
 "phone":{
 "areaCode":"11",
 "number":"66778899"
 }
 }
 }
 }
 }
 
 */