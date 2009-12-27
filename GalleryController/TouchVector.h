//
//  TouchVector.h
//  GalleryViewController
//
//  Created by Piotr Sokolski on 09-12-27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


@interface TouchVector : NSObject {
	CGFloat velocity;
	
	CGPoint previousPosition;
	CGPoint initPosition;
	NSUInteger direction;
}

@property(nonatomic,readonly)CGFloat velocity;
@property(nonatomic,readonly)NSUInteger direction;
@property(nonatomic,readonly)CGPoint previousPosition;
@property(nonatomic,readonly)CGPoint initPosition;

-(void)addPostion:(CGPoint)position;
-(id)initWithPosition:(CGPoint)position;
-(CGFloat)getDistance;
@end
