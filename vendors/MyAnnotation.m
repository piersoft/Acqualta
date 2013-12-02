//
//  MyAnnotation.m
//  Acqualta
//
//  Created by Piero Paolicelli on 11/04/11.
//  Copyright 2011 piersoft.it. All rights reserved.
//
#import "MyAnnotation.h"


@implementation MyAnnotation

@synthesize title;
@synthesize subtitle;
@synthesize coordinate,image;

- (void)dealloc 
{
	[super dealloc];
	self.title = nil;
	self.subtitle = nil;
}
@end