//
//  CardHolder.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKCardHolder.h"

@implementation MPKCardHolder

- (NSString *) getDocumentType
{
    switch (self.documentType)
    {
        case MPKDocumentTypeCNPJ:
            return @"CNPJ";
            break;
        case MPKDocumentTypeCPF:
            return @"CPF";
            break;
        case MPKDocumentTypeRG:
            return @"RG";
            break;
        default:
            return @"UNKNOW";
            break;
    }
}

@end
