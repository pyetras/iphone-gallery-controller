//
//  GalleryController.m
//  BigImageCoreData
//
//  Created by Piotr Sokolski on 09-12-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GalleryController.h"
#import "GalleryScrollView.h"
#import <UIKit/UIKit.h>

@interface GalleryController (PrivateMethods)

-(void)fillWithViews:(NSMutableArray**)viewArray backwards:(BOOL)isBackwards;
-(void)resetViewDimensions;
-(CGPoint)advanceCenter:(CGPoint)point by:(NSInteger)n;
-(void)drawViews;
-(CGPoint)endOfDrawViewsFrom:(NSEnumerator*)en startingAt:(CGPoint)point;
-(void)addGalleryContentSize;
-(void)trimViewArray:(NSMutableArray **)viewArray;
-(void)switchViewFrom:(NSMutableArray **)fromArray to:(NSMutableArray **)toArray back:(BOOL)back;
-(CGRect)positionToVisibleRect:(CGPoint)center;
-(void)scrollBackToCurrentView;

-(void)matchScrollPositionToPage;
@end


@implementation GalleryController
@synthesize viewsToKeep, viewsToPresent, currentIndex, currentView;

#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.currentIndex = 0;
		self.viewsToKeep = 1;
		self.viewsToPresent = 1;
		
		[self setNavigationMode:GalleryControllerNavigationModeHorizontal inverted:NO];
    }
    return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {	
	self.view = [[UIView alloc] init];
	self.view.autoresizesSubviews = YES;

	galleryScrollView = [[GalleryScrollView alloc] init];
	
	galleryScrollView.delegate = self;
	galleryScrollView.galleryController = self;	
	[self.view addSubview:galleryScrollView];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	currentView = [[self viewAtIndex:self.currentIndex] retain];
	[self fillWithViews:&previousViews backwards:YES];
	[self fillWithViews:&nextViews backwards:NO];
	
	[self resetViewDimensions];
	[self drawViews];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
#pragma mark -

#pragma mark GalleryController Views Memory Management

-(void)fillWithViews:(NSMutableArray **)viewArray backwards:(BOOL)isBackwards{
	[*viewArray release];
	*viewArray = [[NSMutableArray alloc] initWithCapacity:self.viewsToKeep];
	NSInteger sign = (isBackwards)?-1:1;
	for (NSInteger i = 1; i <= self.viewsToKeep; i++) {
		UIView* view = [self viewAtIndex:(self.currentIndex + sign*i)];
		if (view)
			[*viewArray insertObject:view atIndex:(i-1)];
	}
	return;
}

-(void)trimViewArray:(NSMutableArray **)viewArray{
	if ([*viewArray count] == self.viewsToKeep){
		[(UIView*)[*viewArray lastObject] removeFromSuperview];
		[*viewArray removeLastObject];
	}
}

-(void)switchViewFrom:(NSMutableArray **)fromArray to:(NSMutableArray **)toArray back:(BOOL)back{
	NSInteger sign = ((back)?-1:1);
	
	[self trimViewArray:toArray];
	[*toArray insertObject:currentView atIndex:0];
	
	[currentView release];
	
	currentView = [[*fromArray objectAtIndex:0] retain];
	[*fromArray removeObjectAtIndex:0];
	self.currentIndex += sign;
	
	UIView* newView = [self viewAtIndex:(self.currentIndex + sign*self.viewsToKeep)];
	if (newView){
		[*fromArray insertObject:newView atIndex:[*fromArray count]];

		(void)[self endOfDrawViewsFrom:[[NSArray arrayWithObject:newView] objectEnumerator] 
							startingAt:[self advanceCenter:currentPosition 
														by:self.viewsToKeep*sign]];
	}		
	
}

#pragma mark -

#pragma mark galleryScrollView (Delegate)

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return nil;
}

//-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
//	NSLog(@"end scrolling animation");
//
//}
//
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self matchScrollPositionToPage];
}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//	NSLog(@"did end dragging");
//}
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//	NSLog(@"did end decelerating");
//}
//
//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//	NSLog(@"will begin decelerating");
//}

-(void)matchScrollPositionToPage{
	//if (scrollingATM) return;
	float pageWidth, contentOffset;
	if (navigationMode==GalleryControllerNavigationModeHorizontal){
		pageWidth = galleryScrollView.frame.size.width;
		contentOffset = galleryScrollView.contentOffset.x;
	}else{
		pageWidth = galleryScrollView.frame.size.height;
		contentOffset = galleryScrollView.contentOffset.y;
	}
	int page = floor((contentOffset - pageWidth / 2) / pageWidth) + 1;
	
	//NSLog(@"%d", page);
	if (page - currentIndex != 0){
		[self activateViewNext:(page - currentIndex)>0];
	}
}

#pragma mark -

#pragma mark Scroll View Drawing

-(void)resetViewDimensions{
	if (!currentView || navigationMode == GalleryControllerNavigationModeOther)
		return;
	
	self.view.frame = 
	galleryScrollView.frame = galleryScrollView.bounds = CGRectMake(0, 0, currentView.frame.size.width, currentView.frame.size.height);
	
	NSUInteger capacity = [previousViews count] + [nextViews count];
	
	float width = currentView.frame.size.width * 
	(1 + ((navigationMode==GalleryControllerNavigationModeHorizontal)?capacity:0));
	
	float height = currentView.frame.size.height *
	(1 + ((navigationMode==GalleryControllerNavigationModeVertical)?capacity:0));
	
	galleryScrollView.contentSize = CGSizeMake(width, height);
}

-(void)addGalleryContentSize{
	float width = (self.currentIndex + 2) * currentView.frame.size.width * (navigationMode==GalleryControllerNavigationModeHorizontal);
	float height = (self.currentIndex + 2) * currentView.frame.size.height * (navigationMode==GalleryControllerNavigationModeVertical);

	galleryScrollView.contentSize = CGSizeMake(MAX(galleryScrollView.contentSize.width,width),
											   MAX(galleryScrollView.contentSize.height,height));
}

-(void)drawViews{
	CGPoint point = galleryScrollView.center;

	point = [self endOfDrawViewsFrom:[previousViews reverseObjectEnumerator] startingAt:point];
	currentPosition = point;
	point = [self endOfDrawViewsFrom:[[NSArray arrayWithObject:currentView] objectEnumerator] startingAt:point];
	
	(void)[self endOfDrawViewsFrom:[nextViews objectEnumerator] startingAt:point];	
}

-(CGPoint)endOfDrawViewsFrom:(NSEnumerator*)en startingAt:(CGPoint)point{
	if (navigationMode != GalleryControllerNavigationModeOther){
		for (UIView* view in en) {
			if ([view superview] != galleryScrollView)
				[galleryScrollView addSubview:view];
			
			view.center = point;
			point = [self advanceCenter:point by:1];
		}
	}
	return point;
}

-(CGPoint)advanceCenter:(CGPoint)point by:(NSInteger)n{
	if (navigationMode == GalleryControllerNavigationModeHorizontal){
		point = CGPointMake(point.x + galleryScrollView.frame.size.width*n, point.y);
	}else {
		point = CGPointMake(point.x, point.y + galleryScrollView.frame.size.height*n);
	}
	return point;
}

-(CGRect)positionToVisibleRect:(CGPoint)center{
	return CGRectMake(center.x - galleryScrollView.center.x, 
					  center.y - galleryScrollView.center.y, 
					  galleryScrollView.center.x*2, galleryScrollView.center.y*2);
}


-(void)activateViewNext:(BOOL)next{
	if ((next && [nextViews count] == 0) || (!next && [previousViews count] == 0)) {
		//[self scrollBackToCurrentView];
		return;
	};
	NSInteger sign = 1;
	if (!next)
		sign = -1;
	
	currentPosition = [self advanceCenter:currentPosition by:sign];
		
	//change bounds, free views
	if (next){
		[self switchViewFrom:&nextViews to:&previousViews back:NO];	
	}else {
		[self switchViewFrom:&previousViews to:&nextViews back:YES];
	}
	if ([nextViews count] != 0)
		[self addGalleryContentSize];
	
	[self willActivateViewNext:next];
}

-(void)scrollBackToCurrentView{
	[galleryScrollView scrollRectToVisible:[self positionToVisibleRect:currentPosition] animated:YES];
}

#pragma mark -

#pragma mark NavigationMode
-(void)setNavigationMode:(GalleryControllerNavigationMode)navMode inverted:(BOOL)isInverted{
	navigationMode = navMode;
	inverted = isInverted;
	if (navMode!=GalleryControllerNavigationModeOther && galleryScrollView) {		
		[self resetViewDimensions];
		[self drawViews];
	}
}

#pragma mark -

#pragma mark Abstract
-(UIView*)viewAtIndex:(NSInteger)index{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}
-(void)didActivateViewNext:(BOOL)wasNext{
	return;
}
-(void)willActivateViewNext:(BOOL)isNext{
	return;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
}


#pragma mark -

#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[currentView release];
	[nextViews release];
	[previousViews release];
	[galleryScrollView release];
	
    [super dealloc];
}


@end
