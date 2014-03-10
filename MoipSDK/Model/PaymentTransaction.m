//
//  PaymentTransaction.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "PaymentTransaction.h"
#import "Payment.h"

@implementation PaymentTransaction

- (PaymentTransaction *) parseResponse:(NSData *)jsonData
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    
    if (json != nil)
    {
        Amount *amount = [Amount new];
        amount.total = [json[@"amount"][@"total"] intValue];
        amount.fees = [json[@"amount"][@"fees"] intValue];
        amount.refunds = [json[@"amount"][@"refunds"] intValue];
        amount.liquid = [json[@"amount"][@"liquid"] intValue];
        amount.currency = [self.payment getCurrencyFromString:json[@"amount"][@"currency"] ];
        
        CreditCard *creditCard = [CreditCard new];
        creditCard.creditCardId = json[@"fundingInstrument"][@"creditCard"][@"id"];
        creditCard.customerOwnId = json[@"fundingInstrument"][@"creditCard"][@"customerOwnId"];
        creditCard.brand = [creditCard getBrandFromString:json[@"fundingInstrument"][@"creditCard"][@"brand"]];
        creditCard.first6 = json[@"fundingInstrument"][@"creditCard"][@"first6"];
        creditCard.last4 = json[@"fundingInstrument"][@"creditCard"][@"last4"];
        
        Payment *payment = [Payment new];
        payment.paymenteId = json[@"id"];
        payment.status = [payment getPaymentStatusFromString:json[@"status"]];
        payment.amount = amount;
        payment.creditCard = creditCard;

        FundingInstrument *instrument = [FundingInstrument new];
        instrument.institution = payment.creditCard.brand;
        instrument.paymentMethod = [payment getPaymentMethodFromString:json[@"fundingInstrument"][@"method"]];
        
        self.installmentCount = [json[@"installmentCount"] intValue];
        self.payment = payment;
        self.fundingInstrument = instrument;
        
        NSMutableArray *feesList = [NSMutableArray new];
        for (NSDictionary *feeInfo in json[@"fees"])
        {
            Fee *fee = [Fee new];
            fee.type = [self getFeeFromString:feeInfo[@"type"]];
            fee.amount = [feeInfo[@"amount"] intValue];
            
            [feesList addObject:fee];
        }
        
        self.fees = feesList;
        
        NSMutableArray *eventList = [NSMutableArray new];
        for (NSDictionary *evInfo in json[@"events"])
        {
            Event *ev = [Event new];
            ev.type = [self getEventFromString:evInfo[@"type"]];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss-S"];
            
            NSString *dateStr = [evInfo[@"createdAt"] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            NSDate *dt = [dateFormat dateFromString:dateStr];
            ev.createdAt = dt;
            ev.description = evInfo[@"description"];
            
            [feesList addObject:ev];
        }
        
        self.events = eventList;
    }
    return self;
}


- (FeeType) getFeeFromString:(NSString *)fType
{
    if ([fType isEqualToString:@"PRE_PAYMENT"])
    {
        return FeeTypePrePayment;
    }
    else if ([fType isEqualToString:@"TRANSACTION"])
    {
        return FeeTypeTransaction;
    }
    return FeeTypeTransaction;
}

- (EventType) getEventFromString:(NSString *)ev
{
    if ([ev isEqualToString:@"PAYMENT.IN_ANALYSIS"])
    {
        return EventTypePaymentInAnalysis;
    }
    else if ([ev isEqualToString:@"PAYMENT.AUTHORIZED"])
    {
        return EventTypePaymentAuthorized;
    }
    else if ([ev isEqualToString:@"PAYMENT.CANCELLED"])
    {
        return EventTypePaymentCancelled;
    }
    else if ([ev isEqualToString:@"PAYMENT.CREATED"])
    {
        return EventTypePaymentCreated;
    }
    else if ([ev isEqualToString:@"PAYMENT.REVERTED"])
    {
        return EventTypePaymentReverted;
    }
    else if ([ev isEqualToString:@"PAYMENT.REFUNDED"])
    {
        return EventTypePaymentRefunded;
    }
    else if ([ev isEqualToString:@"PAYMENT.SETTELED"])
    {
        return EventTypePaymentSettled;
    }
    else if ([ev isEqualToString:@"ORDER.NOT_PAID"])
    {
        return EventTypeOrderNotPaid;
    }
    else if ([ev isEqualToString:@"ORDER.PAID"])
    {
        return EventTypeOrderPaid;
    }
    else if ([ev isEqualToString:@"ORDER.REVERTED"])
    {
        return EventTypeOrderReverted;
    }
    else if ([ev isEqualToString:@"ORDER.WAITING"])
    {
        return EventTypeOrderWaiting;
    }
    return EventTypeUnknown;
}


@end
