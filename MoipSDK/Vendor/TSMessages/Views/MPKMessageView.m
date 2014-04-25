//
//  MPKMessageView.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "MPKMessageView.h"
#import "HexColor.h"
#import "MPKBlurView.h"
#import "MPKMessage.h"


#define MPKMessageViewPadding 15.0

#define MPKDesignFileName @"MPKMessagesDefaultDesign.json"


static NSMutableDictionary *_notificationDesign;

@interface MPKMessage (MPKMessageView)
- (void)fadeOutNotification:(MPKMessageView *)currentView; // private method of MPKMessage, but called by MPKMessageView in -[fadeMeOut]
@end

@interface MPKMessageView () <UIGestureRecognizerDelegate>

/** The displayed title of this message */
@property (nonatomic, strong) NSString *title;

/** The displayed subtitle of this message view */
@property (nonatomic, strong) NSString *subtitle;

/** The title of the added button */
@property (nonatomic, strong) NSString *buttonTitle;

/** The view controller this message is displayed in */
@property (nonatomic, strong) UIViewController *viewController;


/** Internal properties needed to resize the view on device rotation properly */
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) MPKBlurView *backgroundBlurView; // Only used in iOS 7

@property (nonatomic, assign) CGFloat textSpaceLeft;
@property (nonatomic, assign) CGFloat textSpaceRight;

@property (copy) void (^callback)();
@property (copy) void (^buttonCallback)();

- (CGFloat)updateHeightOfMessageView;
- (void)layoutSubviews;

@end


@implementation MPKMessageView

+ (NSMutableDictionary *)notificationDesign
{
    if (!_notificationDesign)
    {
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"MoipSDKResources" withExtension:@"bundle"]];
        NSString *path = [[bundle resourcePath] stringByAppendingPathComponent:MPKDesignFileName];
        _notificationDesign = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                                                                            options:kNilOptions
                                                                                                              error:nil]];
    }
    
    return _notificationDesign;
}


+ (void)addNotificationDesignFromFile:(NSString *)filename
{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"MoipSDKResources" withExtension:@"bundle"]];
    NSString *path = [[bundle resourcePath] stringByAppendingPathComponent:filename];
    NSDictionary *design = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                           options:kNilOptions
                                                             error:nil];
    
    [[MPKMessageView notificationDesign] addEntriesFromDictionary:design];
}

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
canBeDismissedByUser:(BOOL)dismissingEnabled
{
    NSDictionary *notificationDesign = [MPKMessageView notificationDesign];
    
    if ((self = [self init]))
    {
        _title = title;
        _subtitle = subtitle;
        _buttonTitle = buttonTitle;
        _duration = duration;
        _viewController = viewController;
        _messagePosition = position;
        self.callback = callback;
        self.buttonCallback = buttonCallback;
        
        CGFloat screenWidth = self.viewController.view.bounds.size.width;
        NSDictionary *current;
        NSString *currentString;
        switch (notificationType)
        {
            case MPKMessageNotificationTypeMessage:
            {
                currentString = @"message";
                break;
            }
            case MPKMessageNotificationTypeError:
            {
                currentString = @"error";
                break;
            }
            case MPKMessageNotificationTypeSuccess:
            {
                currentString = @"success";
                break;
            }
            case MPKMessageNotificationTypeWarning:
            {
                currentString = @"warning";
                break;
            }
                
            default:
                break;
        }
        
        current = [notificationDesign valueForKey:currentString];
        
        
        if (!image && [current valueForKey:@"imageName"])
        {
            image = [UIImage imageNamed:[current valueForKey:@"imageName"]];
        }
        
        if (![MPKMessage iOS7StyleEnabled])
        {
            self.alpha = 0.0;
            
            // add background image here
            UIImage *backgroundImage = [[UIImage imageNamed:[current valueForKey:@"backgroundImageName"]] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            _backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            self.backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
            [self addSubview:self.backgroundImageView];
        }
        else
        {
            // On iOS 7 and above use a blur layer instead (not yet finished)
            _backgroundBlurView = [[MPKBlurView alloc] init];
            self.backgroundBlurView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
            self.backgroundBlurView.blurTintColor = [UIColor colorWithHexString:current[@"backgroundColor"]];
            [self addSubview:self.backgroundBlurView];
        }
        
        UIColor *fontColor = [UIColor colorWithHexString:[current valueForKey:@"textColor"]
                                                   alpha:1.0];
        
        
        self.textSpaceLeft = 2 * MPKMessageViewPadding;
        if (image) self.textSpaceLeft += image.size.width + 2 * MPKMessageViewPadding;
        
        // Set up title label
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setText:title];
        [self.titleLabel setTextColor:fontColor];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        CGFloat fontSize = [[current valueForKey:@"titleFontSize"] floatValue];
        NSString *fontName = [current valueForKey:@"titleFontName"];
        if (fontName != nil) {
            [self.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
        } else {
            [self.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
        }
        [self.titleLabel setShadowColor:[UIColor colorWithHexString:[current valueForKey:@"shadowColor"] alpha:1.0]];
        [self.titleLabel setShadowOffset:CGSizeMake([[current valueForKey:@"shadowOffsetX"] floatValue],
                                                    [[current valueForKey:@"shadowOffsetY"] floatValue])];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.titleLabel];
        
        // Set up content label (if set)
        if ([subtitle length])
        {
            _contentLabel = [[UILabel alloc] init];
            [self.contentLabel setText:subtitle];
            
            UIColor *contentTextColor = [UIColor colorWithHexString:[current valueForKey:@"contentTextColor"] alpha:1.0];
            if (!contentTextColor)
            {
                contentTextColor = fontColor;
            }
            [self.contentLabel setTextColor:contentTextColor];
            [self.contentLabel setBackgroundColor:[UIColor clearColor]];
            CGFloat fontSize = [[current valueForKey:@"contentFontSize"] floatValue];
            NSString *fontName = [current valueForKey:@"contentFontName"];
            if (fontName != nil) {
                [self.contentLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
            } else {
                [self.contentLabel setFont:[UIFont systemFontOfSize:fontSize]];
            }
            [self.contentLabel setShadowColor:self.titleLabel.shadowColor];
            [self.contentLabel setShadowOffset:self.titleLabel.shadowOffset];
            self.contentLabel.lineBreakMode = self.titleLabel.lineBreakMode;
            self.contentLabel.numberOfLines = 0;
            
            [self addSubview:self.contentLabel];
        }
        
        if (image)
        {
            _iconImageView = [[UIImageView alloc] initWithImage:image];
            self.iconImageView.frame = CGRectMake(MPKMessageViewPadding * 2,
                                                  MPKMessageViewPadding,
                                                  image.size.width,
                                                  image.size.height);
            [self addSubview:self.iconImageView];
        }
        
        // Set up button (if set)
        if ([buttonTitle length])
        {
            _button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            UIImage *buttonBackgroundImage = [[UIImage imageNamed:[current valueForKey:@"buttonBackgroundImageName"]] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
            
            if (!buttonBackgroundImage)
            {
                buttonBackgroundImage = [[UIImage imageNamed:[current valueForKey:@"NotificationButtonBackground"]] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
            }
            
            [self.button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
            [self.button setTitle:self.buttonTitle forState:UIControlStateNormal];
            
            UIColor *buttonTitleShadowColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTitleShadowColor"] alpha:1.0];
            if (!buttonTitleShadowColor)
            {
                buttonTitleShadowColor = self.titleLabel.shadowColor;
            }
            
            [self.button setTitleShadowColor:buttonTitleShadowColor forState:UIControlStateNormal];
            
            UIColor *buttonTitleTextColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTitleTextColor"] alpha:1.0];
            if (!buttonTitleTextColor)
            {
                buttonTitleTextColor = fontColor;
            }
            
            [self.button setTitleColor:buttonTitleTextColor forState:UIControlStateNormal];
            self.button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
            self.button.titleLabel.shadowOffset = CGSizeMake([[current valueForKey:@"buttonTitleShadowOffsetX"] floatValue],
                                                             [[current valueForKey:@"buttonTitleShadowOffsetY"] floatValue]);
            [self.button addTarget:self
                            action:@selector(buttonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            self.button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
            [self.button sizeToFit];
            self.button.frame = CGRectMake(screenWidth - MPKMessageViewPadding - self.button.frame.size.width,
                                           0.0,
                                           self.button.frame.size.width,
                                           31.0);
            
            [self addSubview:self.button];
            
            self.textSpaceRight = self.button.frame.size.width + MPKMessageViewPadding;
        }
        
        // Add a border on the bottom (or on the top, depending on the view's postion)
        if (![MPKMessage iOS7StyleEnabled])
        {
            _borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                   0.0, // will be set later
                                                                   screenWidth,
                                                                   [[current valueForKey:@"borderHeight"] floatValue])];
            self.borderView.backgroundColor = [UIColor colorWithHexString:[current valueForKey:@"borderColor"]
                                                                    alpha:1.0];
            self.borderView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
            [self addSubview:self.borderView];
        }
        
        
        CGFloat actualHeight = [self updateHeightOfMessageView]; // this call also takes care of positioning the labels
        CGFloat topPosition = -actualHeight;
        
        if (self.messagePosition == MPKMessageNotificationPositionBottom)
        {
            topPosition = self.viewController.view.bounds.size.height;
        }
        
        self.frame = CGRectMake(0.0, topPosition, screenWidth, actualHeight);
        
        if (self.messagePosition == MPKMessageNotificationPositionTop)
        {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        else
        {
            self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        }
        
        if (dismissingEnabled)
        {
            UISwipeGestureRecognizer *gestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(fadeMeOut)];
            [gestureRec setDirection:(self.messagePosition == MPKMessageNotificationPositionTop ?
                                      UISwipeGestureRecognizerDirectionUp :
                                      UISwipeGestureRecognizerDirectionDown)];
            [self addGestureRecognizer:gestureRec];
            
            UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(fadeMeOut)];
            [self addGestureRecognizer:tapRec];
        }
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}


- (CGFloat)updateHeightOfMessageView
{
    CGFloat currentHeight;
    CGFloat screenWidth = self.viewController.view.bounds.size.width;
    
    
    self.titleLabel.frame = CGRectMake(self.textSpaceLeft,
                                       MPKMessageViewPadding,
                                       screenWidth - MPKMessageViewPadding - self.textSpaceLeft - self.textSpaceRight,
                                       0.0);
    [self.titleLabel sizeToFit];
    
    if ([self.subtitle length])
    {
        self.contentLabel.frame = CGRectMake(self.textSpaceLeft,
                                             self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5.0,
                                             screenWidth - MPKMessageViewPadding - self.textSpaceLeft - self.textSpaceRight,
                                             0.0);
        [self.contentLabel sizeToFit];
        
        currentHeight = self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height;
    }
    else
    {
        // only the title was set
        currentHeight = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
    }
    
    currentHeight += MPKMessageViewPadding;
    
    if (self.iconImageView)
    {
        // Check if that makes the popup larger (height)
        if (self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + MPKMessageViewPadding > currentHeight)
        {
            currentHeight = self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height;
        }
        else
        {
            // z-align
            self.iconImageView.center = CGPointMake([self.iconImageView center].x,
                                                    round(currentHeight / 2.0));
        }
    }
    
    // z-align button
    self.button.center = CGPointMake([self.button center].x,
                                     round(currentHeight / 2.0));
    
    if (self.messagePosition == MPKMessageNotificationPositionTop)
    {
        // Correct the border position
        CGRect borderFrame = self.borderView.frame;
        borderFrame.origin.y = currentHeight;
        self.borderView.frame = borderFrame;
    }
    
    currentHeight += self.borderView.frame.size.height;
    
    self.frame = CGRectMake(0.0, self.frame.origin.y, self.frame.size.width, currentHeight);
    
    
    if (self.button)
    {
        self.button.frame = CGRectMake(self.frame.size.width - self.textSpaceRight,
                                       round((self.frame.size.height / 2.0) - self.button.frame.size.height / 2.0),
                                       self.button.frame.size.width,
                                       self.button.frame.size.height);
    }
    
    
    CGRect backgroundFrame = CGRectMake(self.backgroundImageView.frame.origin.x,
                                        self.backgroundImageView.frame.origin.y,
                                        screenWidth,
                                        currentHeight);
    
    // increase frame of background view because of the spring animation
    if ([MPKMessage iOS7StyleEnabled])
    {
        if (self.messagePosition == MPKMessageNotificationPositionTop)
        {
            float topOffset = 0.f;
            
            UINavigationController *navigationController = self.viewController.navigationController;
            if (!navigationController && [self.viewController isKindOfClass:[UINavigationController class]]) {
                navigationController = (UINavigationController *)self.viewController;
            }
            BOOL isNavBarIsHidden = !navigationController || [MPKMessage isNavigationBarInNavigationControllerHidden:self.viewController.navigationController];
            BOOL isNavBarIsOpaque = !self.viewController.navigationController.navigationBar.isTranslucent && self.viewController.navigationController.navigationBar.alpha == 1;
            
            if (isNavBarIsHidden || isNavBarIsOpaque) {
                topOffset = -30.f;
            }
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(topOffset, 0.f, 0.f, 0.f));
        }
        else if (self.messagePosition == MPKMessageNotificationPositionBottom)
        {
            backgroundFrame = UIEdgeInsetsInsetRect(backgroundFrame, UIEdgeInsetsMake(0.f, 0.f, -30.f, 0.f));
        }
    }
    
    self.backgroundImageView.frame = backgroundFrame;
    self.backgroundBlurView.frame = backgroundFrame;
    
    return currentHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateHeightOfMessageView];
}

- (void)fadeMeOut
{
    [[MPKMessage sharedMessage] performSelectorOnMainThread:@selector(fadeOutNotification:) withObject:self waitUntilDone:NO];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.duration == MPKMessageNotificationDurationEndless && self.superview && !self.window ) {
        // view controller was dismissed, let's fade out
        [self fadeMeOut];
    }
}
#pragma mark - Target/Action

- (void)buttonTapped:(id) sender
{
    if (self.buttonCallback)
    {
        self.buttonCallback();
    }
    
    [self fadeMeOut];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateRecognized)
    {
        if (self.callback)
        {
            self.callback();
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ! ([touch.view isKindOfClass:[UIControl class]]);
}

@end
