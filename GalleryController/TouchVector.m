//
//  TouchVector.m
//  GalleryViewController
//
//  Created by Piotr Sokolski on 09-12-27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TouchVector.h"
#import "GalleryController.h"
const float minimum_distance = 5;

@interface TouchVector (Private)

-(SwipeDirection)directionFrom:(CGPoint)from to:(CGPoint)to;
-(CGFloat)distanceFrom:(CGPoint)from to:(CGPoint)to;

@end


@implementation TouchVector
@synthesize velocity, previousPosition, direction, initPosition;

-(id)initWithPosition:(CGPoint)position{
	if (self = [super init]){
		initPosition = position;
		previousPosition = initPosition;
		direction = SwipeDirectionUnknown;
	}
	return self;
}

-(void)addPostion:(CGPoint)position{
	if ([self distanceFrom:previousPosition to:position] < minimum_distance) {
		return;
	}
	
	if (direction != SwipeDirectionUnknown){
		if (direction != [self directionFrom:previousPosition to:position]){
			direction = SwipeDirectionUnknown;
		}
	}
	
	if(direction == SwipeDirectionUnknown) {
		if ([self directionFrom:initPosition to:position] == [self directionFrom:previousPosition to:position]) {
			direction = [self directionFrom:initPosition to:position];
		}
	}
	previousPosition = position;
}

-(SwipeDirection)directionFrom:(CGPoint)from to:(CGPoint)to{
	float distx = from.x - to.x;
	float disty = from.y - to.y;
	
	if (ABS(distx) > ABS(disty)){
		if (distx > 0){
			return SwipeDirectionRight;
		}else {
			return SwipeDirectionLeft;
		}
	}else {
		if (disty > 0) {
			return SwipeDirectionDown;
		}else {
			return SwipeDirectionUp;
		}

	}

}

-(CGFloat)distanceFrom:(CGPoint)from to:(CGPoint)to{
	return hypot(from.x - to.x, from.y-to.y);
}

-(CGFloat)getDistance{
	return [self distanceFrom:initPosition to:previousPosition];
}

@end
