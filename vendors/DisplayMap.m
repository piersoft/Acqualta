//
//  DisplayView.m
//  iVagabro
//
//  Created by Francesco Ficetola on 13/11/11.
//  Copyright 2011 lubannaiuolu. All rights reserved.
//

#import "DisplayMap.h"

@implementation DisplayMap

@synthesize coordinate,title,subtitle;

-(void)dealloc {
    [title release];
    [super dealloc];
}


@end
