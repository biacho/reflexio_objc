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
#import "BrickView.h"

@interface ViewController ()
{
	IBOutlet UIView *backgroundView;
	UIView *ball, *tray, *brick;
	NSMutableArray *bricksArray;
	CGPoint brickPoint_begin;
	CGPoint brickPoint_end;
	IBOutlet UILabel *scoreLabel;
	int score;
	double x,y;
	BOOL play;
}

- (IBAction)playAgain:(UIButton *)sender;

@end

#define BALL_SIZE 20

#define TRAY_SIZE_X 320 // 80
#define TRAY_SIZE_Y 20

#define BRICK_SIZE_X 150 // 50
#define BRICK_SIZE_Y 100

#define SPEED 0.005
#define REMOVE_TIME 0.01


// Podział tacki na części, użyte w wybieraniu konta odbicia.
#define SEKCJA1 TRAY_SIZE_X * 0.2 // 20%
#define SEKCJA2 TRAY_SIZE_X * 0.2 // 20%


@implementation ViewController

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
	if (play)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:SPEED];
		[UIView setAnimationDelegate:self];
		
		//CGPoint ballPosition = CGPointMake(ball.frame.origin.x, ball.frame.origin.y);
		CGPoint ballPosition = CGPointMake(ball.center.x, ball.center.y);
		CGPoint buffor;
		buffor = ballPosition;
		
		buffor.x += x;
		buffor.y += y;
		
		//NSLog(@"y: %g", y);
		//NSLog(@"ball y = %@", [NSNumber numberWithFloat:ball.center.y]);
		
		if ([self przeszkoda:buffor])
		{
			[self sciana:buffor];
			[self performSelector:@selector(moveBall) withObject:nil afterDelay:SPEED];
		}
		else
		{
			ball.center = buffor;
			[self performSelector:@selector(moveBall) withObject:nil afterDelay:SPEED];
		}
		
		[UIView commitAnimations];
	}
}
- (BOOL)przeszkoda:(CGPoint)ballPoint
{
	if (x != 0 || y != 0)
	{
		// !!!: Zrobić pentle for dla całej tablicy
		[self sprawdzKtoraToKostka:0];
		
		if (ballPoint.x >= self.view.bounds.size.width || ballPoint.x <= 0) return YES;
		else if (ballPoint.y >= tray.frame.origin.y || ballPoint.y <= 0) return YES;
		else if (ballPoint.x >= brickPoint_begin.x && ballPoint.x <= brickPoint_end.x)
		{
			if (ballPoint.y >= brickPoint_begin.y && ballPoint.y <= brickPoint_end.y)
			{
				return YES;
			}
			return NO;
		}
		else return NO;
	}
	return YES;
}
- (void)sciana:(CGPoint)point
{
	if (point.y >= tray.frame.origin.y || point.y <= 0) // Dolna ściana/tacka && Górna ściana
	{
		if (point.y <= 0)
		{
			//x = x;
			y = -y;
		}
		else
		{
			NSLog(@"Dolna Ściana...");
			//NSLog(@"tray.frame.origin.x: %g",  tray.frame.origin.x);
			//NSLog(@"tray.frame.size.width: %g",  tray.frame.size.width);
			//NSLog(@"ball.center.x: %g", ball.center.x);
			
			
			if (ball.center.x > tray.frame.origin.x && ball.center.x < tray.frame.origin.x + TRAY_SIZE_X)
			{
				int znak = 1;
				int kierunek = 1;
				if (ball.center.x < tray.frame.origin.x + TRAY_SIZE_X/2 && x == 0) kierunek = -1;
				if (x < 0) znak= -1;
				
				if (ball.center.x < tray.frame.origin.x + SEKCJA1 ||
					tray.frame.origin.x + TRAY_SIZE_X - SEKCJA1 < ball.center.x)
				{
					NSLog(@"Sekcja 1.");
					x = kierunek * 3 * znak;
				}
				else if (ball.center.x < tray.frame.origin.x + SEKCJA1 + SEKCJA2 ||
						 tray.frame.origin.x + TRAY_SIZE_X - SEKCJA1 - SEKCJA2 < ball.center.x)
				{
					NSLog(@"Sekcja 2.");
					x = kierunek * 1 * znak;
				}
				else
				{
					NSLog(@"Sekcja 3.");
					x = kierunek * 0.5 * znak;
				}
				
				y = -y;
				score++;
				scoreLabel.text = [NSString stringWithFormat:@"Punkty: %i", score];
			}
			else
			{
				[self gameOver];
			}
			
		}
	}
	else if (point.x >= self.view.bounds.size.width || point.x <= 0) // Prawa ściana && Lewa ściana
	{
		x = -x;
		//y = y;
	}
	else // Kostka
	{
		[self kostka:point];
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
	}
	else if (trayPosition.x >= self.view.frame.size.width - TRAY_SIZE_X)
	{
		trayPosition.x = self.view.frame.size.width - TRAY_SIZE_X;
	}
	
	tray.center = CGPointMake(trayPosition.x + TRAY_SIZE_X/2, trayPosition.y);
	[move setTranslation:CGPointZero inView:self.view];
}

// !!!: KOSTKA
- (void)createBrick
{
	NSLog(@"I'm creating a Brick...");
	CGRect brickFrame = CGRectMake(self.view.center.x - BRICK_SIZE_X/2,
								  self.view.center.y - 100,
								  BRICK_SIZE_X,
								  BRICK_SIZE_Y);
	
	brick = [[BrickView alloc] initWithFrame:brickFrame];
	[bricksArray addObject:brick];
	
	brick.opaque = NO;
	[self.view addSubview:brick];
}


- (void)kostka:(CGPoint)ballPoint
{
	for (int i = 0; i < bricksArray.count; i++)
	{
		[self sprawdzKtoraToKostka:i];
		
		if (ballPoint.x >= brickPoint_begin.x && ballPoint.x <= brickPoint_end.x)
		{
			if (ballPoint.y >= brickPoint_begin.y && ballPoint.y <= brickPoint_end.y) // Góra/Dół
			{
				y = -y;
				[self zniszczKostke:i];
				
				if (ballPoint.x <= brickPoint_begin.x || ballPoint.x >= brickPoint_end.x) // Lewa/Prawa
				{
					x = -x;
					y = -y;
					[self zniszczKostke:i];
				}
			}
		}
	}
}
- (void)sprawdzKtoraToKostka:(int)i
{
	if (bricksArray.count >= 1)
	{
		UIView *brickViewTemp = [bricksArray objectAtIndex:i];
		CGPoint brickPoint = CGPointMake(brickViewTemp.center.x, brickViewTemp.center.y);
		brickPoint_begin = CGPointMake(brickPoint.x - BRICK_SIZE_X/2, brickPoint.y - BRICK_SIZE_Y/2);
		brickPoint_end = CGPointMake(brickPoint.x + BRICK_SIZE_X/2, brickPoint.y + BRICK_SIZE_Y/2);
	}
	else
	{
		brickPoint_begin = brickPoint_end = CGPointZero;
	}
}
- (void)zniszczKostke:(int)index
{
	UIView *brickTemp = [bricksArray objectAtIndex:index];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:REMOVE_TIME];
	brickTemp.alpha = 0.0;
	[UIView setAnimationDidStopSelector:@selector(wyczysc:)];
	[UIView commitAnimations];
	
}
- (void)wyczysc:(int)index
{
	NSLog(@"index: %i", index);
	NSLog(@"bricksArray: %i", bricksArray.count);
	[[bricksArray objectAtIndex:index] removeFromSuperview];
	[bricksArray removeObjectAtIndex:index];
	NSLog(@"bricksArray after remove: %@", bricksArray);
}

// Set Section
- (void)gameOver
{
	NSLog(@"Game Over!");
	play = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	backgroundView.hidden = NO;
	[self.view bringSubviewToFront:backgroundView]; // Żeby kulka się chowała podspodem.
	backgroundView.alpha = 1.0f;
	[ball removeFromSuperview];
	[tray removeFromSuperview];
	[UIView commitAnimations];

}

- (IBAction)playAgain:(UIButton *)sender
{
	NSLog(@"Start New Game!");
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3f];
	//[UIView setAnimationDelay:2];
	[UIView setAnimationDelegate:self];
	[self createBall];
	[self createTray];
	backgroundView.alpha = 0.0f;
	[self reset];
	backgroundView.hidden = NO;
	[UIView commitAnimations];
}

- (void)reset
{
	x = 0;
	y = 1;
	play = YES;
	[self moveBall];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	NSLog(@"reFlexio!");
	
	// Inicjalizacja
	bricksArray = [[NSMutableArray alloc] init];

	[self createBall];
	[self createTray];
	[self createBrick];
	[self reset];
	// -------------
	
	// DEBUG
	// -----
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
