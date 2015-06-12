//
//  CreditCard.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 06/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKCreditCard.h"

@implementation MPKCreditCard

- (BOOL) isNumberValid {
    return [self isValidLuhn];
}

- (BOOL) isSecurityCodeValid {
    return self.cvc.length >= 3 && self.cvc.length <= 4;
}

- (BOOL) isExpiryDateValid {
    return [self isValidLengthExpiryDate] && [self isValidDate];
}

- (BOOL)isValidLuhn {
    BOOL odd = true;
    int sum = 0;
    NSMutableArray *digits = [NSMutableArray arrayWithCapacity:self.number.length];
    
    for (int i = 0; i < self.number.length; i++) {
        [digits addObject:[self.number substringWithRange:NSMakeRange(i, 1)]];
    }
    
    for (NSString *digitStr in [digits reverseObjectEnumerator]) {
        int digit = [digitStr intValue];
        if ((odd = !odd)) digit *= 2;
        if (digit > 9) digit -= 9;
        sum += digit;
    }
    
    return sum % 10 == 0;
}

- (BOOL)isValidLengthExpiryDate {
    return self.expirationMonth.length == 2 && (self.expirationYear.length == 2 || self.expirationYear.length == 4);
}

- (BOOL)isValidDate {
    if (self.expirationMonth <= 0 || [self month] > 12) return NO;
    
    return [self isValidWithDate:[NSDate date]];
}

- (BOOL)isValidWithDate:(NSDate *)dateToCompare {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:dateToCompare];
    BOOL valid = NO;
    
    if (components.year < [self year]) {
        valid = YES;
    } else if (components.year == [self year]) {
        valid = components.month <= [self month];
    }
    
    return valid;
}

- (MPKCardType)cardType {
    if (self.number.length < 2) {
        return MPKCardTypeUnknown;
    }
    
    NSString *firstChars = [self.number substringWithRange:NSMakeRange(0, 2)];
    NSInteger range = [firstChars integerValue];
    
    if (range >= 40 && range <= 49) {
        return MPKCardTypeVisa;
    } else if (range >= 50 && range <= 59) {
        return MPKCardTypeMasterCard;
    } else if (range == 34 || range == 37) {
        return MPKCardTypeAmex;
    } else if (range == 60 || range == 62 || range == 64 || range == 65) {
        return MPKCardTypeDiscover;
    } else if (range == 35) {
        return MPKCardTypeJCB;
    } else if (range == 30 || range == 36 || range == 38 || range == 39) {
        return MPKCardTypeDinersClub;
    } else {
        return MPKCardTypeUnknown;
    }
}

- (NSUInteger) month {
    return (NSUInteger) [self.expirationMonth integerValue];
}

- (NSUInteger) year {
    return (NSUInteger) [self.expirationYear integerValue];
}


@end
