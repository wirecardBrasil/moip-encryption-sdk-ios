//
//  ValidatorHelper.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 07/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *) getMethodPayment:(PaymentMethod)method
{
    switch (method)
    {
        case PaymentMethodCreditCard:
            return @"CREDIT_CARD";
            break;
            
        default:
            return @"CREDIT_CARD";
            break;
    }
}

+ (NSString *) getTypeDocument:(CardHolderDocumentType)document
{
    switch (document)
    {
        case CardHolderDocumentTypeCNPJ:
            return @"CNPJ";
            break;
        case CardHolderDocumentTypeCPF:
            return @"CPF";
            break;
        case CardHolderDocumentTypeRG:
            return @"RG";
            break;
        default:
            return @"UNKNOW";
            break;
    }
}

@end
