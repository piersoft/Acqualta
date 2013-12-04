//
//  AppDelegate.m
//  ASI Brindisi
//
//  Created by Francesco Piero Paolicelli on 10/11/13.
//  Copyright (c) 2013 Francesco Piero Paolicelli. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "RootViewController_s.h"
#import "shopPoint.h"
#define kHostName @"www.apple.com"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[Reachability sharedReachability] setHostName:kHostName];
    //Set Reachability class to notifiy app when the network status changes.
    [[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
    //Set a method to be called when a notification is sent.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
    [self initStatus];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"NO"
                                                            forKey:@"reset"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
    NSString *thisDevice=@"";
    if (!IS_IPAD)
    {
        thisDevice = @"iPhone";
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0) {
            thisDevice = @"iPhoneRetina";
            if ([[UIScreen mainScreen] bounds].size.height == 568)
                thisDevice = @"iPhone5";
            NSLog(@"size %f",[[UIScreen mainScreen] bounds].size.height);
        }
    }
    else
    {
        thisDevice = @"iPad";
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
            && [[UIScreen mainScreen] scale] == 2.0)
            thisDevice =@"iPadRetina";
    }
    NSLog(@"this device = %@",thisDevice);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:thisDevice forKey:@"phone"];
    
    [prefs setObject:nil forKey:@"password"];
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.items = nil;
    
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
        //   self.viewControllern = [[[RootViewController_s alloc] initWithNibName:@"RootViewController2_n" bundle:nil]autorelease];
    } else {
        //   self.viewControllern = [[[RootViewController_s alloc] initWithNibName:@"RootViewController2_n" bundle:nil]autorelease];
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewControlleriPad" bundle:nil] autorelease];
    }
    if ([UIApplication sharedApplication].applicationIconBadgeNumber!=0) {
        [prefs setObject:@"1" forKey:@"news"];
    }else [prefs setObject:nil forKey:@"news"];
    
    [self.window addSubview:self.viewController.view];
    self.window.rootViewController=self.viewController;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    navController.navigationBarHidden=YES;
    [self.window addSubview:navController.view];
    
    [self.window makeKeyAndVisible];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,768, 1024)];
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
            splashView.image = [UIImage imageNamed:@"Default~ipad.png"];
        } else splashView.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
        [self.window addSubview:splashView];
        [self.window bringSubviewToFront:splashView];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.window cache:YES];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
        splashView.frame = CGRectMake(384, 384, 0, 0);
        splashView.alpha = 0.0;
    }
    else {
        splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
        splashView.image = [UIImage imageNamed:@"Default.png"];
        [self.window addSubview:splashView];
        [self.window bringSubviewToFront:splashView];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.window cache:YES];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
        splashView.frame = CGRectMake(160, 240, 0, 0);
        splashView.alpha = 0.0;
    }
    
    
    [UIView commitAnimations];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIView *addStatusBar = [[UIView alloc] init];
        addStatusBar.frame = CGRectMake(0, 0, 768, 20);
        //  addStatusBar.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1]; //change this to match your navigation bar
        addStatusBar.backgroundColor = [UIColor whiteColor]; //change this to match your navigation bar
        
        [self.window.rootViewController.view addSubview:addStatusBar];
    }
    sleep(2);
    return YES;
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[splashView removeFromSuperview];
	[splashView release];
}
- (void)reachabilityChanged:(NSNotification *)note {
    [self updateStatus];
}

-(void)initStatus {
    remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
    //  self.internetConnectionStatus    = [[Reachability sharedReachability] internetConnectionStatus];
}

- (void)updateStatus
{
    // Query the SystemConfiguration framework for the state of the device's network connections.
    remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
    internetConnectionStatus    = [[Reachability sharedReachability] internetConnectionStatus];
    NSLog(@"remote status = %d, internet status = %d", remoteHostStatus, internetConnectionStatus);
    if (internetConnectionStatus == NotReachable && remoteHostStatus == NotReachable) {
        self.window.hidden=YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rete assente" message:@"Spiacente, ma la connesione 3G o Wifi non è disponibile o sufficiente. Abilitala per poter accedere all'App" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        NSLog(@"notifica nel didfinishlaunching");
        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
        
        self.window.hidden=NO;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
   
        
        NSURL *dataUrl = [NSURL
                          URLWithString:@"http://www.imatera.info/Acqualta/link.txt"];
        NSString *fileString = [NSString stringWithContentsOfURL:dataUrl
                                                        encoding:NSUTF8StringEncoding
                                                           error:nil];
        int count = 0;
        NSScanner *scanner = [NSScanner scannerWithString:fileString];
        
        shopPoints = [[NSMutableArray array] retain];
        
        
        NSString *line;
        NSArray *values;
        
        while ([scanner isAtEnd] == NO) {
            [scanner scanUpToString:@"\n" intoString:&line];
            //if(count > -1) {
            values = [line componentsSeparatedByString:@"#"];
            
         
            
            [prefs setObject:[[values objectAtIndex:0] copy] forKey:@"api"];
              [prefs setObject:[[values objectAtIndex:1] copy] forKey:@"apimappa"];
            [prefs setObject:[[values objectAtIndex:2] copy] forKey:@"apilivelli"];
          [prefs setObject:[[values objectAtIndex:3] copy] forKey:@"xml"];
            NSLog(@"api link %@ %@ %@ %@",[prefs objectForKey:@"api"],[prefs objectForKey:@"apilivelli"],[prefs objectForKey:@"apimappa"],[prefs objectForKey:@"xml"]);
            //	}
            count++;
            if(count == 100) {
                //limit number of events to 100
                break;
            }
        }
        

    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
 * --------------------------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE
 * --------------------------------------------------------------------------------------------------------------
 */

/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
#if !TARGET_IPHONE_SIMULATOR
    //  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
    
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    appName = [appName stringByReplacingOccurrencesOfString:@" "withString:@""];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
	NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
	NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid;
    
    
    // identifierForVendor è solo per iOS6. per iOS5 si può ancora usare id uuid
	if ([dev respondsToSelector:@selector(identifierForVendor)]){
        //#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
        NSString *uuidString = [uuid UUIDString];
        NSLog(@"uuidString= %@",uuidString);
        deviceUuid = uuidString;
        deviceUuid=[deviceUuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
	}
    else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		id uuid = [defaults objectForKey:@"deviceUuid"];
		if (uuid)
			deviceUuid = (NSString *)uuid;
		else {
			CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
			deviceUuid = (NSString *)cfUuid;
			CFRelease(cfUuid);
			[defaults setObject:deviceUuid forKey:@"deviceUuid"];
		}
	}
	NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	// Build URL String for Registration
	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
	// !!! SAMPLE: "secure.awesomeapp.com"
	NSString *host = @"www.apposta.biz";
	
	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED
	// !!! ( MUST START WITH / AND END WITH ? ).
	// !!! SAMPLE: "/path/to/apns.php?"
	NSString *urlString = [NSString stringWithFormat:@"/apnacqualta.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
	
	// Register the Device Data
	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSLog(@"Register URL: %@", url);
	NSLog(@"Return Data: %@", returnData);
    //	}
#endif
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
#if !TARGET_IPHONE_SIMULATOR
	
	NSLog(@"Error in registration. Error: %@", error);
	
#endif
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
#if !TARGET_IPHONE_SIMULATOR
    
	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
	
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
	
#endif
}

/*
 * --------------------------------------------------------------------------------------------------------------
 *  END APNS CODE
 * --------------------------------------------------------------------------------------------------------------
 */




@end
