//
//  MPKTextField.h
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 12/03/14.
//  Copyright (c) 2014 ThinkMob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPKInterceptor;

@interface MPKCreditCardTextField : UITextField<UITextFieldDelegate>
{
    MPKInterceptor *_delegateInterceptor;
    NSString *_encryptedNumber;
    NSString *_number;
}

@property (assign, nonatomic) Brand cardType;
@property (strong, nonatomic) UIImage *cardLogo;

@end