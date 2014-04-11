//
//  PKTextField.h
//  PaymentKit Example
//
//  Created by Michaël Villar on 3/20/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPKTextField;

@protocol MPKTextFieldDelegate <UITextFieldDelegate>

@optional

- (void)pkTextFieldDidBackSpaceWhileTextIsEmpty:(MPKTextField *)textField;

@end

@interface MPKTextField : UITextField

+ (NSString*)textByRemovingUselessSpacesFromString:(NSString*)string;

@property (nonatomic, weak) id<MPKTextFieldDelegate> delegate;

@end

