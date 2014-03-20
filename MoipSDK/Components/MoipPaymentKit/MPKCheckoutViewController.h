//
//  MPKCheckoutViewController.h
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 ThinkMob. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MPKTextFieldTag)
{
    MPKTextFieldTagCPF,
    MPKTextFieldTagPhoneNumber,
    MPKTextFieldTagHolder,
    MPKTextFieldTagCreditCard,
    MPKTextFieldTagCVC,
    MPKTextFieldTagExpireDate,
    MPKTextFieldTagFullname,
    MPKTextFieldTagBirthdate
};

@class MPKConfiguration;

@interface MPKCheckoutViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

- (instancetype) initWithConfiguration:(MPKConfiguration *)configuration;

@end
