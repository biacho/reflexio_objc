//
//  ViewController.m
//  reflexio
//
//  Created by Tobiasz Czelakowski on 20.03.2013.
//  Copyright (c) 2013 Tobiasz Czelakowski. All rights reserved.
//

#import "ViewController.h"
#import "BallView.h"
#import "TrayView.h"

@interface ViewController ()
{
	IBOutlet UIView *backgroundView;
	UIView *ball, *tray;
}

@end

#define BALL_SIZE 20
#define TRAY_SIZE_X 80
#define TRAY_SIZE_Y 20

@implementation ViewController

// Create Section
- (void)createBall
{
	// Tutaj będzie tworzona piłeczka.
	NSLog(@"I'm creating a Ball...");
	CGRect ballFrame = CGRectMake(self.view.center.x - BALL_SIZE/2,
								  self.view.center.y - BALL_SIZE/2,
								  BALL_SIZE,
								  BALL_SIZE);
	
	ball = [[BallView alloc] initWithFrame:ballFrame];
	ball.opaque = NO;
	[self.view addSubview:ball];
}
- (void)createTray
{
	// Tutaj będzie tworzona tacka.
	NSLog(@"I'm creating a Tray...");
	CGRect trayFrame = CGRectMake(self.view.center.x - TRAY_SIZE_X/2,
								  self.view.bounds.size.height - 50,
								  TRAY_SIZE_X,
								  TRAY_SIZE_Y);
	
	tray = [[TrayView alloc] initWithFrame:trayFrame];
	tray.opaque = NO;
	[self.view addSubview:tray];
	
	// gest
	UIPanGestureRecognizer *moveTrayGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTray:)];
    [tray addGestureRecognizer:moveTrayGesture];
}

- (void)moveTray:(UIPanGestureRecognizer *)move
{
	CGPoint translation = [move translationInView:self.view];
	CGPoint temp = CGPointMake(tray.frame.origin.x, tray.center.y);
	
	temp.x += translation.x;
	if (temp.x <= 0)
	{
		temp.x = 0;
		NSLog(@"Lewa ściana.");
	}
	else if (temp.x >= self.view.frame.size.width - TRAY_SIZE_X)
	{
		temp.x = self.view.frame.size.width - TRAY_SIZE_X;
		NSLog(@"Prawa ściana.");
	}
	
	tray.center = CGPointMake(temp.x + TRAY_SIZE_X/2, temp.y);
	NSLog(@"Pozycja Tacki: %@", [NSNumber numberWithFloat:temp.x]);
	[move setTranslation:CGPointZero inView:self.view];
}

// Set Section
- (void)gameOver
{
	NSLog(@"Game Over!");
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.7f];
	[UIView setAnimationDelegate:self];
	backgroundView.hidden = NO;
	[self.view bringSubviewToFront:backgroundView]; // Żeby kulka się chowała podspodem.
	backgroundView.alpha = 1.0f;
	[UIView commitAnimations];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	NSLog(@"WITAJ!");
	
	// Inicjalizacja
	[self createBall];
	[self createTray];
	// -------------
	
	// DEBUG
	//[self gameOver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
