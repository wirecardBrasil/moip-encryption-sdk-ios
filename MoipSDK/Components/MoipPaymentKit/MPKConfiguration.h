//
//  MPKConfiguration.h
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 20/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPKEnvironment.h"

@interface MPKConfiguration : NSObject

@property NSString *titleView;
@property id apperance;
@property UIFont *textFieldFont;
@property UIColor *textFieldColor;
@property UIColor *textFieldBackgroundColor;
@property UIColor *viewBackgroundColor;
@property BOOL showSuccessFeedback;
@property BOOL showErrorFeedback;

@end
