//
//  PaymentTransaction.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKPaymentTransaction.h"
#import "MPKPayment.h"

@implementation MPKPaymentTransaction

- (MPKPaymentTransaction *) transactionWithJSON:(NSData *)jsonData;
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    if (json != nil)
    {
        MPKAmount *amount = [MPKAmount new];
        amount.total = [json[@"amount"][@"total"] intValue];
        amount.fees = [json[@"amount"][@"fees"] intValue];
        amount.refunds = [json[@"amount"][@"refunds"] intValue];
        amount.liquid = [json[@"amount"][@"liquid"] intValue];
        amount.MPKCurrency = [self getMPKCurrencyFromString:json[@"amount"][@"MPKCurrency"]];
        
        MPKCreditCard *creditCard = [MPKCreditCard new];
        creditCard.creditCardId = json[@"fundingInstrument"][@"creditCard"][@"id"];
        creditCard.customerOwnId = json[@"fundingInstrument"][@"creditCard"][@"customerOwnId"];
        creditCard.brand = [creditCard getMPKBrandFromString:json[@"fundingInstrument"][@"creditCard"][@"brand"]];
        creditCard.first6 = json[@"fundingInstrument"][@"creditCard"][@"first6"];
        creditCard.last4 = json[@"fundingInstrument"][@"creditCard"][@"last4"];
        
        MPKPayment *payment = [MPKPayment new];
        payment.creditCard = creditCard;
        payment.installmentCount = [json[@"installmentCount"] intValue];

        MPKFundingInstrument *instrument = [MPKFundingInstrument new];
        instrument.institution = payment.creditCard.brand;
        instrument.MPKPaymentMethod = [payment getMPKPaymentMethodFromString:json[@"fundingInstrument"][@"method"]];
        
        NSMutableArray *feesList = [NSMutableArray new];
        for (NSDictionary *feeInfo in json[@"fees"])
        {
            MPKFee *fee = [MPKFee new];
            fee.type = [self getFeeFromString:feeInfo[@"type"]];
            fee.amount = [feeInfo[@"amount"] intValue];
            
            [feesList addObject:fee];
        }
        
        NSMutableArray *eventList = [NSMutableArray new];
        for (NSDictionary *evInfo in json[@"events"])
        {
            MPKEvent *ev = [MPKEvent new];
            ev.type = [self getEventFromString:evInfo[@"type"]];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss-S"];
            
            NSString *dateStr = [evInfo[@"createdAt"] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            NSDate *dt = [dateFormat dateFromString:dateStr];
            ev.createdAt = dt;
            ev.description = evInfo[@"description"];
            
            [feesList addObject:ev];
        }
        
        self.payment = payment;
        self.paymenteId = json[@"id"];
        self.status = [self getMPKPaymentStatusFromString:json[@"status"]];
        self.amount = amount;
        self.fundingInstrument = instrument;
        self.fees = feesList;
        self.events = eventList;
    }
    return self;
}


- (MPKFeeType) getFeeFromString:(NSString *)fType
{
    if ([fType isEqualToString:@"PRE_PAYMENT"])
    {
        return MPKFeeTypePrePayment;
    }
    else if ([fType isEqualToString:@"TRANSACTION"])
    {
        return MPKFeeTypeTransaction;
    }
    return MPKFeeTypeTransaction;
}

- (MPKEventType) getEventFromString:(NSString *)ev
{
    if ([ev isEqualToString:@"PAYMENT.IN_ANALYSIS"])
    {
        return MPKEventTypePaymentInAnalysis;
    }
    else if ([ev isEqualToString:@"PAYMENT.AUTHORIZED"])
    {
        return MPKEventTypePaymentAuthorized;
    }
    else if ([ev isEqualToString:@"PAYMENT.CANCELLED"])
    {
        return MPKEventTypePaymentCancelled;
    }
    else if ([ev isEqualToString:@"PAYMENT.CREATED"])
    {
        return MPKEventTypePaymentCreated;
    }
    else if ([ev isEqualToString:@"PAYMENT.REVERTED"])
    {
        return MPKEventTypePaymentReverted;
    }
    else if ([ev isEqualToString:@"PAYMENT.REFUNDED"])
    {
        return MPKEventTypePaymentRefunded;
    }
    else if ([ev isEqualToString:@"PAYMENT.SETTELED"])
    {
        return MPKEventTypePaymentSettled;
    }
    else if ([ev isEqualToString:@"ORDER.NOT_PAID"])
    {
        return MPKEventTypeOrderNotPaid;
    }
    else if ([ev isEqualToString:@"ORDER.PAID"])
    {
        return MPKEventTypeOrderPaid;
    }
    else if ([ev isEqualToString:@"ORDER.REVERTED"])
    {
        return MPKEventTypeOrderReverted;
    }
    else if ([ev isEqualToString:@"ORDER.WAITING"])
    {
        return MPKEventTypeOrderWaiting;
    }
    return MPKEventTypeUnknown;
}

- (MPKPaymentStatus) getMPKPaymentStatusFromString:(NSString *)method
{
    if ([method isEqualToString:@"AUTHORIZED"])
    {
        return MPKPaymentStatusAuthorized;
    }
    else if ([method isEqualToString:@"IN_ANALYSIS"])
    {
        return MPKPaymentStatusInAnalysis;
    }
    else if ([method isEqualToString:@"CONCLUED"])
    {
        return MPKPaymentStatusConcluded;
    }
    else if ([method isEqualToString:@"CANCELLED"])
    {
        return MPKPaymentStatusCancelled;
    }
    else if ([method isEqualToString:@"REFUNDED"])
    {
        return MPKPaymentStatusRefunded;
    }
    else if ([method isEqualToString:@"REVERSED"])
    {
        return MPKPaymentStatusReversed;
    }
    else if ([method isEqualToString:@"INITIATED"])
    {
        return MPKPaymentStatusInitiated;
    }
    else if ([method isEqualToString:@"PRINTED"])
    {
        return MPKPaymentStatusPrinted;
    }
    return MPKPaymentStatusInAnalysis;
}

- (MPKCurrency) getMPKCurrencyFromString:(NSString *)MPKCurrency
{
    return BRL;
}


@end
