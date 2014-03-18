//
//  MPKTextField.m
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 12/03/14.
//  Copyright (c) 2014 ThinkMob. All rights reserved.
//

#import "MPKCreditCardTextField.h"
#import "MPKInterceptor.h"
#import "MPKEnums.h"
#import "MPKUtilities.h"

@interface MPKCreditCardTextField ()

@property SecKeyRef publicKeyRef;

@end

@implementation MPKCreditCardTextField
#pragma mark -
#pragma mark Init
- (id)initWithPublicKey:(NSString *)publicKeyText;
{
    self = [super init];
    if (self)
    {
        [MPKUtilities importPublicKey:publicKeyText];
        [self startComponent];
    }
    return self;
}

- (void) startComponent
{
    self.placeholder = @"9889 0000 0000 0000";
    
    _delegateInterceptor = [[MPKInterceptor alloc] init];
    [_delegateInterceptor setMiddleMan:self];
    [super setDelegate:(id)_delegateInterceptor];
}

#pragma mark -
#pragma mark Get text
- (NSString *) text
{
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *fullStack = [NSMutableArray arrayWithArray:[[NSThread callStackSymbols][1] componentsSeparatedByCharactersInSet:separatorSet]];
    if (fullStack.count > 0)
    {
        [fullStack removeObject:@""];

        if ([fullStack[3] isEqualToString:NSStringFromClass([self class])])
        {
            return [super text];
        }
    }

    return [MPKUtilities encryptData:[super text]];
}

#pragma mark -
#pragma mark Delegate Interception
- (id) delegate
{
    return _delegateInterceptor.receiver;
}

- (void)setDelegate:(id)newDelegate
{
    [super setDelegate:nil];
    [_delegateInterceptor setReceiver:newDelegate];
    [super setDelegate:(id)_delegateInterceptor];
}


#pragma mark -
#pragma mark Textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        [self.delegate textFieldShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:self];
    }
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        [self.delegate textFieldShouldEndEditing:self];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![string isEqualToString:@""])
    {
        self.text = [self formattedStringWithTrail];
    }
    
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        [self.delegate textField:self shouldChangeCharactersInRange:range replacementString:nil];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)])
    {
        [self.delegate textFieldShouldClear:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        [self.delegate textFieldShouldReturn:self];
    }
    return YES;
}


#pragma mark -
#pragma mark Validations
- (NSString *)formattedString
{
    NSRegularExpression *regex;
    if (self.cardType == MPKBrandAmex)
    {
        regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{1,4})(\\d{1,6})?(\\d{1,5})?" options:0 error:NULL];
    } else {
        regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{1,4})" options:0 error:NULL];
    }
    
    NSArray *matches = [regex matchesInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:matches.count];
    
    for (NSTextCheckingResult *match in matches) {
        for (int i = 1; i < [match numberOfRanges]; i++) {
            NSRange range = [match rangeAtIndex:i];
            
            if (range.length > 0) {
                NSString *matchText = [self.text substringWithRange:range];
                [result addObject:matchText];
            }
        }
    }
    
    return [result componentsJoinedByString:@" "];
}

- (NSString *)formattedStringWithTrail
{
    NSString *string = [self formattedString];
    if (string != nil)
    {
        NSRegularExpression *regex;
        if ([self isValidLength])
        {
            return string;
        }
        
        if (self.cardType == MPKBrandAmex) {
            regex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d{4}|\\d{4}\\s\\d{6})$" options:0 error:NULL];
        } else {
            regex = [NSRegularExpression regularExpressionWithPattern:@"(?:^|\\s)(\\d{4})$" options:0 error:NULL];
        }
        
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
        
        if (numberOfMatches == 0) {
            // Not at the end of a group of digits
            return string;
        } else {
            return [NSString stringWithFormat:@"%@ ", string];
        }
    }
    return nil;
}

- (BOOL)isValid
{
    return [self isValidLength] && [self isValidLuhn];
}

- (BOOL)isValidLength
{
    return self.text.length == [self lengthForCardType];
}

- (BOOL)isValidLuhn
{
    BOOL odd = true;
    int sum = 0;
    NSMutableArray *digits = [NSMutableArray arrayWithCapacity:self.text.length];
    
    for (int i = 0; i < self.text.length; i++) {
        [digits addObject:[self.text substringWithRange:NSMakeRange(i, 1)]];
    }
    
    for (NSString *digitStr in [digits reverseObjectEnumerator]) {
        int digit = [digitStr intValue];
        if ((odd = !odd)) digit *= 2;
        if (digit > 9) digit -= 9;
        sum += digit;
    }
    
    return sum % 10 == 0;
}

- (NSInteger)lengthForCardType
{
    MPKBrand type = self.cardType;
    NSInteger length;
    if (type == MPKBrandAmex) {
        length = 15;
    } else if (type == MPKBrandDinersClub) {
        length = 14;
    } else {
        length = 16;
    }
    return length;
}

- (MPKBrand) cardType
{
    if (self.text.length < 2) {
        return MPKBrandUnknown;
    }
    
    NSString *firstChars = [self.text substringWithRange:NSMakeRange(0, 2)];
    NSInteger range = [firstChars integerValue];
    
    if (range >= 40 && range <= 49) {
        return MPKBrandVisa;
    } else if (range >= 50 && range <= 59) {
        return MPKBrandMasterCard;
    } else if (range == 34 || range == 37) {
        return MPKBrandAmex;
    } else if (range == 60 || range == 62 || range == 64 || range == 65) {
        return MPKBrandDiscover;
    } else if (range == 30 || range == 36 || range == 38 || range == 39) {
        return MPKBrandDinersClub;
    } else {
        return MPKBrandUnknown;
    }
}

- (UIImage *) cardLogo
{
    NSString *cardTypeName = @"placeholder";
    switch (self.cardType)
    {
        case MPKBrandAmex:
            cardTypeName = @"amex";
            break;
        case MPKBrandDinersClub:
            cardTypeName = @"diners";
            break;
        case MPKBrandDiscover:
            cardTypeName = @"discover";
            break;
        case MPKBrandMasterCard:
            cardTypeName = @"mastercard";
            break;
        case MPKBrandVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }
    
    return [UIImage imageNamed:cardTypeName];
}

@end
