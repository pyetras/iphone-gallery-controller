//
//  GalleryScrollView.m
//  GalleryViewController
//
//	This class is a hack that passes touch events to GalleryController
//	It's the best (and simpliest) solution I've found so far

//  Created by Piotr Sokolski on 09-12-27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GalleryScrollView.h"
#import "GalleryController.h"
@interface GalleryScrollView (Private)
@end


@implementation GalleryScrollView
@synthesize galleryController, horizontalScrollEnabled, verticalScrollEnabled;
-(id)init{
	if (self = [super init]){
		[self setShowsHorizontalScrollIndicator:NO];
		[self setShowsVerticalScrollIndicator:NO];
		
		//self.decelerationRate = 0.1;

		self.scrollEnabled = YES;
		self.pagingEnabled = YES;
		self.horizontalScrollEnabled = YES;
		self.verticalScrollEnabled = YES;
		self.autoresizesSubviews = YES;
	}
	return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[galleryController touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[galleryController touchesCancelled:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[galleryController touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[galleryController touchesEnded:touches withEvent:event];
}

-(void)dealloc{
	[super dealloc];
}

@end
