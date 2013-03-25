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
	double x,y,t;
}

@end

#define BALL_SIZE 20
#define TRAY_SIZE_X 80
#define TRAY_SIZE_Y 20

#define TIME 0.005

@implementation ViewController

// Create Section

// !!!: KULKA
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

- (void)moveBall
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.005];
	[UIView setAnimationDelegate:self];
	
	//CGPoint ballPosition = CGPointMake(ball.frame.origin.x, ball.frame.origin.y);
	CGPoint ballPosition = CGPointMake(ball.center.x, ball.center.y);
	CGPoint buffor;
	buffor = ballPosition;
	
	buffor.x += x;
	buffor.y += y;
	
	//NSLog(@"y: %g", y);
	//NSLog(@"buffor: %@ : %@", [NSNumber numberWithFloat:buffor.x], [NSNumber numberWithFloat:buffor.y]);
		
	if ([self przeszkoda:buffor])
	{
		[self sciana:buffor];
		[self performSelector:@selector(moveBall) withObject:nil afterDelay:TIME];
	}
	else
	{
		ball.center = buffor;
		[self performSelector:@selector(moveBall) withObject:nil afterDelay:TIME];
	}
	
	[UIView commitAnimations];
}

- (BOOL)przeszkoda:(CGPoint)point
{
	if (x != 0 || y != 0)
	{
		if (point.x /*+ BALL_SIZE/2*/ >= self.view.bounds.size.width ||point.x /*- BALL_SIZE/2*/ <= 0) return YES;
		else if (point.y /*+ BALL_SIZE/2*/ >= self.view.bounds.size.height || point.y /*- BALL_SIZE/2*/ <= 0) return YES;
		else return NO;
	}
	return YES;
}

- (void)sciana:(CGPoint)point
{
	if (point.y >= self.view.bounds.size.height || point.y <= 0) // Dolna ściana && Górna ściana
	{
		if (point.y <= 0)
		{
			//x = x;
			y = -y;
		}
		else
		{
			y = -y;
			NSLog(@"Dolna Ściana...");
		}
	}
	else if (point.x >= self.view.bounds.size.width || point.x <= 0) // Prawa ściana && Lewa ściana
	{
		x = -x;
		//y = y;
	}

}

// !!!: TACKA
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
	CGPoint trayPosition = CGPointMake(tray.frame.origin.x, tray.center.y);
	
	trayPosition.x += translation.x;
	if (trayPosition.x <= 0)
	{
		trayPosition.x = 0;
		NSLog(@"Lewa ściana.");
	}
	else if (trayPosition.x >= self.view.frame.size.width - TRAY_SIZE_X)
	{
		trayPosition.x = self.view.frame.size.width - TRAY_SIZE_X;
		NSLog(@"Prawa ściana.");
	}
	
	tray.center = CGPointMake(trayPosition.x + TRAY_SIZE_X/2, trayPosition.y);
	//NSLog(@"Pozycja Tacki: %@", [NSNumber numberWithFloat:temp.x]);
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
	NSLog(@"reFlexio!");
	
	// Inicjalizacja
	[self createBall];
	[self createTray];
	// -------------
	
	// DEBUG
	//[self gameOver];
	x = 0;
	y = 1;
	t = TIME;
	[self moveBall];
	// -----
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
