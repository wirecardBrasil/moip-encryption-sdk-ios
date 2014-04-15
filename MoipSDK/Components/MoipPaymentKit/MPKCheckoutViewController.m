//
//  MPKCheckoutViewController.m
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 Moip Pagamentos. All rights reserved.
//

#import "MPKCheckoutViewController.h"
#import "MPKView.h"
#import "MoipSDK.h"
#import "MPKConfiguration.h"
#import "MPKUtilities.h"
#import "MoipHttpRequester.h"
#import "MoipHttpResponse.h"
#import "HTTPStatusCodes.h"
#import "MPKMessage.h"
#import "MPKMessageView.h"

@interface MPKCheckoutViewController () <MPKViewDelegate>
{
    @private
    BOOL isValidCreditCard;
}

@property MPKConfiguration *configs;
@property NSInteger maxInstallmentCount;
@property NSString *phoneMask;
@property NSString *cpfMask;
@property NSString *expirationDateMask;
@property NSString *birthdateMask;
@property NSRegularExpression *regex;

@property (strong, nonatomic) MPKView *paymentView;
@property (strong, nonatomic) MPKCreditCard *card;
@property (strong, nonatomic) UITextField *txtCardHolder;
@property (strong, nonatomic) UITextField *txtFullname;
@property (strong, nonatomic) UITextField *txtDocument;
@property (strong, nonatomic) UITextField *txtPhone;
@property (strong, nonatomic) UITextField *txtBirthDate;
@property (strong, nonatomic) UITextField *txtInstallmentCount;
@property (strong, nonatomic) UITableView *tableViewForm;
@property (strong, nonatomic) UIView *loadingView;

@end

@implementation MPKCheckoutViewController

- (instancetype) initWithConfiguration:(MPKConfiguration *)configuration
                        maxInstallment:(NSInteger)maxInstallment;
{
    self = [super init];
    if (self)
    {
        self.configs = configuration;
        self.maxInstallmentCount = maxInstallment;
        self.regex = [NSRegularExpression regularExpressionWithPattern:@"[,\\.\\-\\(\\)\\ `\"]" options:0 error:nil];

        self.paymentView = [[MPKView alloc] initWithFrame:CGRectMake(5, 0, 282, 55) borderStyle:MPKViewBorderStyleNone delegate:self];
        self.paymentView.defaultTextFieldFont = self.configs.textFieldFont;
        self.paymentView.defaultTextFieldTextColor = self.configs.textFieldColor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    isValidCreditCard = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelTouched:)];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:self.configs.titleView];
    navItem.rightBarButtonItem = btnCancel;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.items = @[navItem];
    [self.view addSubview:navBar];
    
    self.view.backgroundColor = self.configs.viewBackgroundColor;
    self.phoneMask = @"(99) 999999999";
    self.cpfMask = @"999.999.999-99";
    self.expirationDateMask = @"99/99";
    self.birthdateMask = @"99/99/9999";
    
    self.tableViewForm = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    self.tableViewForm.allowsSelection = NO;
    self.tableViewForm.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableViewForm.delegate = self;
    self.tableViewForm.dataSource = self;
    [self.view addSubview:self.tableViewForm];
    [self.tableViewForm setContentInset:UIEdgeInsetsMake(0, 0, 300, 0)];

    [MPKMessage setDefaultViewController:self];

    [self setupPaymentForm];
    [self setupLoadingView];
    [self.txtCardHolder becomeFirstResponder];
    
}

- (void) preloadUserData:(NSDictionary *)userData
{
    self.txtFullname.text = userData[MPKTextFullname];
    self.txtDocument.text = userData[MPKTextCPF];
    self.txtBirthDate.text = userData[MPKTextBirthdate];
    self.txtPhone.text = userData[MPKTextPhone];
}

- (void) setupPaymentForm
{
    // Form
    self.txtCardHolder = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 282, 55)];
    self.txtCardHolder.borderStyle = UITextBorderStyleNone;
    self.txtCardHolder.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.txtCardHolder.tag = MPKTextFieldTagHolder;
    self.txtCardHolder.placeholder = @"Nome (como no cartão)";
    self.txtCardHolder.font = self.configs.textFieldFont;
    self.txtCardHolder.delegate = self;
    
    self.txtFullname = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 282, 55)];
    self.txtFullname.borderStyle = UITextBorderStyleNone;
    self.txtFullname.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.txtFullname.placeholder = @"Nome completo";
    self.txtFullname.font = self.configs.textFieldFont;
    self.txtFullname.delegate = self;
    self.txtFullname.tag = MPKTextFieldTagFullname;

//    self.txtInstallmentCount = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 202, 55)];
//    self.txtInstallmentCount.borderStyle = UITextBorderStyleNone;
//    self.txtInstallmentCount.keyboardType = UIKeyboardTypeNumberPad;
//    self.txtInstallmentCount.autocorrectionType = UITextAutocorrectionTypeNo;
//    self.txtInstallmentCount.placeholder = @"12";
//    self.txtInstallmentCount.font = self.configs.textFieldFont;
//    self.txtInstallmentCount.delegate = self;
//    self.txtInstallmentCount.tag = MPKTextFieldTagInstallmentCount;
    
    self.txtPhone = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 282, 55)];
    self.txtPhone.borderStyle = UITextBorderStyleNone;
    self.txtPhone.keyboardType = UIKeyboardTypeNumberPad;
    self.txtPhone.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtPhone.placeholder = @"Telefone";
    self.txtPhone.font = self.configs.textFieldFont;
    self.txtPhone.delegate = self;
    self.txtPhone.tag = MPKTextFieldTagPhoneNumber;
    
    self.txtDocument = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 160, 55)];
    self.txtDocument.borderStyle = UITextBorderStyleNone;
    self.txtDocument.keyboardType = UIKeyboardTypeNumberPad;
    self.txtDocument.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtDocument.placeholder = @"CPF";
    self.txtDocument.font = self.configs.textFieldFont;
    self.txtDocument.delegate = self;
    self.txtDocument.tag = MPKTextFieldTagCPF;
    
    self.txtBirthDate = [[UITextField alloc] initWithFrame:CGRectMake(185, 0, 120, 55)];
    self.txtBirthDate.borderStyle = UITextBorderStyleNone;
    self.txtBirthDate.keyboardType = UIKeyboardTypeNumberPad;
    self.txtBirthDate.placeholder = @"Nascimento";
    self.txtBirthDate.font = self.configs.textFieldFont;
    self.txtBirthDate.delegate = self;
    self.txtBirthDate.tag = MPKTextFieldTagBirthdate;
}

- (void) setupLoadingView
{
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.loadingView.backgroundColor = [UIColor clearColor];
    self.loadingView.alpha = 0;
    
    UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actIndicator.frame = CGRectMake(self.loadingView.frame.size.width/2 - 37/2, self.loadingView.frame.size.height/2 - 37/2, 37, 37);
    actIndicator.color = [UIColor whiteColor];
    [actIndicator startAnimating];
    
    UIView *loadingSubView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    loadingSubView.backgroundColor = [UIColor blackColor];
    loadingSubView.alpha = 0.7f;
    loadingSubView.layer.cornerRadius = 5.0f;
    [loadingSubView addSubview:actIndicator];
    
    [self.loadingView addSubview:loadingSubView];
}

#pragma mark -
#pragma mark Table View
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section)
    {
        case 0:
            title = @"Dados do pagamento";
            break;

        case 1:
            title = @"Dados do comprador";
            break;
            
        default:
            break;
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
            return 3;
            break;
            
        case 2:
            return 1;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = [NSString stringWithFormat:@"PaymentFormCellID_%li_%li", (long)indexPath.section, (long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                [cell.contentView addSubview:self.txtCardHolder];
                break;
            case 1:
                [cell.contentView addSubview:self.paymentView];
                break;
//            case 2:
//                cell.textLabel.text = @"Parcelas";
//                [cell.contentView addSubview:self.txtInstallmentCount];
//                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
                [cell.contentView addSubview:self.txtFullname];
                break;
            case 1:
                [cell.contentView addSubview:self.txtDocument];
                [cell.contentView addSubview:self.txtBirthDate];
                break;
            case 2:
                [cell.contentView addSubview:self.txtPhone];
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section == 2)
    {
        UIButton *btnPay = [[UIButton alloc] initWithFrame:CGRectMake(170, 0, 140, 55)];
        [btnPay setTitle:@"Pagar" forState:UIControlStateNormal];
        [btnPay addTarget:self action:@selector(btnPayTouched:) forControlEvents:UIControlEventTouchUpInside];
        [btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnPay.titleLabel.font = self.configs.textFieldFont;
        btnPay.backgroundColor = [UIColor blueColor];
        
        UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 140, 55)];
        [btnCancel setTitle:@"Cancelar" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(btnCancelTouched:) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnCancel.titleLabel.font = self.configs.textFieldFont;
        btnCancel.backgroundColor = [UIColor lightGrayColor];
        
        [cell.contentView addSubview:btnCancel];
        [cell.contentView addSubview:btnPay];

        cell.indentationWidth = 2000;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

#pragma mark -
#pragma mark Actions
- (void) btnPayTouched:(id)sender
{
    if ([self allFieldsAreValid])
    {
        [self showLoadingView];

        NSString *docNumber = [self removeInvalidCharacters:self.txtDocument];
        NSString *phoneNumber = [self removeInvalidCharacters:self.txtPhone];
        NSArray *birthdate = [self.txtBirthDate.text componentsSeparatedByString:@"/"];
        
        MPKCardHolder *holder = [MPKCardHolder new];
        holder.fullname = self.txtFullname.text;
        holder.birthdate = [NSString stringWithFormat:@"%@-%@-%@", birthdate[2], birthdate[1], birthdate[0]];
        holder.documentType = MPKCardHolderDocumentTypeCPF;
        holder.documentNumber = docNumber;
        holder.phoneCountryCode = @"55";
        holder.phoneAreaCode = [phoneNumber substringToIndex:2];
        holder.phoneNumber = [phoneNumber substringFromIndex:2];
        
        MPKPayment *payment = [MPKPayment new];
        payment.moipOrderId = self.moipOrderId;
        payment.installmentCount = 2;//self.installmentCount;
        payment.method = MPKPaymentMethodCreditCard;
        _card.cardholder = holder;
        payment.creditCard = _card;
        
        MoipSDK *instance = [MoipSDK session];
        [instance submitPayment:payment success:^(MPKPaymentTransaction *transaction) {
            [self hideLoadingView];
            
            if ([self.delegate respondsToSelector:@selector(paymentTransactionSuccess:)])
            {
                [self.delegate performSelector:@selector(paymentTransactionSuccess:) withObject:transaction];
            }
            
            if (self.configs.showSuccessFeedback)
            {
                [self showSuccessFeedback:transaction];
            }
            else
            {
                [self dismissAction];
            }
            
        } failure:^(NSArray *errorList) {
            [self hideLoadingView];
            
            if ([self.delegate respondsToSelector:@selector(paymentTransactionFailure:)])
            {
                [self.delegate performSelector:@selector(paymentTransactionFailure:) withObject:errorList];
            }
            
            if (self.configs.showErrorFeedback)
            {
                [self showErrorFeedback:errorList];
            }
            else
            {
                [self dismissAction];
            }
        }];
    }
}

- (void) btnCancelTouched:(id)sender
{
    [self dismissAction];
    

}


- (void) dismissAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showSuccessFeedback:(MPKPaymentTransaction *)transaction
{
    NSString *message = @"Seu pagamento %@ com sucesso!";
    if (transaction.status == MPKPaymentStatusAuthorized)
    {
        message = [NSString stringWithFormat:message, @"foi autorizado"];
    }
    else if (transaction.status == MPKPaymentStatusConcluded)
    {
        message = [NSString stringWithFormat:message, @"foi concluido"];
    }
    
    [MPKMessage showNotificationWithTitle:@"Pagamento criado!"
                                subtitle:@"O pagamento foi efetuado com sucesso!"
                                    type:MPKMessageNotificationTypeSuccess];
}

- (void) showErrorFeedback:(NSArray *)errors
{
    NSMutableString *errorMessage = [NSMutableString string];
    for (MPKError *er in errors)
    {
        [errorMessage appendFormat:@"%@\n", er.localizedFailureReason];
    }
    
    [MPKMessage showNotificationInViewController:self title:@"Oops! Ocorreu um imprevisto..."
                                       subtitle:errorMessage
                                           type:MPKMessageNotificationTypeWarning
                                       duration:5.0f];
}

#pragma mark -
#pragma mark PKViewDelegate
- (void)paymentViewWithCard:(MPKCreditCard *)card isValid:(BOOL)valid
{
    isValidCreditCard = valid;
    _card = card;
}

#pragma mark -
#pragma mark Fields Validations
- (BOOL) allFieldsAreValid
{
    BOOL allValid = YES;
    
    if (self.txtCardHolder.text.length <= 5)
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtCardHolder];
    }
    
    if (self.txtFullname.text.length < 5)
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtFullname];
    }
    
    if (self.txtDocument.text.length != self.cpfMask.length)
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtDocument];
    }
    
    if (self.txtBirthDate.text.length < 10)
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtBirthDate];
    }

    if (self.txtPhone.text.length < (self.phoneMask.length - 1))
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtPhone];
    }

    if (!isValidCreditCard)
    {
        allValid = NO;
    }
    
    return allValid;
}

- (void) invalidAlerTextField:(UITextField *)txtField
{
    NSDictionary *attrs = @{NSForegroundColorAttributeName: RGB(255.0f, 91.0f, 91.0f, 0.9f)};
    
    txtField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:txtField.placeholder
                                                                     attributes:attrs];
}

- (NSString *) removeInvalidCharacters:(UITextField *)textField
{
    return [self.regex stringByReplacingMatchesInString:textField.text
                                                options:0
                                                  range:NSMakeRange(0, textField.text.length)
                                           withTemplate:@""];
    
}

#pragma mark -
#pragma mark View Animations
- (void) showLoadingView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.view addSubview:self.loadingView];
    [UIView animateWithDuration:0.35f animations:^{
        self.loadingView.alpha = 1;
    }];
}

- (void) hideLoadingView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [UIView animateWithDuration:0.3f animations:^{
        self.loadingView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.loadingView removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark Text Field
- (void)formatInput:(UITextField*)aTextField string:(NSString*)aString range:(NSRange)aRange
{
    NSString *value = aTextField.text;
    NSString *formattedValue = value;
    
    aRange.length = 1;
    NSString *textMask = @"";
    if (aTextField.tag == MPKTextFieldTagCPF)
        textMask = self.cpfMask;
    else if (aTextField.tag == MPKTextFieldTagPhoneNumber)
        textMask = self.phoneMask;
    else if (aTextField.tag == MPKTextFieldTagExpirationDate)
        textMask = self.expirationDateMask;
    else if (aTextField.tag == MPKTextFieldTagBirthdate)
        textMask = self.birthdateMask;
    
    NSString *_mask = [textMask substringWithRange:aRange];
    if (_mask != nil)
    {
        NSString *regex = @"[0-9]*";
        NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (! [regextest evaluateWithObject:_mask])
        {
            formattedValue = [formattedValue stringByAppendingString:_mask];
        }
        
        if (aRange.location + 1 < textMask.length)
        {
            _mask =  [textMask substringWithRange:NSMakeRange(aRange.location + 1, 1)];
            if([_mask isEqualToString:@" "])
            {
                formattedValue = [formattedValue stringByAppendingString:_mask];
            }
        }
    }

    formattedValue = [formattedValue stringByAppendingString:aString];
    aTextField.text = formattedValue;
}

- (BOOL) canEditTextField:(MPKTextFieldTag)tag inputString:(NSString *)string
{
    if (tag == MPKTextFieldTagPhoneNumber)
    {
        if (self.txtPhone.text.length == self.phoneMask.length)
        {
            return [string isEqualToString:@""];
        }
    }
    else if (tag == MPKTextFieldTagCPF)
    {
        if (self.txtDocument.text.length == self.cpfMask.length)
        {
            return [string isEqualToString:@""];
        }
    }
    else if (tag == MPKTextFieldTagBirthdate)
    {
        if (self.txtBirthDate.text.length == self.birthdateMask.length)
        {
            return [string isEqualToString:@""];
        }
    }
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == MPKTextFieldTagHolder)
    {
        self.txtFullname.text = textField.text;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == MPKTextFieldTagCPF ||
        textField.tag == MPKTextFieldTagPhoneNumber ||
        textField.tag == MPKTextFieldTagExpirationDate ||
        textField.tag == MPKTextFieldTagBirthdate)
    {
        if (![self canEditTextField:textField.tag inputString:string])
        {
            return NO;
        }
        else if (textField.text.length || range.location == 0)
        {
            if (string)
            {
                if(![string isEqualToString:@""])
                {
                    [self formatInput:textField string:string range:range];
                    return NO;
                }
                return YES;
            }
            return YES;
        }
    }
    
    return YES;
}

- (BOOL)disablesAutomaticKeyboardDismissal { return NO; }

@end