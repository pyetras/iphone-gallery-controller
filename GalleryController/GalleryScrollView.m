//
//  GalleryScrollView.m
//  GalleryViewController
//
//  Created by Piotr Sokolski on 09-12-27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GalleryScrollView.h"
#import "GalleryController.h"
#import "TouchVector.h"
@interface GalleryScrollView (Private)

-(float)distance:(CGPoint)from to:(CGPoint)to;
@end


@implementation GalleryScrollView
@synthesize galleryController, horizontalScrollEnabled, verticalScrollEnabled;
-(id)init{
	if (self = [super init]){
		[self setShowsHorizontalScrollIndicator:NO];
		[self setShowsVerticalScrollIndicator:NO];
		
		self.decelerationRate = 0.1;

		self.scrollEnabled = NO;
		self.horizontalScrollEnabled = YES;
		self.verticalScrollEnabled = YES;
	}
	return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[galleryController touchesBegan:touches withEvent:event];
	if (!self.userInteractionEnabled) return;
	
	UITouch* touch = [touches anyObject];
	touchVector = [[TouchVector alloc] initWithPosition:[touch locationInView:[self superview]]];
	
//	NSUInteger half;
//	NSUInteger touchPos;
//	
//	half = self.frame.size.height/2;
//	touchPos = [touch locationInView:[self superview]].y;
//	if (touchPos > half) [galleryController swipe:SwipeDirectionDown];
//	else [galleryController swipe:SwipeDirectionUp]; 
//	
//	half = self.frame.size.width/2;
//	touchPos = [touch locationInView:[self superview]].x;
//	if (touchPos > half) [galleryController swipe:SwipeDirectionRight];
//	else [galleryController swipe:SwipeDirectionLeft]; 
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[galleryController touchesCancelled:touches withEvent:event];
	if (!self.userInteractionEnabled) return;
	[touchVector release];
	[galleryController swipeCancelled];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[galleryController touchesMoved:touches withEvent:event];
	if (!self.userInteractionEnabled) return;
	
	UITouch* touch = [touches anyObject];
	CGPoint from = [touch previousLocationInView:[self superview]];
	CGPoint to = [touch locationInView:[self superview]];
	if (touchVector.initPosition.x != touchVector.previousPosition.x || 
		touchVector.initPosition.y != touchVector.previousPosition.y)
		self.contentOffset = CGPointMake(self.contentOffset.x + ((horizontalScrollEnabled)?from.x-to.x:0), 
									 self.contentOffset.y + ((verticalScrollEnabled)?from.y-to.y:0));
	[touchVector addPostion:to];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[galleryController touchesEnded:touches withEvent:event];
	if (!self.userInteractionEnabled) return;
	
	UITouch* touch = [touches anyObject];

	CGPoint to = [touch locationInView:[self superview]];
	
	[touchVector addPostion:to];
	
	if (touchVector.direction != SwipeDirectionUnknown){
		[galleryController swipe:touchVector.direction];
	}else {
		[galleryController swipeCancelled];
	}

	[touchVector release];
}

-(float)distance:(CGPoint)from to:(CGPoint)to{
	return hypot(from.x - to.x, from.y-to.y);
}

@end
