//
//  MPKMessageView.h
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPKMessage.h"

#define MPKMessageViewAlpha 0.95



@protocol MPKMessageViewProtocol<NSObject>
@optional
/** Implement this method to pass a custom value for positioning the message view */
- (CGFloat)navigationbarBottomOfViewController:(UIViewController *)viewController;
@end




@interface MPKMessageView : UIView

/** The displayed title of this message */
@property (nonatomic, readonly) NSString *title;

/** The displayed subtitle of this message */
@property (nonatomic, readonly) NSString *subtitle;

/** The view controller this message is displayed in */
@property (nonatomic, readonly) UIViewController *viewController;

/** The duration of the displayed message. If it is 0.0, it will automatically be calculated */
@property (nonatomic, assign) CGFloat duration;

/** The position of the message (top or bottom) */
@property (nonatomic, assign) MPKMessageNotificationPosition messagePosition;

/** Is the message currenlty fully displayed? Is set as soon as the message is really fully visible */
@property (nonatomic, assign) BOOL messageIsFullyDisplayed;

/** By setting this delegate it's possible to set a custom offset for the notification view */
@property(nonatomic, assign) id <MPKMessageViewProtocol>delegate;

/** Inits the notification view. Do not call this from outside this library.
 @param title The title of the notification view
 @param subtitle The subtitle of the notification view (optional)
 @param image A custom icon image (optional)
 @param notificationType The type (color) of the notification view
 @param duration The duration this notification should be displayed (optional)
 @param viewController The view controller this message should be displayed in
 @param callback The block that should be executed, when the user tapped on the message
 @param buttonTitle The title for button (optional)
 @param buttonCallback The block that should be executed, when the user tapped on the button
 @param position The position of the message on the screen
 @param dismissingEnabled Should this message be dismissed when the user taps/swipes it?
 */
- (id)initWithTitle:(NSString *)title
           subtitle:(NSString *)subtitle
              image:(UIImage *)image
               type:(MPKMessageNotificationType)notificationType
           duration:(CGFloat)duration
   inViewController:(UIViewController *)viewController
           callback:(void (^)())callback
        buttonTitle:(NSString *)buttonTitle
     buttonCallback:(void (^)())buttonCallback
         atPosition:(MPKMessageNotificationPosition)position
canBeDismissedByUser:(BOOL)dismissingEnabled;

/** Fades out this notification view */
- (void)fadeMeOut;

/** Use this method to load a custom design file */
+ (void)addNotificationDesignFromFile:(NSString *)file;


@end
