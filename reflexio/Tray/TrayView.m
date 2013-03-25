//
//  TrayView.m
//  reflexio
//
//  Created by Tobiasz Czelakowski on 25.03.2013.
//  Copyright (c) 2013 Tobiasz Czelakowski. All rights reserved.
//

#import "TrayView.h"

#define CORNER_RADIOUS 8.0f

@implementation TrayView

- (void)drawRect:(CGRect)rect
{
	UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds
														 cornerRadius:CORNER_RADIOUS];
	
	[roundRect addClip];
	
	[[UIColor lightGrayColor] setFill];
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
