//
//  AddToFavoritesAppDelegate.h
//  AddToFavorites
//
//  Created by Gianluca Tranchedone on 08/02/11.
//  Copyright 2011 Sketch to Code. All rights reserved.
//

#import "FavoritesData.h"

#import "SynthesizeSingleton.h"

@interface FavoritesData (Private)

- (NSString *) docsDir;

@end

@implementation FavoritesData

NSString *const REFRESH_FAVORITES = @"refreshFavorites";

SYNTHESIZE_SINGLETON_FOR_CLASS(FavoritesData);

- (void) addFavorite:(Favorite *) fav
{
	if(!favoritesLoaded) [self loadFavorites];
	
	Favorite *favorite = [self favoriteWithId:fav.favId];
	if(!favorite) [_favArray addObject:fav];
	
	[self saveFavorites];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FAVORITES object:nil];
}

- (void) removeFavoriteById:(NSString *) favId
{
	for(int i = 0; i < _favArray.count; i++)
	{
		Favorite *fav = (Favorite *)[_favArray objectAtIndex:i];
		if([fav.favId isEqualToString:favId])
			[_favArray removeObjectAtIndex:i];
	}
	
	[self saveFavorites];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_FAVORITES object:nil];
}

- (Favorite *) favoriteWithId:(NSString *) favId
{
	for(int i = 0; i < _favArray.count; i++)
	{
		Favorite *fav = (Favorite *)[_favArray objectAtIndex:i];
		if([fav.favId isEqualToString:favId]) return fav;
	}
	
	return nil;
}

- (NSArray *) getFavorites
{
	if(!favoritesLoaded) [self loadFavorites];
	
	return _favArray;
}

- (void) saveFavorites
{
	NSMutableData *savedData;
	NSKeyedArchiver *encoder;
	
	savedData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:savedData];
	
	[encoder encodeObject:_favArray forKey:@"favorites"];
	[encoder finishEncoding];
	
	[savedData writeToFile:_dataFilePath atomically:YES];
	[encoder release];
}

- (void) loadFavorites
{	
	if(favoritesLoaded) return;
	
	NSString *dataFileName = @"favorites.dat";
	_dataFilePath = [[[self docsDir] stringByAppendingPathComponent:dataFileName] retain];
	
	BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	success = [fileManager fileExistsAtPath:_dataFilePath];
	
	if(success)
	{
		NSMutableData *savedData;
		NSKeyedUnarchiver *decoder;
		NSMutableArray *tmpFavArray;
		
		savedData = [NSData dataWithContentsOfFile:_dataFilePath];
		decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:savedData];
		tmpFavArray = [decoder decodeObjectForKey:@"favorites"];
		
		if(tmpFavArray) _favArray = [tmpFavArray retain];
		else _favArray = [[[NSMutableArray alloc] init] retain];
		
		[decoder finishDecoding];
		[decoder release];
	}
	else _favArray = [[[NSMutableArray alloc] init] retain];
	
	favoritesLoaded = YES;
}
/*
- (NSString *) docsDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return documentsDirectory;
}
*/
- (NSString *)docsDir
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	NSFileManager *fileManager = [[NSFileManager new] autorelease]; // File manager instance
    
	NSURL *pathURL = [fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    
	return [pathURL path]; // Path to the application's "~/Library/Application Support" directory
}

@end
