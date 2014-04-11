//
//  PKPaymentField.h
//  PKPayment Example
//
//  Created by Alex MacCaw on 1/22/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPKCreditCard.h"

@class MPKView, PKTextField;

@protocol MPKViewDelegate <NSObject>
@optional
- (void)paymentViewWithCard:(MPKCreditCard *)card isValid:(BOOL)valid;
@end

@interface MPKView : UIView

@property UIFont *defaultTextFieldFont;
@property UIColor *defaultTextFieldTextColor;

@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, strong) UIView *clipView;
@property (nonatomic, strong) UIImageView *placeholderView;
@property (nonatomic, strong) UIView *opaqueOverGradientView;
@property (readonly) MPKCreditCard *card;

- (id)initWithFrame:(CGRect)frame delegate:(id)_del;
- (BOOL)isValid;

@end
