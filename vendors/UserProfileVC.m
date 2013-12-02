//  Acqualta
//
//  Created by Piero Paolicelli on 11/04/11.
//  Copyright 2011 piersoft.it. All rights reserved.

//

#import	"UserProfileVC.h"


@implementation UserProfileVC
@synthesize textView;

- (void)viewDidLoad {
	[super viewDidLoad];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
	 interfaceOrientation=UIInterfaceOrientationPortrait;
 return YES;
 }
 

@end
