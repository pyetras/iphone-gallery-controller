//
//  GalleryScrollView.h
//  GalleryViewController
//
//  Created by Piotr Sokolski on 09-12-27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchVector.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class GalleryController;

@interface GalleryScrollView : UIScrollView {
	GalleryController* galleryController;
	TouchVector* touchVector;
	BOOL horizontalScrollEnabled;
	BOOL verticalScrollEnabled;
}

@property(nonatomic, assign)BOOL horizontalScrollEnabled;
@property(nonatomic, assign)BOOL verticalScrollEnabled;
@property(nonatomic, assign)GalleryController* galleryController;

@end
