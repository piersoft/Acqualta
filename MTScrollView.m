//
//  MTScrollView.m
//  MTGallery
//
//  Created by Matt Tuzzolo on 9/15/10.
//  Copyright 2010 Regulars LLC. All rights reserved.
//

#import "MTScrollView.h"


@implementation MTScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [(UIViewController*)[self superview] touchesBegan:touches withEvent:event];
}

@end
