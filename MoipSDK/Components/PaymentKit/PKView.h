//
//  PKPaymentField.h
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPKCreditCard.h"

@class PKView, PKTextField;

@protocol PKViewDelegate <NSObject>
@optional
- (void)paymentViewWithCard:(MPKCreditCard *)card isValid:(BOOL)valid;
@end

@interface PKView : UIView

@property UIFont *defaultTextFieldFont;
@property UIColor *defaultTextFieldTextColor;

@property (nonatomic, weak) id <PKViewDelegate> delegate;
@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, strong) UIView *clipView;
@property (nonatomic, strong) UIImageView *placeholderView;
@property (nonatomic, strong) UIView *opaqueOverGradientView;
@property (readonly) MPKCreditCard *card;

- (BOOL)isValid;

@end
