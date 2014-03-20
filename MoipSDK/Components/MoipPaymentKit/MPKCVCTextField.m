//
//  MPKCVCTextField.m
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKCVCTextField.h"
#import "MPKInterceptor.h"
#import "MPKUtilities.h"

@implementation MPKCVCTextField

#pragma mark -
#pragma mark Init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self startComponent];
        self.borderStyle = UITextBorderStyleRoundedRect;
    }
    return self;
}

- (void) startComponent
{
    self.placeholder = @"999";
    
    _delegateInterceptor = [[MPKInterceptor alloc] init];
    [_delegateInterceptor setMiddleMan:self];
    [super setDelegate:(id)_delegateInterceptor];
}

#pragma mark -
#pragma mark Get text
- (NSString *) text
{
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
    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([string rangeOfCharacterFromSet:nonNumberSet].location != NSNotFound)
    {
        textField.text = @"";
        return NO;
    }
    
    if ([super text].length == 4 && ![string isEqualToString:@""])
    {
        return NO;
    }
    
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"¥œ∑®†øπ£€¡™¢∞§¶•ªº!?,.-:–≠^ˆ}{][+=_|˜~@$%/#&><()\\'\"*"];
    for (int i = 0; i < [string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c])
            return NO;
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
- (BOOL) isValidLength
{
    if ([super text].length >= 3 && [super text].length <= 4)
    {
        return YES;
    }
    
    return NO;
}

@end
