//
//  MPKCheckoutViewController.h
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 ThinkMob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoipSDK.h"
#import "MoipHttpRequester.h"
#import "MoipHttpResponse.h"
#import "HTTPStatusCodes.h"

typedef NS_ENUM(NSInteger, MPKTextFieldTag)
{
    MPKTextFieldTagCPF,
    MPKTextFieldTagPhoneNumber,
    MPKTextFieldTagHolder,
    MPKTextFieldTagCreditCard,
    MPKTextFieldTagCVC,
    MPKTextFieldTagExpirationDate,
    MPKTextFieldTagFullname,
    MPKTextFieldTagBirthdate
};

@class MPKConfiguration;

@protocol  MPKCheckoutDelegate;

@interface MPKCheckoutViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property NSString *publicKey;
@property NSString *authorization;
@property NSString *moipOrderId;
@property NSInteger installmentCount;
@property id<MPKCheckoutDelegate> delegate;

- (instancetype) initWithConfiguration:(MPKConfiguration *)configuration;

@end


@protocol MPKCheckoutDelegate <NSObject>

- (void) paymentTransactionSuccess:(MPKPaymentTransaction *)transaction;
- (void) paymentTransactionFailure:(NSArray *)errorList;

@end