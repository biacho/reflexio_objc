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
	//IBOutlet UIView *backgroundView;
	UIView *ball, *tray, *gameField, *leftSideScreen;
	//IBOutlet UIView *gameField;
	NSMutableDictionary *bricksDictionary;
	NSMutableArray *bricksViewArray;
	CGPoint brickPoint_begin;
	CGPoint brickPoint_end;
	IBOutlet UILabel *scoreLabel;
	IBOutlet UILabel *lifeLabel;
	IBOutlet UILabel *countDownLabel;
	BOOL hole;
	int score, life, countTime;
	double x,y;
	BOOL play, show;
}
@end

#define BALL_SIZE 20
#define BALL_SQUARE BALL_SIZE/2

#define TRAY_SIZE_X 80
#define TRAY_SIZE_Y 20

#define BRICK_SIZE_X 50 // 50
#define BRICK_SIZE_Y 20 // 20

#define SPEED 0.005
#define REMOVE_TIME 0.01

// Podział tacki na części, użyte w wybieraniu konta odbicia.
#define SEKCJA1 TRAY_SIZE_X * 0.2 // 20%
#define SEKCJA2 TRAY_SIZE_X * 0.2 // 20%


@implementation ViewController

// !!!: Buttons
- (IBAction)startPlayButton:(UIButton *)sender
{
	NSLog(@"Naciśnięty :>");
	//[self start];
	//[sender setHidden:YES];
}


// !!!: GameField
- (void)createGameField
{
	CGRect gameFieldRect = CGRectMake(0, 40, 320, 528);
	gameField = [[UIView alloc] initWithFrame:gameFieldRect];
	gameField.backgroundColor = [UIColor clearColor];
	[self.view addSubview:gameField];
	[self updateLabels];
}

- (void)updateLabels
{
	lifeLabel.text = [NSString stringWithFormat:@"Życie: %i", life];
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
			if (hole) // Żeby piłeczka nie przyśpieszała przy restartcie.
			{
				NSLog(@"Miss...");
				hole = NO;
			}
			else
			{
				//NSLog(@"Przeszkoda");
				[self sciana:buffor];
				[self performSelector:@selector(moveBall) withObject:nil afterDelay:SPEED];
			}
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
			if (ballPoint.x  >= gameField.bounds.size.width || ballPoint.x  <= 0) return YES;
			else if (ballPoint.y  >= tray.frame.origin.y || ballPoint.y  <= 0) return YES;
			else if (bricksDictionary.count == 0) return NO;
			else
			{
				/*
				for (int i = 0; i < bricksDictionary.count; i++)
				{
				*/
					[self sprawdzKtoraToKostka:ballPoint];
					
					if (ballPoint.x >= brickPoint_begin.x &&
						ballPoint.x <= brickPoint_end.x)
					{
						if (ballPoint.y  >= brickPoint_begin.y &&
							ballPoint.y  <= brickPoint_end.y)
						{
							return YES;
						}
						return NO;
					}
				/*
					else return NO;
				}
				*/
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
		NSLog(@"Kostka");
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
	CGRect brickFrame = CGRectMake(gameField.center.x - BRICK_SIZE_X/2 ,
								  gameField.center.y - 100,
								  BRICK_SIZE_X,
								  BRICK_SIZE_Y);
	
	UIView *brick = [[BrickView alloc] initWithFrame:brickFrame];
	
	double bx = brickFrame.origin.x ;//- BRICK_SIZE_X/2;
	double by = brickFrame.origin.y;// - BRICK_SIZE_Y/2;
	double ex = brickFrame.origin.x + BRICK_SIZE_X;
	double ey = brickFrame.origin.y + BRICK_SIZE_Y;
	
	NSMutableDictionary *brick_Dic = [NSMutableDictionary dictionary];
	[brick_Dic setObject:[NSNumber numberWithDouble:bx] forKey:@"begin_x"];
	[brick_Dic setObject:[NSNumber numberWithDouble:by] forKey:@"begin_y"];
	[brick_Dic setObject:[NSNumber numberWithDouble:ex] forKey:@"end_x"];
	[brick_Dic setObject:[NSNumber numberWithDouble:ey] forKey:@"end_y"];

	//NSLog(@"%@", brick_Dic);
	
	[bricksDictionary setObject:brick_Dic forKey:@"brick1"];
	[bricksViewArray addObject:brick];
	brick.opaque = NO;
	[gameField addSubview:brick];
	NSLog(@"bricksDictionary : %@", bricksDictionary);

}

- (void)createBrick2
{
	NSLog(@"I'm creating a Brick 2...");
	
	CGRect brickFrame = CGRectMake(gameField.center.x - BRICK_SIZE_X/2 + 20,
								   gameField.center.y - 200,
								   BRICK_SIZE_X,
								   BRICK_SIZE_Y);
	
	
	UIView *brick = [[BrickView alloc] initWithFrame:brickFrame];
	double bx = brickFrame.origin.x - BRICK_SIZE_X/2;
	double by = brickFrame.origin.y - BRICK_SIZE_Y/2;
	double ex = brickFrame.origin.x + BRICK_SIZE_X/2;
	double ey = brickFrame.origin.y + BRICK_SIZE_Y/2;
	
	NSMutableDictionary *brick_Dic = [NSMutableDictionary dictionary];
	[brick_Dic setObject:[NSNumber numberWithDouble:bx] forKey:@"begin_x"];
	[brick_Dic setObject:[NSNumber numberWithDouble:by] forKey:@"begin_y"];
	[brick_Dic setObject:[NSNumber numberWithDouble:ex] forKey:@"end_x"];
	[brick_Dic setObject:[NSNumber numberWithDouble:ey] forKey:@"end_y"];
	
	//NSLog(@"%@", brick_Dic);
	
	[bricksDictionary setObject:brick_Dic forKey:@"brick2"];
	
	//[bricksDictionary addObject:brick];
	
	brick.opaque = NO;
	[gameField addSubview:brick];
	NSLog(@"bricksDictionary : %@", bricksDictionary);

}

- (void)kostka:(CGPoint)ballPoint
{
	NSLog(@"Inside Kostka");
	
	if (ballPoint.x  >= brickPoint_begin.x || ballPoint.x >= brickPoint_end.x) // Lewa/Prawa
	{
		[self zniszczKostke:@"brick1"];
		if (ballPoint.y <= brickPoint_begin.y || ballPoint.y >= brickPoint_end.y)
		{
			y = -y;
		}
		else
		{
			x = -x;
		}
	}
}
- (void)sprawdzKtoraToKostka:(CGPoint)ballPoint
{
	//NSLog(@"kostka %i", i);
	
	double bx = [[[bricksDictionary objectForKey:@"brick1"] objectForKey:@"begin_x"] doubleValue];
	double by = [[[bricksDictionary objectForKey:@"brick1"] objectForKey:@"begin_y"] doubleValue];
	double ex = [[[bricksDictionary objectForKey:@"brick1"] objectForKey:@"end_x"] doubleValue];
	double ey = [[[bricksDictionary objectForKey:@"brick1"] objectForKey:@"end_y"] doubleValue];
	
	
	if (ballPoint.x  >= bx &&
		ballPoint.x  <= ex)
	{
		if (ballPoint.y  >= by &&
			ballPoint.y  <= ey)
		{
			NSLog(@"+");
			brickPoint_begin = CGPointMake(bx, by);
			brickPoint_end = CGPointMake(ex, ey);
		}
	}
	/*
	else if (ballPoint.x - BALL_SQUARE >= bx && ballPoint.x  - BALL_SQUARE<= ex)
	{
		if (ballPoint.y - BALL_SQUARE >= by && ballPoint.y -BALL_SQUARE <= ey)
		{
			NSLog(@"-");
			brickPoint_begin = CGPointMake(bx, by);
			brickPoint_end = CGPointMake(ex, ey);
		}
	}
	*/
	//UIView *brickViewTemp = [bricksDictionary objectAtIndex:i];
	//CGPoint brickPoint = CGPointMake(brickViewTemp.center.x, brickViewTemp.center.y);
	//brickPoint_begin = CGPointMake(brickPoint.x - BRICK_SIZE_X/2, brickPoint.y - BRICK_SIZE_Y/2);
	//brickPoint_end = CGPointMake(brickPoint.x + BRICK_SIZE_X/2, brickPoint.y + BRICK_SIZE_Y/2);
}
- (void)zniszczKostke:(NSString*)index
{
	index = @"0"; // Tymczasowo
	
	
	UIView *brickTemp = [bricksViewArray objectAtIndex:[index doubleValue]];
	NSLog(@"brickTemp = %@", brickTemp);
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:REMOVE_TIME];
	brickTemp.alpha = 0.0;
	[UIView setAnimationDidStopSelector:@selector(wyczysc:)];
	[UIView commitAnimations];
	
}
- (void)wyczysc:(NSString*)index
{
	index = @"brick1";
	NSLog(@"index: %@", index);
	NSLog(@"bricksDictionary: %lu", bricksDictionary.count);
	[bricksDictionary removeObjectForKey:index];
	NSLog(@"bricksDictionary after remove: %@", bricksDictionary);
}

// Set Section
- (void)gameOver
{
	hole = YES;
	
	if (life == 0)
	{
		NSLog(@"Game Over!");
		play = NO;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationDelegate:self];
		x = 0;
		y = 0;
		[ball removeFromSuperview];
		[tray removeFromSuperview];
		[UIView commitAnimations];
	}
	else
	{
		--life;
		[self updateLabels];
		[self reset];
	}
}

- (IBAction)playAgain:(UIButton *)sender
{
	NSLog(@"Start New Game!");
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	[self reset];
	[UIView commitAnimations];
}
// ???: CZEMU TA PIERDOLONA PIŁECZKA PRZYŚPIESZA PO RESTARCIE !?
- (void)reset
{
	[ball removeFromSuperview];
	[tray removeFromSuperview];
	x = 0; // Zmiana kierunku piłeczki na pierwotny prostopadły w dół
	[self createBall];
	[self createTray];
	play = YES;
	[self moveBall];
}

- (void)start
{
	x = 0;
	y = 1;
	play = YES;
	[self moveBall];
}

- (void)countToStartAnimation
{
	if (countTime > 1)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationRepeatAutoreverses:YES];
		countDownLabel.alpha = 1;
		[UIView setAnimationDidStopSelector:@selector(countDownToStart)];
		[UIView commitAnimations];
	}
	else if (countTime == 1)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationRepeatAutoreverses:YES];
		countDownLabel.alpha = 1;
		[UIView setAnimationDidStopSelector:@selector(countDownToStart)];
		[UIView commitAnimations];
		[self initialization];
	}
	else
	{
		[self start];
	}
}

- (void)countDownToStart
{
	countDownLabel.alpha = 0;
	countTime = [countDownLabel.text intValue];
	countTime--;
	countDownLabel.text = [NSString stringWithFormat:@"%i", countTime];
	[self countToStartAnimation];
}

// TODO: Ustawić countDownLabel jako najwyżej w hierarchi, żeby kostka nie przykrywała 1 na ekranie.
- (void)initialization
{
	// Inicjalizacja
	bricksDictionary = [NSMutableDictionary dictionary];
	bricksViewArray = [NSMutableArray array];
	life = 2; // Ilość żyć
	countTime = [countDownLabel.text intValue];
	[self createGameField];
	[self createBall];
	[self createTray];
	[self createBrick];
	//[self createBrick2];
	// -------------

}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self countDownToStart];
}

// TODO: Wysuwanie się menu. Jak na razie jest ono dodane i działa. Trzeba zrobić UIView animation dla wysuwania się w momencie kiedy będzie PAUSA, albo GAME OVER.
- (void)viewDidLoad
{
    [super viewDidLoad];
	leftSideScreen = [[UIView alloc] init];
	NSLog(@"Pozycja lewego menu: %f", leftSideScreen.frame.origin.x);
	
	// Do any additional setup after loading the view, typically from a nib.
	NSLog(@"reFlexio!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
