//
//  UIImage+Resizing.h
//  Free24
//
//  Created by francesco paolicelli on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resizing)

- (UIImage*) resizedImageWithSize:(CGSize)size;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end