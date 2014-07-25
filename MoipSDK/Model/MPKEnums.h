//
//  Enums.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 10/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

typedef NS_ENUM(NSUInteger, MPKPaymentStatus)
{
    MPKPaymentStatusInitiated,
    MPKPaymentStatusAuthorized,
    MPKPaymentStatusConcluded,
    MPKPaymentStatusCancelled,
    MPKPaymentStatusRefunded,
    MPKPaymentStatusReversed,
    MPKPaymentStatusPrinted,
    MPKPaymentStatusInAnalysis
};

typedef NS_ENUM(NSUInteger, MPKCurrency)
{
    BRL
};

typedef NS_ENUM (NSUInteger, MPKBrand)
{
    MPKBrandUnknown,
    MPKBrandVisa,
    MPKBrandMasterCard,
    MPKBrandAmex,
    MPKBrandDiscover,
    MPKBrandHipercard,
    MPKBrandDinersClub
};

typedef NS_ENUM (NSUInteger, MPKFeeType)
{
    MPKFeeTypePrePayment,
    MPKFeeTypeTransaction
};

typedef NS_ENUM (NSUInteger, MPKEventType)
{
    MPKEventTypePaymentCreated,
    MPKEventTypePaymentPrinted,
    MPKEventTypePaymentInAnalysis,
    MPKEventTypePaymentAuthorized,
    MPKEventTypePaymentCancelled,
    MPKEventTypePaymentReverted,
    MPKEventTypePaymentRefunded,
    MPKEventTypePaymentSettled,
    MPKEventTypeOrderWaiting,
    MPKEventTypeOrderPaid,
    MPKEventTypeOrderNotPaid,
    MPKEventTypeOrderReverted,
    MPKEventTypeUnknown
};


