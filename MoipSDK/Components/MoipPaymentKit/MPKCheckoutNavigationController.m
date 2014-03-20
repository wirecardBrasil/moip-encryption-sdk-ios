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

- (instancetype) initWithConfiguration:(MPKConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        self.viewControllers = @[[[MPKCheckoutViewController alloc] initWithConfiguration:configuration]];
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