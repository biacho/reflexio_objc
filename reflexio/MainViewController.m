//
//  MainViewController.m
//  reflexio
//
//  Created by Tobiasz Czelakowski on 19.01.2014.
//  Copyright (c) 2014 Tobiasz Czelakowski. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (IBAction)playButton:(UIButton *)sender
{
	NSLog(@"Play");
}
- (IBAction)settingsButton:(UIButton *)sender
{
	NSLog(@"Settings");
}
- (IBAction)aboutButton:(UIButton *)sender
{
	NSLog(@"About");
}


 
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
