//
//  MPKCheckoutViewController.m
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 ThinkMob. All rights reserved.
//

#import "MPKCheckoutViewController.h"
#import "MPKConfiguration.h"
#import "MPKCreditCardTextField.h"
#import "MPKCVCTextField.h"
#import "MPKUtilities.h"

@interface MPKCheckoutViewController ()

@property MPKConfiguration *configs;
@property NSString* phoneMask;
@property NSString* cpfMask;
@property NSRegularExpression *regex;

@property (strong, nonatomic) UITextField *txtCardHolder;
@property (strong, nonatomic) MPKCreditCardTextField *txtCreditCard;
@property (strong, nonatomic) UIImageView *imgViewCardLogo;
@property (strong, nonatomic) UIImageView *imgViewCVC;
@property (strong, nonatomic) MPKCVCTextField *txtCVC;
@property (strong, nonatomic) UITextField *txtDate;
@property (strong, nonatomic) UITextField *txtFullname;
@property (strong, nonatomic) UITextField *txtDocument;
@property (strong, nonatomic) UITextField *txtPhone;
@property (strong, nonatomic) UITextField *txtBirthDate;
@property (strong, nonatomic) UIView *viewDatePicker;
@property (strong, nonatomic) UIDatePicker *datePickerBirthDate;
@property (strong, nonatomic) UIView *viewPicker;
@property (strong, nonatomic) UIPickerView *pkrValidation;
@property (strong, nonatomic) UIToolbar *toolbarPicker;
@property (strong, nonatomic) UIToolbar *toolbarDatePicker;
@property (strong, nonatomic) UITableView *tableViewForm;
@property (strong, nonatomic) UIView *loadingView;

@end

@implementation MPKCheckoutViewController

- (instancetype) initWithConfiguration:(MPKConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        [MPKUtilities importPublicKey:configuration.publicKey];
        
        self.configs = configuration;
        self.regex = [NSRegularExpression regularExpressionWithPattern:@"[,\\.\\-\\(\\)\\ `\"]" options:0 error:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.configs.titleView;
    self.view.backgroundColor = self.configs.viewBackgroundColor;
    self.phoneMask = @"(99) 999999999";
    self.cpfMask = @"999.999.999-99";
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(btnCancelTouched:)];
    self.navigationItem.rightBarButtonItem = btnCancel;
    
    self.tableViewForm = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    self.tableViewForm.allowsSelection = NO;
    self.tableViewForm.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableViewForm.delegate = self;
    self.tableViewForm.dataSource = self;
    [self.view addSubview:self.tableViewForm];
    [self.tableViewForm setContentInset:UIEdgeInsetsMake(0, 0, 300, 0)];
    
    // Form
    self.txtCardHolder = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 282, 55)];
    self.txtCardHolder.borderStyle = UITextBorderStyleNone;
    self.txtCardHolder.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.txtCardHolder.tag = MPKTextFieldTagHolder;
    self.txtCardHolder.placeholder = @"Nome (como no cartão)";
    self.txtCardHolder.font = self.configs.textFieldFont;
    self.txtCardHolder.delegate = self;
    
    self.txtCreditCard = [[MPKCreditCardTextField alloc] initWithFrame:CGRectMake(20, 0, 240, 55)];
    self.txtCreditCard.borderStyle = UITextBorderStyleNone;
    self.txtCreditCard.keyboardType = UIKeyboardTypeNumberPad;
    self.txtCreditCard.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtCreditCard.delegate = self;
    self.txtCreditCard.tag = MPKTextFieldTagCreditCard;
    self.txtCreditCard.placeholder = @"Número do Cartão";
    self.txtCardHolder.font = self.configs.textFieldFont;
    
    self.imgViewCardLogo = [[UIImageView alloc] initWithFrame:CGRectMake(270, 18, 32, 19)];
    self.imgViewCardLogo.image = self.txtCreditCard.cardLogo;
    
    self.txtCVC = [[MPKCVCTextField alloc] initWithFrame:CGRectMake(20, 0, 70, 55)];
    self.txtCVC.delegate = self;
    self.txtCVC.borderStyle = UITextBorderStyleNone;
    self.txtCVC.keyboardType = UIKeyboardTypeNumberPad;
    self.txtCVC.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtCVC.placeholder = @"Cód.";
    self.txtCVC.font = self.configs.textFieldFont;
    self.txtCVC.tag = MPKTextFieldTagCVC;
    
    self.imgViewCVC = [[UIImageView alloc] initWithFrame:CGRectMake(94, 18, 32, 19)];
    self.imgViewCVC.image = [UIImage imageNamed:@"cvc.png"];
    
    self.txtDate = [[UITextField alloc] initWithFrame:CGRectMake(202, 0, 100, 55)];
    self.txtDate.borderStyle = UITextBorderStyleNone;
    self.txtDate.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtDate.delegate = self;
    self.txtDate.tag = MPKTextFieldTagExpireDate;
    self.txtDate.placeholder = @"MM/AA";
    self.txtDate.font = self.configs.textFieldFont;

    self.txtFullname = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 282, 55)];
    self.txtFullname.borderStyle = UITextBorderStyleNone;
    self.txtFullname.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.txtFullname.placeholder = @"Nome completo";
    self.txtFullname.font = self.configs.textFieldFont;
    self.txtFullname.delegate = self;
    self.txtFullname.tag = MPKTextFieldTagFullname;
    
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
    self.txtBirthDate.placeholder = @"Nascimento";
    self.txtBirthDate.font = self.configs.textFieldFont;
    self.txtBirthDate.delegate = self;
    self.txtBirthDate.tag = MPKTextFieldTagBirthdate;

    self.pkrValidation = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 0, 162)];
    self.pkrValidation.dataSource = self;
    self.pkrValidation.delegate = self;
    self.pkrValidation.showsSelectionIndicator = YES;
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *btnDonePicker = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDonePickerTouched:)];
    
    self.toolbarPicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.toolbarPicker.items = @[flexibleItem, btnDonePicker];

    self.viewPicker = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height + 10, self.view.frame.size.width, 162 + 44)];
    self.viewPicker.backgroundColor = [UIColor whiteColor];
    [self.viewPicker addSubview:self.toolbarPicker];
    [self.viewPicker addSubview:self.pkrValidation];
    
    [self.view addSubview:self.viewPicker];
    
    self.datePickerBirthDate = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 162)];
    self.datePickerBirthDate.datePickerMode = UIDatePickerModeDate;
    
    UIBarButtonItem *btnDoneDatePicker = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDoneDatePickerTouched:)];
    
    self.toolbarDatePicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.toolbarDatePicker.items = @[flexibleItem, btnDoneDatePicker];
    
    self.viewDatePicker = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height + 10, self.view.frame.size.width, 162 + 44)];
    self.viewDatePicker.backgroundColor = [UIColor whiteColor];
    [self.viewDatePicker addSubview:self.toolbarDatePicker];
    [self.viewDatePicker addSubview:self.datePickerBirthDate];
    
    [self.view addSubview:self.viewDatePicker];
    
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2) - (80/2),
                                                                (self.view.frame.size.height/2) - (80/2), 80, 80)];
    self.loadingView.backgroundColor = [UIColor clearColor];
    self.loadingView.alpha = 0;
    
    UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actIndicator.frame = CGRectMake(self.loadingView.frame.size.width/2 - 37/2, self.loadingView.frame.size.height/2 - 37/2, 37, 37);
    actIndicator.color = [UIColor whiteColor];
    [actIndicator startAnimating];
    
    UIView *loadingSubView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
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
            return 3;
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
    NSString *cellID = [NSString stringWithFormat:@"PaymentFormCellID_%i_%i", indexPath.section, indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        NSLog(@"Criou nova cell %@", cellID);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    else
    {
        NSLog(@"Reutilizou cell %@", cellID);
    }
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                [cell.contentView addSubview:self.txtCardHolder];
                break;
            case 1:
                [cell.contentView addSubview:self.txtCreditCard];
                [cell.contentView addSubview:self.imgViewCardLogo];
                break;
            case 2:
                [cell.contentView addSubview:self.txtCVC];
                [cell.contentView addSubview:self.imgViewCVC];
                [cell.contentView addSubview:self.txtDate];
                break;
                
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
        UIButton *btnPay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 55)];
        [btnPay setTitle:@"Pagar" forState:UIControlStateNormal];
        [btnPay addTarget:self action:@selector(btnPayTouched:) forControlEvents:UIControlEventTouchUpInside];
        [btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnPay.titleLabel.font = self.configs.textFieldFont;
        btnPay.backgroundColor = [UIColor blueColor];
        
        [cell addSubview:btnPay];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

#pragma mark -
#pragma mark Picker view
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 12;
    }
    else
    {
        return 10;
    }
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        row = row + 1;
        if (row < 10)
        {
            return [NSString stringWithFormat:@"0%li", (long)row];
        }
        else
        {
            return [NSString stringWithFormat:@"%li", (long)row];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"20%li", ((long)(row + 14))];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSUInteger mm = ([self.pkrValidation selectedRowInComponent:0] + 1);
    NSUInteger yy = ([self.pkrValidation selectedRowInComponent:1] + 14);
    
    NSString *m = [NSString stringWithFormat:@"%lu", (unsigned long)mm];
    if (mm < 10)
    {
        m = [NSString stringWithFormat:@"0%lu", (unsigned long)mm];
    }
    
    self.txtDate.text = [NSString stringWithFormat:@"%@/%lu", m, (unsigned long)yy];
}

#pragma mark -
#pragma mark Actions
- (void) btnPayTouched:(id)sender
{
    if ([self allFieldsAreValid])
    {
        [self showLoadingView];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth |   NSCalendarUnitYear fromDate:self.datePickerBirthDate.date];
        
        NSString *docNumber = [self document];
        NSString *phoneNumber = [self phoneNumber];
        NSString *birthdate = [NSString stringWithFormat:@"%i-%i-%i", components.year, components.month, components.day];
        
        MPKCardHolder *holder = [MPKCardHolder new];
        holder.fullname = self.txtFullname.text;
        holder.birthdate = birthdate;
        holder.documentType = MPKCardHolderDocumentTypeCPF;
        holder.documentNumber = docNumber;
        holder.phoneCountryCode = @"55";
        holder.phoneAreaCode = [phoneNumber substringToIndex:2];
        holder.phoneNumber = [phoneNumber substringFromIndex:2];


        MPKCreditCard *card = [MPKCreditCard new];
        card.expirationMonth = [[self.txtDate.text componentsSeparatedByString:@"/"][0] integerValue];
        card.expirationYear = [[self.txtDate.text componentsSeparatedByString:@"/"][1] integerValue];
        card.number = @"4903762433566341";
        card.cvv = self.txtCVC.text;
        card.cardholder = holder;
        
        MPKPayment *payment = [MPKPayment new];
        payment.moipOrderId = self.moipOrderId;
        payment.installmentCount = self.installmentCount;
        payment.method = MPKPaymentMethodCreditCard;
        payment.creditCard = card;
        
        MoipSDK *sdk = [[MoipSDK alloc] initWithAuthorization:self.authorization publicKey:self.publicKey];
        [sdk submitPayment:payment success:^(MPKPaymentTransaction *transaction) {
            NSLog(@"%i", transaction.status);
            [self hideLoadingView];
        } failure:^(NSArray *errorList) {
            [self hideLoadingView];
            NSLog(@"error: %@", errorList);
        }];
    }
}

- (void) btnCancelTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) btnDoneDatePickerTouched:(id) sender
{
    NSDate *selectedDate = self.datePickerBirthDate.date;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    
    self.txtBirthDate.text = [format stringFromDate:selectedDate];
    [self hideDatePickerView];
}

- (void) btnDonePickerTouched:(id)sender
{
    NSUInteger mm = ([self.pkrValidation selectedRowInComponent:0] + 1);
    NSUInteger yy = ([self.pkrValidation selectedRowInComponent:1] + 14);
    
    NSString *m = [NSString stringWithFormat:@"%lu", (unsigned long)mm];
    if (mm < 10)
    {
        m = [NSString stringWithFormat:@"0%lu", (unsigned long)mm];
    }
    
    self.txtDate.text = [NSString stringWithFormat:@"%@/%lu", m, (unsigned long)yy];
    
    [self hidePickerView];
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
    
    if (![((MPKCreditCardTextField *)self.txtCreditCard) isValidLuhn])
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtCreditCard];
    }
    
    if (![((MPKCVCTextField *)self.txtCVC) isValidLength])
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtCVC];
    }
    
    if (self.txtDate.text.length < 5)
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtDate];
    }
    
    if (self.txtDate.text.length < 5)
    {
        allValid = NO;
        [self invalidAlerTextField:self.txtDate];
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

    
    return allValid;
}

- (void) invalidAlerTextField:(UITextField *)txtField
{
    NSDictionary *attrs = @{NSForegroundColorAttributeName: RGB(255.0f, 91.0f, 91.0f, 0.9f)};
    
    txtField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:txtField.placeholder
                                                                     attributes:attrs];
}

- (NSString *) phoneNumber
{
    return [self.regex stringByReplacingMatchesInString:self.txtPhone.text
                                                options:0
                                                  range:NSMakeRange(0, self.txtPhone.text.length)
                                           withTemplate:@""];
    
}

- (NSString *) document
{
    return [self.regex stringByReplacingMatchesInString:self.txtDocument.text
                                                options:0
                                                  range:NSMakeRange(0, self.txtDocument.text.length)
                                           withTemplate:@""];
}

#pragma mark -
#pragma mark Methods Helper
- (NSString *) getMoipOrderId
{
    NSString *orderJSON = [self generateOrderJSON];
    NSString *url = APIURL(@"/orders");
    
    MoipHttpRequester *requester = [MoipHttpRequester requesterWithBasicAuthorization:self.authorization];
    MoipHttpResponse *response = [requester post:url payload:orderJSON params:nil delegate:nil];
    if (response.httpStatusCode == kHTTPStatusCodeCreated)
    {
        id order = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
        return order[@"id"];
    }
    else
    {
        id error = [NSJSONSerialization JSONObjectWithData:response.content options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", error);
    }
    return nil;
}

- (NSString *)generateOrderJSON
{
    NSMutableString *jsonOrder = [NSMutableString new];
    [jsonOrder appendFormat:@"{"];
    [jsonOrder appendFormat:@"  \"ownId\": \"id_proprio\","];
    [jsonOrder appendFormat:@"  \"amount\": {"];
    [jsonOrder appendFormat:@"    \"MPKCurrency\": \"BRL\""];
    [jsonOrder appendFormat:@"  },"];
    [jsonOrder appendFormat:@"  \"items\": ["];
    [jsonOrder appendFormat:@"    {"];
    [jsonOrder appendFormat:@"      \"product\": \"Bicicleta Specialized Tarmac 26 Shimano Alivio\","];
    [jsonOrder appendFormat:@"      \"quantity\": 1,"];
    [jsonOrder appendFormat:@"      \"detail\": \"uma linda bicicleta\","];
    [jsonOrder appendFormat:@"      \"price\": 10000"];
    [jsonOrder appendFormat:@"    }"];
    [jsonOrder appendFormat:@"  ],"];
    [jsonOrder appendFormat:@"  \"customer\": {"];
    [jsonOrder appendFormat:@"    \"ownId\": \"meu_id_de_cliente\","];
    [jsonOrder appendFormat:@"    \"fullname\": \"Jose Silva\","];
    [jsonOrder appendFormat:@"    \"email\": \"josedasilva@email.com\","];
    [jsonOrder appendFormat:@"    \"birthDate\": \"1988-12-30\","];
    [jsonOrder appendFormat:@"    \"taxDocument\": {"];
    [jsonOrder appendFormat:@"      \"type\": \"CPF\","];
    [jsonOrder appendFormat:@"      \"number\": \"22222222222\""];
    [jsonOrder appendFormat:@"    },"];
    [jsonOrder appendFormat:@"    \"phone\": {"];
    [jsonOrder appendFormat:@"      \"countryCode\": \"55\","];
    [jsonOrder appendFormat:@"      \"areaCode\": \"11\","];
    [jsonOrder appendFormat:@"      \"number\": \"66778899\""];
    [jsonOrder appendFormat:@"    },"];
    [jsonOrder appendFormat:@"    \"addresses\": ["];
    [jsonOrder appendFormat:@"      {"];
    [jsonOrder appendFormat:@"        \"type\": \"BILLING\","];
    [jsonOrder appendFormat:@"        \"street\": \"Avenida Faria Lima\","];
    [jsonOrder appendFormat:@"        \"streetNumber\": 2927,"];
    [jsonOrder appendFormat:@"        \"complement\": 8,"];
    [jsonOrder appendFormat:@"        \"district\": \"Itaim\","];
    [jsonOrder appendFormat:@"        \"city\": \"Sao Paulo\","];
    [jsonOrder appendFormat:@"        \"state\": \"SP\","];
    [jsonOrder appendFormat:@"        \"country\": \"BRA\","];
    [jsonOrder appendFormat:@"        \"zipCode\": \"01234000\""];
    [jsonOrder appendFormat:@"      }"];
    [jsonOrder appendFormat:@"    ]"];
    [jsonOrder appendFormat:@"  }"];
    [jsonOrder appendFormat:@"}"];
    
    return jsonOrder;
}

#pragma mark -
#pragma mark View Animations
- (void) showLoadingView
{
    [self.view addSubview:self.loadingView];
    [UIView animateWithDuration:0.2f animations:^{
        self.loadingView.alpha = 1;
    }];
}

- (void) hideLoadingView
{
    [UIView animateWithDuration:0.3f animations:^{
        self.loadingView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.loadingView removeFromSuperview];
    }];
}

- (void) showPickerView
{
    CGRect framePicker = self.viewPicker.frame;
    framePicker.origin.y = self.view.frame.size.height-framePicker.size.height;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.viewPicker.frame = framePicker;
    }];
}

- (void) hidePickerView
{
    CGRect framePicker = self.viewPicker.frame;
    framePicker.origin.y = self.view.frame.size.height+10;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.viewPicker.frame = framePicker;
    }];
}

- (void) showDatePickerView
{
    CGRect framePicker = self.viewDatePicker.frame;
    framePicker.origin.y = self.view.frame.size.height-framePicker.size.height;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.viewDatePicker.frame = framePicker;
    }];
}

- (void) hideDatePickerView
{
    CGRect framePicker = self.viewDatePicker.frame;
    framePicker.origin.y = self.view.frame.size.height+10;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.viewDatePicker.frame = framePicker;
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
    
    return YES;
}

- (void) hideKeyboardAndShowPicker:(id) sender
{
    [self.txtDate resignFirstResponder];
    [self showPickerView];
}

- (void) hideKeyboardAndShowDatePicker:(id) sender
{
    [self.txtBirthDate resignFirstResponder];
    [self showDatePickerView];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == MPKTextFieldTagExpireDate)
    {
        [self.txtCVC resignFirstResponder];
        [self performSelector:@selector(hideKeyboardAndShowPicker:) withObject:nil afterDelay:0.0001f];
    }
    
    if (textField.tag == MPKTextFieldTagBirthdate)
    {
        [self.txtDocument resignFirstResponder];
        [self performSelector:@selector(hideKeyboardAndShowDatePicker:) withObject:nil afterDelay:0.0001f];
    }
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
    if (textField.tag == MPKTextFieldTagCPF || textField.tag == MPKTextFieldTagPhoneNumber)
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
    
    if ([textField isKindOfClass:[MPKCreditCardTextField class]])
    {
        self.imgViewCardLogo.image = ((MPKCreditCardTextField *)textField).cardLogo;
    }

    return YES;
}

- (BOOL)disablesAutomaticKeyboardDismissal { return NO; }

@end
