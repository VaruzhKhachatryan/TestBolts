//
//  ViewController.m
//  BoltsTest
//
//  Created by Varuzhan Khachatryan on 10/15/15.
//  Copyright © 2015 Varuzhan Khachatryan. All rights reserved.
//

#import "ViewController.h"
#import "SCContactsSender.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SCContactsSender sharedInstance] sendFacebookContactsIfNeeded];
    [[SCContactsSender sharedInstance] sendTwitterContactsIfNeeded];
    [[SCContactsSender sharedInstance] sendInstagramContactsIfNeeded];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
