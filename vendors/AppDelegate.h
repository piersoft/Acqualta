//
//  AppDelegate.h
//  Acqualta Venezia
//
//  Created by Francesco Piero Paolicelli on 30/11/13.
//  Copyright (c) 2013 Francesco Piero Paolicelli. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
@class ViewController;
@class RootViewController_s;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIImageView *splashView;
    NetworkStatus internetConnectionStatus;
    NetworkStatus remoteHostStatus;
}

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) RootViewController *viewController;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) RootViewController_s *viewControllern;


@end
