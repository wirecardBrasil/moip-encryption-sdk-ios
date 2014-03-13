//
//  Enums.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

typedef NS_ENUM(int, PaymentMethod)
{
    PaymentMethodCreditCard
};

typedef NS_ENUM(NSUInteger, PaymentStatus)
{
    PaymentStatusInitiated,
    PaymentStatusAuthorized,
    PaymentStatusConcluded,
    PaymentStatusCancelled,
    PaymentStatusRefunded,
    PaymentStatusReversed,
    PaymentStatusPrinted,
    PaymentStatusInAnalysis
};

typedef NS_ENUM(NSUInteger, Currency)
{
    BRL
};

typedef NS_ENUM(int, CardHolderDocumentType)
{
    CardHolderDocumentTypeCNPJ,
    CardHolderDocumentTypeCPF,
    CardHolderDocumentTypeRG
};

typedef NS_ENUM (int, Brand)
{
    BrandUnknown,
    BrandVisa,
    BrandMasterCard,
    BrandAmex,
    BrandDiscover,
    BrandHipercard,
    BrandDinersClub
};

typedef NS_ENUM (int, FeeType)
{
    FeeTypePrePayment,
    FeeTypeTransaction
};

typedef NS_ENUM (int, EventType)
{
    EventTypePaymentCreated,
    EventTypePaymentPrinted,
    EventTypePaymentInAnalysis,
    EventTypePaymentAuthorized,
    EventTypePaymentCancelled,
    EventTypePaymentReverted,
    EventTypePaymentRefunded,
    EventTypePaymentSettled,
    EventTypeOrderWaiting,
    EventTypeOrderPaid,
    EventTypeOrderNotPaid,
    EventTypeOrderReverted,
    EventTypeUnknown
};


