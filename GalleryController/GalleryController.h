//
//  GalleryController.h
//  BigImageCoreData
//
//  Created by Piotr Sokolski on 09-12-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryScrollView.h"
#import <CoreGraphics/CoreGraphics.h>
typedef enum {
	GalleryControllerNavigationModeOther,
	GalleryControllerNavigationModeHorizontal,
	GalleryControllerNavigationModeVertical
} GalleryControllerNavigationMode;

@interface GalleryController : UIViewController <UIScrollViewDelegate> {
	GalleryControllerNavigationMode navigationMode;
	BOOL navigationModeInverted;
	
	UIView* currentView;
	NSMutableArray* nextViews;
	NSMutableArray* previousViews;
	
	NSUInteger viewsToKeep;
	NSUInteger viewsToPresent;
	NSInteger currentIndex;
	
	CGPoint currentPosition;
	
	GalleryScrollView* galleryScrollView;
	BOOL inverted;
}

@property(nonatomic, assign)NSUInteger viewsToKeep;
@property(nonatomic, assign)NSUInteger viewsToPresent;
@property(nonatomic, assign)NSInteger currentIndex;
@property(nonatomic, readonly)UIView* currentView;

-(UIView*)viewAtIndex:(NSInteger)index;

-(void)activateViewNext:(BOOL)next;

-(void)willActivateViewNext:(BOOL)isNext;
-(void)didActivateViewNext:(BOOL)wasNext;

-(void)setNavigationMode:(GalleryControllerNavigationMode)navMode inverted:(BOOL)isInverted;

@end
