//
//  MPKCheckoutNavigationController.m
//  SkateStore
//
//  Created by Fernando Nazario Sousa on 19/03/14.
//  Copyright (c) 2014 ThinkMob. All rights reserved.
//

#import "MPKCheckoutNavigationController.h"
#import "MPKCheckoutViewController.h"
#import "MPKConfiguration.h"

@interface MPKCheckoutNavigationController ()

@end

@implementation MPKCheckoutNavigationController

- (instancetype) initWithOrderId:(NSString *)moipOrderId
                installmentCount:(NSInteger)installmentCount
                   configuration:(MPKConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        MPKCheckoutViewController *viewController = [[MPKCheckoutViewController alloc] initWithConfiguration:configuration];
        viewController.authorization = configuration.authorization;
        viewController.publicKey = configuration.publicKey;
        viewController.installmentCount = installmentCount;
        viewController.moipOrderId = moipOrderId;
        self.viewControllers = @[viewController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
