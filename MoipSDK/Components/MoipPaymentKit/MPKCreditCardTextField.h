//
//  MPKTextField.h
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 12/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPKInterceptor;

@interface MPKCreditCardTextField : UITextField<UITextFieldDelegate>
{
    MPKInterceptor *_delegateInterceptor;
}

@property (assign, nonatomic) MPKBrand cardType;
@property (strong, nonatomic) UIImage *cardLogo;

- (id)initWithPublicKey:(NSString *)publicKeyText;

@end