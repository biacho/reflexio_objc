//
//  BrickView.m
//  reflexio
//
//  Created by Tobiasz Czelakowski on 26.03.2013.
//  Copyright (c) 2013 Tobiasz Czelakowski. All rights reserved.
//

#import "BrickView.h"

#define CORNER_RADIOUS 8.0f

@implementation BrickView

- (void)drawRect:(CGRect)rect
{
	UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds
														 cornerRadius:CORNER_RADIOUS];
	
	[roundRect addClip];
	
	[[UIColor greenColor] setFill];
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

@end
