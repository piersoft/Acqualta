//
//  AddToFavoritesAppDelegate.h
//  AddToFavorites
//
//  Created by Gianluca Tranchedone on 08/02/11.
//  Copyright 2011 Sketch to Code. All rights reserved.
//

#import "Favorite.h"

@interface FavoritesData : NSObject
{
	NSMutableArray *_favArray;
	NSString *_dataFilePath;
	BOOL favoritesLoaded;
}

extern NSString *const REFRESH_FAVORITES;

- (void) addFavorite:(Favorite *) fav;
- (void) removeFavoriteById:(NSString *) favId;
- (Favorite *) favoriteWithId:(NSString *) favId;

- (NSArray *) getFavorites;

- (void) saveFavorites;
- (void) loadFavorites;

+ (FavoritesData *) sharedFavoritesData;

@end
