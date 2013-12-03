//
//  SeesmicEvent.h
//  EarthquakeMap
//
//  Created by Charlie Key on 8/24/09.
//  Copyright 2009 Paranoid Ferret Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>



@interface shopPoint : NSObject <MKAnnotation>{
  float latitude;
  float longitude;
	NSString* title;
    NSString* subtitle;
	NSString* immagine;
    NSString* link;
    NSString* pin;
}

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic, copy)		NSString* title;
@property (nonatomic, copy)		NSString* subtitle;
@property (nonatomic, copy)		NSString* immagine;
@property (nonatomic, copy)		NSString* link;
@property (nonatomic, copy)		NSString* pin;
//MKAnnotation
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;


@end
