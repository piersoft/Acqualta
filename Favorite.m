//
//  AddToFavoritesAppDelegate.h
//  AddToFavorites
//
//  Created by Gianluca Tranchedone on 08/02/11.
//  Copyright 2011 Sketch to Code. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

@synthesize favId, description;

- (id) initWithCoder:(NSCoder *) encoder
{
	favId = [[encoder decodeObjectForKey:@"favId"] retain];
	description = [[encoder decodeObjectForKey:@"description"] retain];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *) encoder
{
	[encoder encodeObject:favId forKey:@"favId"];
	[encoder encodeObject:description forKey:@"description"];
}

- (void) dealloc
{
	[description release];
	[favId release];
	[super dealloc];
}

@end
