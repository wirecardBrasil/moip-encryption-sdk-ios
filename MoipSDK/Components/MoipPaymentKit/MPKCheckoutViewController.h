//
//  MPKCheckoutViewController.h
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Constants.h"
#import "MPKPaymentTransaction.h"

static NSString *MPKTextFullname = @"MPKTextFullname";
static NSString *MPKTextCPF = @"MPKTextCPF";
static NSString *MPKTextBirthdate = @"MPKTextBirthdate";
static NSString *MPKTextPhone = @"MPKTextPhone";

typedef NS_ENUM(NSInteger, MPKTextFieldTag)
{
    MPKTextFieldTagCPF,
    MPKTextFieldTagPhoneNumber,
    MPKTextFieldTagHolder,
    MPKTextFieldTagCreditCard,
    MPKTextFieldTagCVC,
    MPKTextFieldTagExpirationDate,
    MPKTextFieldTagFullname,
    MPKTextFieldTagBirthdate,
    MPKTextFieldTagInstallmentCount
};

@class MPKConfiguration;
@protocol MPKCheckoutDelegate;

@interface MPKCheckoutViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property NSString *publicKey;
@property NSString *authorization;
@property NSString *moipOrderId;
@property NSInteger installmentCount;
@property id<MPKCheckoutDelegate> delegate;


- (instancetype) initWithConfiguration:(MPKConfiguration *)configuration maxInstallment:(NSInteger)maxInstallment;
- (void) preloadUserData:(NSDictionary *)userData;

@end


@protocol MPKCheckoutDelegate <NSObject>

- (void) paymentTransactionSuccess:(MPKPaymentTransaction *)transaction;
- (void) paymentTransactionFailure:(NSArray *)errorList;

@end