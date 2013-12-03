//
//  AddToFavoritesAppDelegate.h
//  AddToFavorites
//
//  Created by Gianluca Tranchedone on 08/02/11.
//  Copyright 2011 Sketch to Code. All rights reserved.
//

@interface Favorite : NSObject
{
	NSString *favId;
	NSString *description;
}

@property (nonatomic, retain) NSString *favId;
@property (nonatomic, retain) NSString *description;

@end
