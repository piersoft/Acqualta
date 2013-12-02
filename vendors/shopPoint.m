//
//  SeesmicEvent.m
//  EarthquakeMap
//
//  Created by Charlie Key on 8/24/09.
//  Copyright 2009 Paranoid Ferret Productions. All rights reserved.
//

#import "shopPoint.h"

@implementation shopPoint

@synthesize latitude;
@synthesize longitude;
@synthesize title;
@synthesize subtitle;
@synthesize coordinate;
@synthesize immagine,link,pin;

- (CLLocationCoordinate2D)coordinate
{
  CLLocationCoordinate2D coord = {self.latitude, self.longitude};
  return coord;
}

- (NSString*) description
{
  return [NSString stringWithFormat:@"%1.3f, %1.3f", 
          self.latitude, self.longitude];
}
@end
