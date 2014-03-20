//
//  MPKCVCTextField.h
//  MoipSDK
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPKInterceptor;

@interface MPKCVCTextField : UITextField<UITextFieldDelegate>
{
    MPKInterceptor *_delegateInterceptor;
}

@end
