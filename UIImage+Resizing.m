//
//  UIImage+Resizing.m
//  Free24
//
//  Created by francesco paolicelli on 15/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "UIImage+Resizing.h"

@implementation UIImage (Resizing)

/**
 * Creates a resized, autoreleased copy of the image, with the given dimensions.
 * @return an autoreleased, resized copy of the image
 */
- (UIImage*) resizedImageWithSize:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
    
	[self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
	// An autoreleased image
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return newImage;
}


#pragma mark -
#pragma mark Scale and crop image

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
UIImage *sourceImage = self;
UIImage *newImage = nil;        
CGSize imageSize = sourceImage.size;
CGFloat width = imageSize.width;
CGFloat height = imageSize.height;
CGFloat targetWidth = targetSize.width;
CGFloat targetHeight = targetSize.height;
CGFloat scaleFactor = 0.0;
CGFloat scaledWidth = targetWidth;
CGFloat scaledHeight = targetHeight;
CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
{
    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;
    
    if (widthFactor > heightFactor) 
        scaleFactor = widthFactor; // scale to fit height
    else
        scaleFactor = heightFactor; // scale to fit width
    scaledWidth  = width * scaleFactor;
    scaledHeight = height * scaleFactor;
    
    // center the image
    if (widthFactor > heightFactor)
    {
        thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5+0; 
    }
    else 
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
}       

UIGraphicsBeginImageContext(targetSize); // this will crop

CGRect thumbnailRect = CGRectZero;
thumbnailRect.origin = thumbnailPoint;
thumbnailRect.size.width  = scaledWidth;
thumbnailRect.size.height = scaledHeight;

[sourceImage drawInRect:thumbnailRect];

newImage = UIGraphicsGetImageFromCurrentImageContext();
if(newImage == nil) 
NSLog(@"could not scale image");

//pop the context to get back to the default
UIGraphicsEndImageContext();
return newImage;
}

@end

