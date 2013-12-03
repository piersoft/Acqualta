//
//  DisplayView.h
//  iVagabro
//
//  Created by Francesco Ficetola on 13/11/11.
//  Copyright 2015 lubannaiuolu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>


@interface DisplayMap : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D coordinate; 
    NSString *title; 
    NSString *subtitle;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate; 
@property (nonatomic, copy) NSString *title; 
@property (nonatomic, copy) NSString *subtitle;

@end