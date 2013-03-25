//
//  BallView.m
//  reflexio
//
//  Created by Tobiasz Czelakowski on 25.03.2013.
//  Copyright (c) 2013 Tobiasz Czelakowski. All rights reserved.
//

#import "BallView.h"

#define CORNER_RADIUS

@implementation BallView

- (void)drawRect:(CGRect)rect
{
	UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds
														 cornerRadius:self.frame.size.height/2];
	
	[roundRect addClip];
	
	[[UIColor redColor] setFill];
	UIRectFill(self.bounds);
	
	[[UIColor blackColor] setStroke];
	[roundRect stroke];
}

// Settery
- (void)setSize:(int)size
{
	_size = size;
}
// -------


- (void)setup
{
	NSLog(@"Promien: %f", self.frame.size.height/2);
}

- (void)awakeFromNib
{
	[self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	[self setup];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
