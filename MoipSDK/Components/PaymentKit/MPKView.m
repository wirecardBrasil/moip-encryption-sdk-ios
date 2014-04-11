//
//  PKPaymentField.m
//  PKPayment Example
//
//  Created by Fernando Sousa on 3/22/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#define GET_RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define DarkGreyColor GET_RGB(0,0,0)
#define RedColor GET_RGB(253,0,17)
#define DefaultBoldFont [UIFont fontWithName:@"HelveticaNeue" size:15]

#define kPKViewPlaceholderViewAnimationDuration 0.25

#define kPKViewCardExpiryFieldStartX 84 + 200
#define kPKViewCardCVCFieldStartX 177 + 200

#define kPKViewCardExpiryFieldEndX 84
#define kPKViewCardCVCFieldEndX 177

static NSString *const kPKLocalizedStringsTableName = @"MoipPaymentKit";
static NSString *const kPKOldLocalizedStringsTableName = @"STPaymentLocalizable";

#import "MPKView.h"
#import "MPKTextField.h"
#import "MPKCard.h"
#import "MPKCardNumber.h"
#import "MPKCardExpiry.h"
#import "MPKCardCVC.h"
#import "MPKEnums.h"
#import "MPKCheckoutViewController.h"

@interface MPKView () <MPKTextFieldDelegate> {
@private
    BOOL _isInitialState;
    BOOL _isValidState;
}

@property (nonatomic, readonly, assign) UIResponder *firstResponderField;
@property (nonatomic, readonly, assign) MPKTextField *firstInvalidField;
@property (nonatomic, readonly, assign) MPKTextField *nextFirstResponder;

- (void)setupPlaceholderView;
- (void)setupCardNumberField;
- (void)setupCardExpiryField;
- (void)setupCardCVCField;

- (void)pkTextFieldDidBackSpaceWhileTextIsEmpty:(PKTextField *)textField;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;
- (BOOL)cardCVCShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString;

@property MPKTextField *cardNumberField;
@property MPKTextField *cardCVCField;
@property MPKTextField *cardExpiryField;

@property (nonatomic, readonly) MPKCardNumber *cardNumber;
@property (nonatomic, readonly) MPKCardExpiry *cardExpiry;
@property (nonatomic, readonly) MPKCardCVC *cardCVC;
@property (nonatomic, weak) id <MPKViewDelegate> delegate;

@end

#pragma mark -

@implementation MPKView

- (id)initWithFrame:(CGRect)frame delegate:(id)_del
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.delegate = _del;
        if ([self.delegate isKindOfClass:[MPKCheckoutViewController class]])
        {
            [self setup:YES];
        }
        else
        {
            [self setup:NO];
        }
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup:NO];
}

- (void)setup:(BOOL) moip
{
    _isInitialState = YES;
    _isValidState = NO;

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.backgroundColor = [UIColor clearColor];

    if (moip)
    {
        self.innerView = [[UIView alloc] initWithFrame:CGRectMake(40, 0, self.frame.size.width - 40, 55)];
        self.innerView.clipsToBounds = YES;
        
        [self setupPlaceholderViewMoipCheckout];
        [self setupCardNumberFieldMoipCheckout];
        [self setupCardExpiryFieldMoipCheckout];
        [self setupCardCVCFieldMoipCheckout];
    }
    else
    {
        self.innerView = [[UIView alloc] initWithFrame:CGRectMake(40, 0, self.frame.size.width - 40, self.frame.size.height)];
        self.innerView.clipsToBounds = YES;

        UIView *backgroundImageView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundImageView.backgroundColor = [UIColor whiteColor];
        backgroundImageView.layer.cornerRadius = 5.4f;
        backgroundImageView.layer.borderWidth = 0.7f;
        backgroundImageView.layer.borderColor = [[UIColor colorWithWhite:0.1f alpha:0.2f] CGColor];
        [self addSubview:backgroundImageView];
        
        [self setupPlaceholderView];
        [self setupCardNumberField];
        [self setupCardExpiryField];
        [self setupCardCVCField];
    }

    [self.innerView addSubview:self.cardNumberField];
    
    self.opaqueOverGradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 34)];
    self.opaqueOverGradientView.backgroundColor = [UIColor whiteColor];
    self.opaqueOverGradientView.alpha = 0.0;
    [self.innerView addSubview:self.opaqueOverGradientView];

    [self addSubview:self.innerView];
    [self addSubview:self.placeholderView];

    [self stateCardNumber];

}


- (void)setupPlaceholderViewMoipCheckout
{
    self.placeholderView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 17.5f, 32, 20)];
    self.placeholderView.backgroundColor = [UIColor clearColor];
    self.placeholderView.image = [UIImage imageNamed:@"placeholder"];

    CALayer *clip = [CALayer layer];
    clip.frame = CGRectMake(32, 0, 4, 20);
    clip.backgroundColor = [UIColor clearColor].CGColor;
    [self.placeholderView.layer addSublayer:clip];
}

- (void)setupCardNumberFieldMoipCheckout
{
    self.cardNumberField = [[MPKTextField alloc] initWithFrame:CGRectMake(12, 0, 175, 55)];
    self.cardNumberField.delegate = self;
    self.cardNumberField.placeholder = [self.class localizedStringWithKey:@"placeholder.card_number" defaultValue:@"1234 5678 9012 3456"];
    self.cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardNumberField.textColor = self.defaultTextFieldTextColor;
    self.cardNumberField.font = self.defaultTextFieldFont;

    [self.cardNumberField.layer setMasksToBounds:YES];
}

- (void)setupCardExpiryFieldMoipCheckout
{
    self.cardExpiryField = [[MPKTextField alloc] initWithFrame:CGRectMake(kPKViewCardExpiryFieldStartX, 0, 60, 55)];
    self.cardExpiryField.delegate = self;
    self.cardExpiryField.placeholder = [self.class localizedStringWithKey:@"placeholder.card_expiry" defaultValue:@"MM/YY"];
    self.cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardExpiryField.textColor = self.defaultTextFieldTextColor;
    self.cardExpiryField.font = self.defaultTextFieldFont;

    [self.cardExpiryField.layer setMasksToBounds:YES];
}

- (void)setupCardCVCFieldMoipCheckout
{
    self.cardCVCField = [[MPKTextField alloc] initWithFrame:CGRectMake(kPKViewCardCVCFieldStartX, 0, 55, 55)];
    self.cardCVCField.delegate = self;
    self.cardCVCField.placeholder = [self.class localizedStringWithKey:@"placeholder.card_cvc" defaultValue:@"CVC"];
    self.cardCVCField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardCVCField.textColor = self.defaultTextFieldTextColor;
    self.cardCVCField.font = self.defaultTextFieldFont;

    [self.cardCVCField.layer setMasksToBounds:YES];
}

- (void)setupPlaceholderView
{
    UIImage *img = [UIImage imageNamed:@"placeholder"];
    CGFloat y = (self.frame.size.height/2)-(img.size.height/2);
    
    self.placeholderView = [[UIImageView alloc] initWithFrame:CGRectMake(12,
                                                                         y,
                                                                         32,
                                                                         20)];
    self.placeholderView.backgroundColor = [UIColor clearColor];
    self.placeholderView.image = img;
    
    CALayer *clip = [CALayer layer];
    clip.frame = CGRectMake(32, 0, 4, 20);
    clip.backgroundColor = [UIColor clearColor].CGColor;
    [self.placeholderView.layer addSublayer:clip];
}

- (void)setupCardNumberField
{
    self.cardNumberField = [[MPKTextField alloc] initWithFrame:CGRectMake(12, 0, 170, self.frame.size.height)];
    self.cardNumberField.delegate = self;
    self.cardNumberField.placeholder = [self.class localizedStringWithKey:@"placeholder.card_number" defaultValue:@"1234 5678 9012 3456"];
    self.cardNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardNumberField.textColor = DarkGreyColor;
    self.cardNumberField.font = DefaultBoldFont;
    
    [self.cardNumberField.layer setMasksToBounds:YES];
}

- (void)setupCardExpiryField
{
    self.cardExpiryField = [[MPKTextField alloc] initWithFrame:CGRectMake(kPKViewCardExpiryFieldStartX, 0, 60, self.frame.size.height)];
    self.cardExpiryField.delegate = self;
    self.cardExpiryField.placeholder = [self.class localizedStringWithKey:@"placeholder.card_expiry" defaultValue:@"MM/YY"];
    self.cardExpiryField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardExpiryField.textColor = DarkGreyColor;
    self.cardExpiryField.font = DefaultBoldFont;
    
    [self.cardExpiryField.layer setMasksToBounds:YES];
}

- (void)setupCardCVCField
{
    self.cardCVCField = [[MPKTextField alloc] initWithFrame:CGRectMake(kPKViewCardCVCFieldStartX, 0, 55, self.frame.size.height)];
    self.cardCVCField.delegate = self;
    self.cardCVCField.placeholder = [self.class localizedStringWithKey:@"placeholder.card_cvc" defaultValue:@"CVC"];
    self.cardCVCField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardCVCField.textColor = DarkGreyColor;
    self.cardCVCField.font = DefaultBoldFont;
    
    [self.cardCVCField.layer setMasksToBounds:YES];
}

// Checks both the old and new localization table (we switched in 3/14 to PaymentKit.strings).
// Leave this in for a long while to preserve compatibility.
+ (NSString *)localizedStringWithKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
    NSString *value = NSLocalizedStringFromTable(key, kPKLocalizedStringsTableName, nil);
    if (value && ![value isEqualToString:key]) { // key == no value
        return value;
    } else {
        value = NSLocalizedStringFromTable(key, kPKOldLocalizedStringsTableName, nil);
        if (value && ![value isEqualToString:key]) {
            return value;
        }
    }

    return defaultValue;
}

#pragma mark - Accessors

- (MPKCardNumber *)cardNumber
{
    return [MPKCardNumber cardNumberWithString:self.cardNumberField.text];
}

- (MPKCardExpiry *)cardExpiry
{
    return [MPKCardExpiry cardExpiryWithString:self.cardExpiryField.text];
}

- (MPKCardCVC *)cardCVC
{
    return [MPKCardCVC cardCVCWithString:self.cardCVCField.text];
}

#pragma mark - State

- (void)stateCardNumber
{
    if (!_isInitialState) {
        // Animate left
        _isInitialState = YES;

        [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.opaqueOverGradientView.alpha = 0.0;
                         } completion:^(BOOL finished) {
        }];
        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             self.cardExpiryField.frame = CGRectMake(kPKViewCardExpiryFieldStartX,
                                     self.cardExpiryField.frame.origin.y,
                                     self.cardExpiryField.frame.size.width,
                                     self.cardExpiryField.frame.size.height);
                             self.cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldStartX,
                                     self.cardCVCField.frame.origin.y,
                                     self.cardCVCField.frame.size.width,
                                     self.cardCVCField.frame.size.height);
                             self.cardNumberField.frame = CGRectMake(12,
                                     self.cardNumberField.frame.origin.y,
                                     self.cardNumberField.frame.size.width,
                                     self.cardNumberField.frame.size.height);
                         }
                         completion:^(BOOL completed) {
                             [self.cardExpiryField removeFromSuperview];
                             [self.cardCVCField removeFromSuperview];
                         }];
    }
}

- (void)stateMeta
{
    _isInitialState = NO;

    CGSize cardNumberSize;
    CGSize lastGroupSize;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    if ([self.cardNumber.formattedString respondsToSelector:@selector(sizeWithAttributes:)]) {
        NSDictionary *attributes = @{NSFontAttributeName: DefaultBoldFont};

        cardNumberSize = [self.cardNumber.formattedString sizeWithAttributes:attributes];
        lastGroupSize = [self.cardNumber.lastGroup sizeWithAttributes:attributes];
    } else {
        cardNumberSize = [self.cardNumber.formattedString sizeWithFont:DefaultBoldFont];
        lastGroupSize = [self.cardNumber.lastGroup sizeWithFont:DefaultBoldFont];
    }
#else
    NSDictionary *attributes = @{NSFontAttributeName: DefaultBoldFont};

    cardNumberSize = [self.cardNumber.formattedString sizeWithAttributes:attributes];
    lastGroupSize = [self.cardNumber.lastGroup sizeWithAttributes:attributes];
#endif

    CGFloat frameX = self.cardNumberField.frame.origin.x - (cardNumberSize.width - lastGroupSize.width);

    [UIView animateWithDuration:0.05 delay:0.35 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.opaqueOverGradientView.alpha = 1.0;
                     } completion:^(BOOL finished) {
    }];
    [UIView animateWithDuration:0.400 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.cardExpiryField.frame = CGRectMake(kPKViewCardExpiryFieldEndX,
                self.cardExpiryField.frame.origin.y,
                self.cardExpiryField.frame.size.width,
                self.cardExpiryField.frame.size.height);
        self.cardCVCField.frame = CGRectMake(kPKViewCardCVCFieldEndX,
                self.cardCVCField.frame.origin.y,
                self.cardCVCField.frame.size.width,
                self.cardCVCField.frame.size.height);
        self.cardNumberField.frame = CGRectMake(frameX,
                self.cardNumberField.frame.origin.y,
                self.cardNumberField.frame.size.width,
                self.cardNumberField.frame.size.height);
    }                completion:nil];

    [self addSubview:self.placeholderView];
    [self.innerView addSubview:self.cardExpiryField];
    [self.innerView addSubview:self.cardCVCField];
    [self.cardExpiryField becomeFirstResponder];
}

- (void)stateCardCVC
{
    [self.cardCVCField becomeFirstResponder];
}

- (BOOL)isValid
{
    return [self.cardNumber isValid] && [self.cardExpiry isValid] &&
            [self.cardCVC isValidWithType:self.cardNumber.cardType];
}

- (MPKCreditCard *)card
{
    MPKCreditCard *card = [[MPKCreditCard alloc] init];
    card.number = [self.cardNumber string];
    card.cvv = [self.cardCVC string];
    card.expirationMonth = [self.cardExpiry month];
    card.expirationYear = [self.cardExpiry year];

    return card;
}

- (void)setPlaceholderViewImage:(UIImage *)image
{
    if (![self.placeholderView.image isEqual:image]) {
        __block __unsafe_unretained UIView *previousPlaceholderView = self.placeholderView;
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.placeholderView.layer.opacity = 0.0;
                             self.placeholderView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2);
                         } completion:^(BOOL finished) {
            [previousPlaceholderView removeFromSuperview];
        }];
        self.placeholderView = nil;

        [self setupPlaceholderView];
        self.placeholderView.image = image;
        self.placeholderView.layer.opacity = 0.0;
        self.placeholderView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8);
        [self insertSubview:self.placeholderView belowSubview:previousPlaceholderView];
        [UIView animateWithDuration:kPKViewPlaceholderViewAnimationDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.placeholderView.layer.opacity = 1.0;
                             self.placeholderView.layer.transform = CATransform3DIdentity;
                         } completion:^(BOOL finished) {
        }];
    }
}

- (void)setPlaceholderToCVC
{
    MPKCardNumber *cardNumber = [MPKCardNumber cardNumberWithString:self.cardNumberField.text];
    MPKCardType
    cardType = [cardNumber cardType];

    if (cardType == MPKCardTypeAmex) {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc-amex"]];
    } else {
        [self setPlaceholderViewImage:[UIImage imageNamed:@"cvc"]];
    }
}

- (void)setPlaceholderToCardType
{
    MPKCardNumber *cardNumber = [MPKCardNumber cardNumberWithString:self.cardNumberField.text];
    MPKCardType cardType = [cardNumber cardType];
    NSString *cardTypeName = @"placeholder";

    switch (cardType) {
        case MPKCardTypeAmex:
            cardTypeName = @"amex";
            break;
        case MPKCardTypeDinersClub:
            cardTypeName = @"diners";
            break;
        case MPKCardTypeDiscover:
            cardTypeName = @"discover";
            break;
        case MPKCardTypeJCB:
            cardTypeName = @"jcb";
            break;
        case MPKCardTypeMasterCard:
            cardTypeName = @"mastercard";
            break;
        case MPKCardTypeVisa:
            cardTypeName = @"visa";
            break;
        default:
            break;
    }

    [self setPlaceholderViewImage:[UIImage imageNamed:cardTypeName]];
}

#pragma mark - Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.cardCVCField]) {
        [self setPlaceholderToCVC];
    } else {
        [self setPlaceholderToCardType];
    }

    if ([textField isEqual:self.cardNumberField] && !_isInitialState) {
        [self stateCardNumber];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if ([textField isEqual:self.cardNumberField]) {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    if ([textField isEqual:self.cardExpiryField]) {
        return [self cardExpiryShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    if ([textField isEqual:self.cardCVCField]) {
        return [self cardCVCShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    return YES;
}

- (void)pkTextFieldDidBackSpaceWhileTextIsEmpty:(MPKTextField *)textField
{
    if (textField == self.cardCVCField)
        [self.cardExpiryField becomeFirstResponder];
    else if (textField == self.cardExpiryField)
        [self stateCardNumber];
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [MPKTextField textByRemovingUselessSpacesFromString:resultString];
    MPKCardNumber *cardNumber = [MPKCardNumber cardNumberWithString:resultString];

    if (![cardNumber isPartiallyValid])
        return NO;

    if (replacementString.length > 0) {
        self.cardNumberField.text = [cardNumber formattedStringWithTrail];
    } else {
        self.cardNumberField.text = [cardNumber formattedString];
    }

    [self setPlaceholderToCardType];

    if ([cardNumber isValid]) {
        [self textFieldIsValid:self.cardNumberField];
        [self stateMeta];

    } else if ([cardNumber isValidLength] && ![cardNumber isValidLuhn]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:YES];

    } else if (![cardNumber isValidLength]) {
        [self textFieldIsInvalid:self.cardNumberField withErrors:NO];
    }

    return NO;
}

- (BOOL)cardExpiryShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardExpiryField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [MPKTextField textByRemovingUselessSpacesFromString:resultString];
    MPKCardExpiry *cardExpiry = [MPKCardExpiry cardExpiryWithString:resultString];

    if (![cardExpiry isPartiallyValid]) return NO;

    // Only support shorthand year
    if ([cardExpiry formattedString].length > 5) return NO;

    if (replacementString.length > 0) {
        self.cardExpiryField.text = [cardExpiry formattedStringWithTrail];
    } else {
        self.cardExpiryField.text = [cardExpiry formattedString];
    }

    if ([cardExpiry isValid]) {
        [self textFieldIsValid:self.cardExpiryField];
        [self stateCardCVC];

    } else if ([cardExpiry isValidLength] && ![cardExpiry isValidDate]) {
        [self textFieldIsInvalid:self.cardExpiryField withErrors:YES];
    } else if (![cardExpiry isValidLength]) {
        [self textFieldIsInvalid:self.cardExpiryField withErrors:NO];
    }

    return NO;
}

- (BOOL)cardCVCShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    NSString *resultString = [self.cardCVCField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [MPKTextField textByRemovingUselessSpacesFromString:resultString];
    MPKCardCVC *cardCVC = [MPKCardCVC cardCVCWithString:resultString];
    MPKCardType cardType = [[MPKCardNumber cardNumberWithString:self.cardNumberField.text] cardType];

    // Restrict length
    if (![cardCVC isPartiallyValidWithType:cardType]) return NO;

    // Strip non-digits
    self.cardCVCField.text = [cardCVC formattedString];

    if ([cardCVC isValidWithType:cardType]) {
        [self textFieldIsValid:self.cardCVCField];
    } else {
        [self textFieldIsInvalid:self.cardCVCField withErrors:NO];
    }

    return NO;
}


#pragma mark - Validations

- (void)checkValid
{
    if ([self isValid])
    {
        _isValidState = YES;
        if ([self.delegate respondsToSelector:@selector(paymentViewWithCard:isValid:)]) {
            [self.delegate paymentViewWithCard:self.card isValid:YES];
        }

    } else if (![self isValid] && _isValidState) {
        _isValidState = NO;

        if ([self.delegate respondsToSelector:@selector(paymentViewWithCard:isValid:)]) {
            [self.delegate paymentViewWithCard:self.card isValid:NO];
        }
    }
}

- (void)textFieldIsValid:(UITextField *)textField
{
    textField.textColor = DarkGreyColor;
    [self checkValid];
}

- (void)textFieldIsInvalid:(UITextField *)textField withErrors:(BOOL)errors
{
    if (errors) {
        textField.textColor = RedColor;
    } else {
        textField.textColor = DarkGreyColor;
    }

    [self checkValid];
}

#pragma mark -
#pragma mark UIResponder
- (UIResponder *)firstResponderField;
{
    NSArray *responders = @[self.cardNumberField, self.cardExpiryField, self.cardCVCField];
    for (UIResponder *responder in responders) {
        if (responder.isFirstResponder) {
            return responder;
        }
    }

    return nil;
}

- (MPKTextField *)firstInvalidField;
{
    if (![[MPKCardNumber cardNumberWithString:self.cardNumberField.text] isValid])
        return self.cardNumberField;
    else if (![[MPKCardExpiry cardExpiryWithString:self.cardExpiryField.text] isValid])
        return self.cardExpiryField;
    else if (![[MPKCardCVC cardCVCWithString:self.cardCVCField.text] isValid])
        return self.cardCVCField;

    return nil;
}

- (MPKTextField *)nextFirstResponder;
{
    if (self.firstInvalidField)
        return self.firstInvalidField;

    return self.cardCVCField;
}

- (BOOL)isFirstResponder;
{
    return self.firstResponderField.isFirstResponder;
}

- (BOOL)canBecomeFirstResponder;
{
    return self.nextFirstResponder.canBecomeFirstResponder;
}

- (BOOL)becomeFirstResponder;
{
    return [self.nextFirstResponder becomeFirstResponder];
}

- (BOOL)canResignFirstResponder;
{
    return self.firstResponderField.canResignFirstResponder;
}

- (BOOL)resignFirstResponder;
{
    return [self.firstResponderField resignFirstResponder];
}

@end
