//
//  CardHolder.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "CardHolder.h"

@implementation CardHolder

- (NSString *) getDocumentType
{
    switch (self.documentType)
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
