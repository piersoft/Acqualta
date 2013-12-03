//
//  EndAnnotation.h
//  Ride
//
//  Created by Nicholas Hubbard on 5/2/10.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import "ZSPinAnnotation.h"

/*!
 An annotation helped class to be used to hold annotation data for ZSPinAnnotation
 */
@interface ZSAnnotation : NSObject <MKAnnotation>

/// The coordinate for the annotation
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/// The title for the annotation
@property (nonatomic, copy) NSString *title;

/// The subtitle for the annotation
@property (nonatomic, copy) NSString *subtitle;

/// The color of the annotation
@property (nonatomic, strong) UIColor *color;

/// The type of annotation to draw
@property (nonatomic) ZSPinAnnotationType type;

@end