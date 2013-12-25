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
	UIView *ball, *tray, *brick, *gameField;
	//IBOutlet UIView *gameField;
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
#define BALL_SQUARE BALL_SIZE/2

#define TRAY_SIZE_X 80 // 80
#define TRAY_SIZE_Y 20

#define BRICK_SIZE_X 50 // 50
#define BRICK_SIZE_Y 20 // 20

#define SPEED 0.005
#define REMOVE_TIME 0.01


// Podział tacki na części, użyte w wybieraniu konta odbicia.
#define SEKCJA1 TRAY_SIZE_X * 0.2 // 20%
#define SEKCJA2 TRAY_SIZE_X * 0.2 // 20%


@implementation ViewController


- (void)createGameField
{
	CGRect gameFieldRect = CGRectMake(0, 40, 320, 528);
	gameField = [[UIView alloc] initWithFrame:gameFieldRect];
	gameField.backgroundColor = [UIColor clearColor];
	[self.view addSubview:gameField];
}
// !!!: KULKA
- (void)createBall
{
	NSLog(@"I'm creating a Ball...");
	
	CGRect ballFrame = CGRectMake(gameField.center.x - BALL_SIZE/2,
								  gameField.center.y - BALL_SIZE/2,
								  BALL_SIZE,
								  BALL_SIZE);
	
	ball = [[BallView alloc] initWithFrame:ballFrame];
	ball.opaque = NO;
	[gameField addSubview:ball];
}
- (void)moveBall
{
	if (play)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:SPEED];
		[UIView setAnimationDelegate:self];
		
		CGPoint ballPosition = CGPointMake(ball.center.x, ball.center.y);
		CGPoint buffor;
		buffor = ballPosition;
		
		buffor.x += x;
		buffor.y += y;
		
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
			if (ballPoint.x >= gameField.bounds.size.width || ballPoint.x <= 0) return YES;
			else if (ballPoint.y >= tray.frame.origin.y || ballPoint.y <= 0) return YES;
			else
			{
				for (int i = 0; i < bricksArray.count; i++)
				{
					[self sprawdzKtoraToKostka:i];
					
					if (ballPoint.x + BALL_SQUARE >= brickPoint_begin.x &&
						ballPoint.x + BALL_SQUARE <= brickPoint_end.x)
					{
						//NSLog(@"Przestrzen kostki X");
						if (ballPoint.y + BALL_SQUARE >= brickPoint_begin.y &&
							ballPoint.y + BALL_SQUARE <= brickPoint_end.y)
						{
							//NSLog(@"Przestrzen kostki Y");
							return YES;
						}
						return NO;
					}
					else return NO;
				}
				return NO;
			}
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
	else if (point.x >= gameField.bounds.size.width  || point.x <= 0) // Prawa ściana && Lewa ściana
	{
		x = -x;
	}
	else // Kostka
	{
		[self kostka:point];
	}
	
}


// !!!: TACKA
- (void)createTray
{
	NSLog(@"I'm creating a Tray...");
	CGRect trayFrame = CGRectMake(gameField.center.x - TRAY_SIZE_X/2,
								  gameField.bounds.size.height - TRAY_SIZE_Y-20,
								  TRAY_SIZE_X,
								  TRAY_SIZE_Y);
	
	tray = [[TrayView alloc] initWithFrame:trayFrame];
	tray.opaque = NO;
	[gameField addSubview:tray];
	
	// gest
	UIPanGestureRecognizer *moveTrayGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTray:)];
    [tray addGestureRecognizer:moveTrayGesture];
}
- (void)moveTray:(UIPanGestureRecognizer *)move
{
	CGPoint translation = [move translationInView:gameField];
	CGPoint trayPosition = CGPointMake(tray.frame.origin.x, tray.center.y);
	
	trayPosition.x += translation.x;
	if (trayPosition.x <= 0)
	{
		trayPosition.x = 0;
	}
	else if (trayPosition.x >= gameField.frame.size.width - TRAY_SIZE_X)
	{
		trayPosition.x = gameField.frame.size.width - TRAY_SIZE_X;
	}
	
	tray.center = CGPointMake(trayPosition.x + TRAY_SIZE_X/2, trayPosition.y);
	[move setTranslation:CGPointZero inView:gameField];
}

// !!!: KOSTKA
- (void)createBrick
{
	NSLog(@"I'm creating a Brick...");
	CGRect brickFrame = CGRectMake(gameField.center.x - BRICK_SIZE_X/2,
								  gameField.center.y - 100,
								  BRICK_SIZE_X,
								  BRICK_SIZE_Y);
	
	brick = [[BrickView alloc] initWithFrame:brickFrame];
	[bricksArray addObject:brick];
	
	brick.opaque = NO;
	[gameField addSubview:brick];
}

- (void)createBrick2
{
	NSLog(@"I'm creating a Brick2...");
	
	CGRect brickFrame = CGRectMake(gameField.center.x - BRICK_SIZE_X/2 + 50,
								   gameField.center.y - 200,
								   BRICK_SIZE_X,
								   BRICK_SIZE_Y);
	
	
	brick = [[BrickView alloc] initWithFrame:brickFrame];
	[bricksArray addObject:brick];
	
	brick.opaque = NO;
	[gameField addSubview:brick];
}

- (void)kostka:(CGPoint)ballPoint
{
	for (int i = 0; i < bricksArray.count; i++)
	{
		[self sprawdzKtoraToKostka:i];
		
		if (ballPoint.x + BALL_SQUARE >= brickPoint_begin.x &&
			ballPoint.x + BALL_SQUARE <= brickPoint_end.x)
		{
			if (ballPoint.y + BALL_SQUARE >= brickPoint_begin.y &&
				ballPoint.y + BALL_SQUARE <= brickPoint_end.y) // Góra/Dół
			{
				[self zniszczKostke:i];
				y = -y;
				
				if (ballPoint.x + BALL_SQUARE <= brickPoint_begin.x ||
					ballPoint.x + BALL_SQUARE >= brickPoint_end.x) // Lewa/Prawa
				{
					[self zniszczKostke:i];
					x = -x;
					y = -y;
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
	//[self.view bringSubviewToFront:backgroundView]; // Żeby kulka się chowała podspodem.
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
	backgroundView.hidden = YES;
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
	[self createGameField];
	[self createBall];
	[self createTray];
	[self createBrick];
	[self createBrick2];
	[self reset];
	// -------------
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
