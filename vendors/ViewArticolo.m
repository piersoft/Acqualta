//
//  ViewArticolo.m
//  SimpleRSSreader
//
//  Created by Andrea Busi on 17/05/10.
//  Copyright 2010 BubiDevs. All rights reserved.
//  Modifiche a cura di Francesco Piero Paolicelli
//

#import "ViewArticolo.h"
#import <QuartzCore/QuartzCore.h>
#import "Mappa.h"
#import "ZBFallenBricksAnimator.h"
#import "MethodSwizzle.h"


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


typedef enum {
    TransitionTypeNormal,
    TransitionTypeVerticalLines,
    TransitionTypeHorizontalLines,
    TransitionTypeGravity,
} TransitionType;


@interface ViewArticolo () <UINavigationControllerDelegate>{
    
   
    
 TransitionType type;
}
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBeahvior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;

- (void)hideGradientBackground:(UIView*)theView;
@end




@implementation ViewArticolo

@synthesize indirizzo,sommario,fit,immagine,datatext,indirizzo1,titolotext,titolo,webView;
@synthesize m_activity,titoloview,phone,map,lat,longi,buttonoff,indirizzoazienda,emailaz,www,barra;
@synthesize toolbar = _toolbar;
@synthesize hud = _hud;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSObject <UIViewControllerAnimatedTransitioning> *animator;
    
    switch (type) {
        case TransitionTypeGravity:
            animator = [[ZBFallenBricksAnimator alloc] init];
            break;
        default:
            animator = nil;
    }
    
    return animator;
}

- (IBAction)pop:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0:
            type = TransitionTypeGravity;
            break;
            
       
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    titolo.textColor=[UIColor blackColor];
    type = TransitionTypeNormal;
    
    self.navigationController.delegate = self;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) { 
        webView.scrollView.bounces = NO;
        webView1.scrollView.bounces = NO;
           webView.scrollView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    }
    [super viewDidLoad];

    
       [self hideGradientBackground:webView];
        webView.opaque=NO;
    webView.backgroundColor=[UIColor clearColor];
    
 
    
        self.hud = [MBProgressHUD showHUDAddedTo:webView animated:YES];
    _hud.labelText = nil;
    _hud.detailsLabelText = nil;
          [self performSelector:@selector(timeout:) withObject:nil afterDelay:20];
    
        indirizzo=[indirizzo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"indirizzo =%@",indirizzo);
            NSURL *url = [NSURL URLWithString:indirizzo];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            webView.scalesPageToFit = YES;
            
             [webView setDelegate:self];
            
            [webView loadRequest:requestObj];
        
        
    [self.view bringSubviewToFront:titolo];
  

    if ([titolotext isEqualToString:@"About"]) {
        /*
       UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(tapped:)];
        gesture.delegate=self;
        
        [self.view addGestureRecognizer:gesture];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(animazione) userInfo:nil repeats:NO];
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        self.gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:nil];
        
        self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:nil];
        self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        
        self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:nil];
        self.itemBehavior.elasticity = 0.6;
        self.itemBehavior.friction = 0.5;
        self.itemBehavior.resistance = 0.5;
        
        
        [self.animator addBehavior:self.gravityBeahvior];
        [self.animator addBehavior:self.collisionBehavior];
        [self.animator addBehavior:self.itemBehavior];
         */
    }
    [self.view bringSubviewToFront:webView];
    [self.view bringSubviewToFront:sfondo];
         
}
- (void)tapped:(UITapGestureRecognizer *)gesture  {
    
    //  NSUInteger num = arc4random() % 40 + 1;
    //  NSString *filename = [NSString stringWithFormat:@"m%lu", (unsigned long)num];
    NSString *filename = @"apposta@2x.png";
    UIImage *image = [UIImage imageNamed:filename];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
    CGPoint tappedPos = [gesture locationInView:gesture.view];
     imageView.center = tappedPos;
    
        
        [self.gravityBeahvior addItem:imageView];
        [self.collisionBehavior addItem:imageView];
        [self.itemBehavior addItem:imageView];
    
   

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != webView) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}
-(IBAction)animazione{
    
    //  NSUInteger num = arc4random() % 40 + 1;
    //  NSString *filename = [NSString stringWithFormat:@"m%lu", (unsigned long)num];
    NSLog(@"animazion");
    NSString *filename = @"apposta@2x.png";
    UIImage *image = [UIImage imageNamed:filename];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
  //  CGPoint tappedPos = [gesture locationInView:gesture.view];
    imageView.center = self.view.center;
    
    [self.gravityBeahvior addItem:imageView];
    [self.collisionBehavior addItem:imageView];
    [self.itemBehavior addItem:imageView];
}

-(IBAction)rubrica{
    if ([phone rangeOfString:@"XXX"].length == 0)  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Inserisco il contatto in rubrica?"
                                                    message:@""
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    [alert release];
}
}
-(void)rubricabackground{
    chiama=0;
  //  ABAddressBookRef addressBook = ABAddressBookCreate();
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook,
                                             ^(bool granted, CFErrorRef error){
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_release(sema);
    
        __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        [self btnAddToContactsTapped];
        // Do whatever you want here.
    }
}
- (void)btnAddToContactsTapped {
    CFErrorRef error = NULL;
    // create addressBook
//    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(iPhoneAddressBook,
                                             ^(bool granted, CFErrorRef error){
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_release(sema);
    //// Creating a person
    // create a new person --------------------
    ABRecordRef newPerson = ABPersonCreate();
    // set the first name for person
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, titolo.text, &error);
    // set the last name
 //   ABRecordSetValue(newPerson, kABPersonLastNameProperty, @"SugarTin.info", &error);
    // set the company name
   // ABRecordSetValue(newPerson, kABPersonOrganizationProperty, @"Apple Inc.", &error);
    // set the job-title
  //  ABRecordSetValue(newPerson, kABPersonJobTitleProperty, @"Senior Developer", &error);
    // --------------------------------------------------------------------------------
    
    //// Adding Phone details
    // create a new phone --------------------
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // set the main phone number
    ABMultiValueAddValueAndLabel(multiPhone, phone, kABPersonPhoneMainLabel, NULL);
    // set the mobile number
  //  ABMultiValueAddValueAndLabel(multiPhone, @"1-123-456-7890", kABPersonPhoneMobileLabel, NULL);
    // set the other number
  //  ABMultiValueAddValueAndLabel(multiPhone, @"1-987-654-3210", kABOtherLabel, NULL);
    // add phone details to person
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    // release phone object
    CFRelease(multiPhone);
    // --------------------------------------------------------------------------------
    
    //// Adding email details
    // create new email-ref
    ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // set the work mail
    ABMultiValueAddValueAndLabel(multiEmail, emailaz, kABWorkLabel, NULL);
    // add the mail to person
   ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
    // release mail object
    CFRelease(multiEmail);
    // --------------------------------------------------------------------------------
    
    
    //// Adding www details
    // create new email-ref
    ABMutableMultiValueRef multiwww = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    // set the work www
    ABMultiValueAddValueAndLabel(multiwww, www, kABWorkLabel, NULL);
    // add the www to person
    ABRecordSetValue(newPerson, kABPersonURLProperty, multiwww, &error);
    // release www object
    CFRelease(multiwww);
    // --------------------------------------------------------------------------------
    
    //// adding address details
    // create address object
    ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    // create a new dictionary
    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
    // set the address line to new dictionary object
    [addressDictionary setObject:indirizzoazienda forKey:(NSString *) kABPersonAddressStreetKey];
    // set the city to new dictionary object
 //   [addressDictionary setObject:@"Bengaluru" forKey:(NSString *)kABPersonAddressCityKey];
    // set the state to new dictionary object
 //   [addressDictionary setObject:@"Karnataka" forKey:(NSString *)kABPersonAddressStateKey];
    // set the zip/pin to new dictionary object
//    [addressDictionary setObject:@"560068 " forKey:(NSString *)kABPersonAddressZIPKey];
    // retain the dictionary
    CFTypeRef ctr = CFBridgingRetain(addressDictionary);
    // copy all key-values from ctr to Address object
    ABMultiValueAddValueAndLabel(multiAddress,ctr, kABWorkLabel, NULL);
    // add address object to person
   ABRecordSetValue(newPerson, kABPersonAddressProperty, multiAddress,&error);
    // release address object
    CFRelease(multiAddress);
    // --------------------------------------------------------------------------------
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSURL *imageURL = [NSURL URLWithString: [prefs valueForKey:@"image"]];

  //  UIImage *im = [UIImage imageNamed:@"my_image.jpg"];
   // NSData *dataRef = UIImagePNGRepresentation(im);
    NSData *dataRef ;
    dataRef= [NSData dataWithContentsOfURL:imageURL];

    ABPersonSetImageData(newPerson, (CFDataRef)dataRef, nil);
    
    
    //// adding entry to contact-book
    // add person to addressbook
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    // save/commit entry
    ABAddressBookSave(iPhoneAddressBook, &error);
    
    if (error != NULL) {
        NSLog(@"Kaa boom ! couldn't save");
    }else {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ \naggiunto alla rubrica",titolo.text]
                                                        message:@""
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
-(IBAction)phoneclass
{
    chiama=1;
  
    if (!IS_IPAD) {
            
      
    NSString *telephoneString=[phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableString *str1=[[NSMutableString alloc] initWithString:telephoneString];
    [str1 setString:[str1 stringByReplacingOccurrencesOfString:@"(" withString:@""]];
    [str1 setString:[str1 stringByReplacingOccurrencesOfString:@")" withString:@""]];
    [str1 setString:[str1 stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    [str1 setString:[str1 stringByReplacingOccurrencesOfString:@" " withString:@""]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CALL / CHIAMA?"
                                                    message:str1
                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    [alert show];
    [alert release];
    }
 
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attenzione"
                                                        message:@"Il tuo dispositivo non permette chiamate telefoniche"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
            
}

- (void)alertView:(UIAlertView *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
		
	}else {
        if (chiama==0) {
   [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(rubricabackground) userInfo:nil repeats:NO];
        
       //     [self rubricabackground];
        }else [self chiama];
    }
}
-(void)chiama
{
    
    NSString *telephoneString=[phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableString *str1=[[NSMutableString alloc] initWithString:telephoneString];
    [str1 setString:[str1 stringByReplacingOccurrencesOfString:@"(" withString:@""]];
    [str1 setString:[str1 stringByReplacingOccurrencesOfString:@")" withString:@""]];
    [str1 setString:[str1 stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    [str1 setString:[str1 stringByReplacingOccurrencesOfString:@" " withString:@""]];
    telephoneString = [@"tel://" stringByAppendingString:str1];
    [str1 release];
    NSLog(@"telefono =%@",telephoneString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneString]];
    
    
}



-(IBAction)mapclass{
    
//    self.hud = [MBProgressHUD showHUDAddedTo:webView animated:YES];
//    _hud.labelText = @"";
 //   [self performSelector:@selector(timeout:) withObject:nil afterDelay:20];
    	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   /*
    indirizzo = [NSString stringWithFormat:@"%@%@%@%@%@",@"https://maps.google.com/maps?q=",lat,@",",longi,@"&num=1&t=m&z=16&output=embed"];
    indirizzo=[indirizzo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"indirizzo =%@",indirizzo);
    NSURL *url = [NSURL URLWithString:indirizzo];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    webView.scalesPageToFit = YES;
    
    [webView setDelegate:self];
    
    [webView loadRequest:requestObj];
    */
    
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"1" forKey:@"scheda"];
     
    NSLog(@"apro singola scheda in mappa");
    
    Mappa *controller = [[Mappa alloc] initWithNibName:@"Mappa" bundle:nil];
    controller.feedlat=lat;
    controller.feedlon=longi;
    controller.feed=titolo.text;
    controller.linkdapassare=indirizzo;
    controller.feedsubtit=titolo.text;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    [titolo.text stripHtml];
 
    NSString *link1=titolo.text;
    
    
    link1= [link1 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    //  link = [link stringByReplacingOccurrencesOfString:@" " withString:@""];
    link1 = [link1 stringByReplacingOccurrencesOfString:@"  " withString:@""];
    link1 = [link1 stringByReplacingOccurrencesOfString:@"   " withString:@""];
    link1 = [link1 stringByReplacingOccurrencesOfString:@"    " withString:@""];
    link1 = [link1 stringByReplacingOccurrencesOfString:@"     " withString:@""];
    link1 = [link1 stringByReplacingOccurrencesOfString:@"      " withString:@""];
    link1 = [link1 stringByReplacingOccurrencesOfString:@"       " withString:@""];
    link1 = [link1 stringByReplacingOccurrencesOfString:@"        " withString:@""];
    link1 = [link1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *oggetto=[NSString stringWithFormat:@"%@%@",link1,@" @AcqualtaVE "];
   
    NSString *indirizzoshare=indirizzo;
            
       NSURL *url=[NSURL URLWithString:indirizzoshare];
 
    NSString *soggetto=[NSString stringWithFormat:@"<html><head>\
                        <title>%@</title>\
                        </head><body>%@\
                        </b>\
                        </body></html>",oggetto,url];
    if ([activityType isEqualToString:UIActivityTypePostToFacebook] || [activityType isEqualToString:UIActivityTypePostToTwitter]) {
        
        soggetto=[soggetto stringByReplacingOccurrencesOfString:@"</head><body>" withString:@""];
        soggetto=[soggetto stringByReplacingOccurrencesOfString:@"</body></html>" withString:@""];
        soggetto=[soggetto stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
        soggetto=[soggetto stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
        soggetto=[soggetto stringByReplacingOccurrencesOfString:@"<html><head>" withString:@""];
        soggetto=[soggetto stringByReplacingOccurrencesOfString:@"<title>" withString:@""];
        soggetto=[soggetto stringByReplacingOccurrencesOfString:@"</title>" withString:@""];
        soggetto=[soggetto stringByReplacingOccurrencesOfString:@"  " withString:@""];
        
        
        NSLog(@"prova");
        return soggetto;
    }else{
        
        
        MethodSwizzle([MFMailComposeViewController class], @selector(setMessageBody:isHTML:), @selector(setMessageBodySwizzled:isHTML:));
    }
    
    return soggetto;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"PlaceHolder";
}

-(IBAction)share{
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
 
   //     NSData *data1 = [NSData dataWithContentsOfFile:filePath];
        
        NSArray* dataToShare =[NSArray arrayWithObjects:self,nil];
        //@[oggetto,data1,self];
        // ...or whatever pieces of data you
        
        
        UIActivityViewController* activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                          applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact,UIActivityTypeMessage];
        
        
        //         [activityViewController setSubject:titolo.text];
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            popovercontroller = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            
            CGRect rect = [[UIScreen mainScreen] bounds];
            
            [popovercontroller
             presentPopoverFromRect:rect inView:self.view
             permittedArrowDirections:0
             animated:YES];
        }
        else
        {
            [self presentViewController:activityViewController animated:YES completion:nil];
        }
        //     [activityViewController setSubject:oggetto];
        //  [self presentViewController:activityViewController animated:YES completion:^{}];
    
    
    
        }else{
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Condivisioni non attive sulla tua versione firmware. Aggiorna almeno a iOS6" message:@"" delegate:nil cancelButtonTitle:@"Annulla" otherButtonTitles:@"OK", nil];
            [alertView show];
            [alertView release];
        }
}

- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:webView animated:YES];
    self.hud = nil;
    
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)timeout:(id)arg {
    
    _hud.labelText = nil;
    _hud.detailsLabelText = nil;
    _hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:1.0];
    //   [self.tableView reloadData];
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation duration:(NSTimeInterval)duration 
{
	switch (interfaceOrientation) 
	{
		case UIInterfaceOrientationPortrait: 
		{
        
        fb.frame=CGRectMake(768/2-40-20, 5, 40, 34);
     
        tw.frame=CGRectMake(768/2-20, 5, 40, 34);
   
        mail.frame=CGRectMake(768/2+20, 5, 40, 34);
            	}
        break;
            
        case UIInterfaceOrientationPortraitUpsideDown: 
		{
            
            fb.frame=CGRectMake(768/2-40-20, 5, 40, 34);
            
            tw.frame=CGRectMake(768/2-20, 5, 40, 34);
            
            mail.frame=CGRectMake(768/2+20, 5, 40, 34);
        }
            break;

        case UIInterfaceOrientationLandscapeRight: 
		{

        fb.frame=CGRectMake(1024/2-40-20, 5, 40, 34);
      
        tw.frame=CGRectMake(1024/2-20, 5, 40, 34);
    
        mail.frame=CGRectMake(1024/2+20, 5, 40, 34); 
        }
        break;
        case UIInterfaceOrientationLandscapeLeft: 
		{
            
            fb.frame=CGRectMake(1024/2-40-20, 5, 40, 34);
            
            tw.frame=CGRectMake(1024/2-20, 5, 40, 34);
            
            mail.frame=CGRectMake(1024/2+20, 5, 40, 34); 
        }
            break;
	
	}
    
}





- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
   
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
    }else if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return YES;
    }
	//webView.scalesPageToFit=YES;
   // se si vogliono solo i links esterni farli aprire in safari return YES;
    return YES;
}
*/

- (void)webViewDidStartLoad:(UIWebView *)_webView
	{
     //   if ([indirizzo isEqualToString:@"webcam"]) {}
      //  else
    if (caricato != 1 && [indirizzo rangeOfString:@".mp3"].length == 0) {
            [m_activity startAnimating];
	
		dateLabel.hidden=FALSE;
		CALayer * l = [dateLabel layer]; 
		[l setMasksToBounds:YES]; 
		[l setCornerRadius:5.0]; 
		// You can even add a border 
		[l setBorderWidth:1]; 
		[l setBorderColor:[[UIColor blackColor] CGColor]]; 	
		// starting the load, show the activity indicator in the status bar
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
        } else  [m_activity stopAnimating];
        
           
    }
- (void)webViewDidFinishLoad:(UIWebView *)_webView {
    //if ([indirizzo isEqualToString:@"webcam"]) {}
    //else{
        caricato = 1;
    
     [self performSelector:@selector(timeout:) withObject:nil afterDelay:0];
    
	[m_activity stopAnimating];
	dateLabel.hidden=TRUE;
	//[alertView3 dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//iScrollview.minimumZoomScale = 0.48;
	//iScrollview.maximumZoomScale = 4.0;
	//iScrollview.zoomScale = iScrollview.minimumZoomScale;
webView.alpha=1;
//	iScrollview.minimumZoomScale = 0.48;
//	iScrollview.maximumZoomScale = 4.0;
//	iScrollview.zoomScale = iScrollview.minimumZoomScale;
   
}
//}
-(void)inizio{
	//[m_activity stopAnimating];
	[alertView3 dismissWithClickedButtonIndex:0 animated:YES];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//iScrollview.minimumZoomScale = 0.48;
	//iScrollview.maximumZoomScale = 4.0;
	//iScrollview.zoomScale = iScrollview.minimumZoomScale;
	
	//	iScrollview.minimumZoomScale = 0.48;
	//	iScrollview.maximumZoomScale = 4.0;
	//	iScrollview.zoomScale = iScrollview.minimumZoomScale;		
}


- (void)viewDidAppear:(BOOL)animated {
	
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif
    
 //   NSError *err;
    
 //   [[GANTracker sharedTracker] trackPageview:titolo.text withError: &err];
    
 //   [[GANTracker sharedTracker] dispatch];
    

    [super viewDidAppear:animated];
}


- (void)viewWillAppear:(BOOL)animated{
    
    
    titolo.text=titolotext;
    [titolo.text stripHtml];
   
    NSLog(@"titolo %@",titolo.text);
	
   
    	self.navigationController.navigationBarHidden=YES;
    self.navigationController.navigationBar.translucent=YES;

   // menu.style=UIBarButtonItemStyleBordered;
  
    [menu setAction:@selector(back)];
    // menu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    
  //    self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:50.0/255.0 green:79.0/255.0 blue:133.0/255 alpha:1];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
    
    UIView *addStatusBar = [[UIView alloc] init];
    addStatusBar.frame = CGRectMake(0, 0, 768, 20);
    //  addStatusBar.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1]; //change this to match your navigation bar
    addStatusBar.backgroundColor = [UIColor whiteColor]; //change this to match your navigation bar
    
    [self.view addSubview:addStatusBar];
    }else {
       //   menu.tintColor=[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255 alpha:1];
        toolbarsotto.tintColor=[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255 alpha:1];
        
    _toolbar.tintColor=[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255 alpha:1];
    }
   
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:nil forKey:@"right"];
  //   [menu setAction:@selector(back)];
    
   
	
    //  [SHK setFirstViewController:self.navigationController];
    if (buttonoff!=nil) {
        toolbarsotto.hidden=NO;
        
        
    }else toolbarsotto.hidden=YES;
//	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:nil forKey:@"keyToLookupString"];
	//webView.alpha=0.4;
	m_activity.alpha=1;
  //  [SHK setFirstViewController:self.navigationController];
    
   // self.navigationController.navigationBarHidden=YES;
    
   // self.navigationController.navigationBar.translucent=NO;
   // self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:50.0/255.0 green:79.0/255.0 blue:133.0/255 alpha:1];
	//self.title=@"RSS Feed";
    
 //   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *thisDevice=[prefs valueForKey:@"phone"];
    NSLog(@"this device = %@",thisDevice);
    if ([thisDevice isEqualToString:@"iPhone5"]) {
        self.view.frame=CGRectMake(0, 20, 320, 568);
       // webView.frame=CGRectMake(0, 44+20, 320, 504-44);
      //  toolbarsotto.frame=CGRectMake(0, 504, 320, 44);
       
    }
    
   // buttonoff=[prefs objectForKey:@"buttonoff"];
    
    if ([titolotext isEqualToString:@"About"] || [titolotext rangeOfString:@"Tweets"].length != 0) {
        _toolbar.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255 alpha:1];
        titolo.hidden=NO;
       
        [self.view bringSubviewToFront:titolo];
        
    }else{
     //   toolbarsotto.hidden=YES;
     //   UIImage* image = [UIImage imageNamed:@"share.png"];
        CGRect frame = CGRectMake(0, 0, 30, 30);
        UIButton* button = [[UIButton alloc] initWithFrame:frame];
        
 button= [UIButton buttonWithType:UIButtonTypeContactAdd];
     

     //   [button setImage:image forState:UIControlStateNormal];
       // [button setImage:[UIImage imageNamed:@"share_on.png"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
       
      //  menu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
        if ([prefs objectForKey:@"info"]!=nil) {
            //[barButton1 setAction:@selector(dism)];
        }
       // menu.style=UIBarButtonItemStyleBordered;
        UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //     NSMutableArray *items = [NSMutableArray arrayWithArray:_toolbar.items];
        //       [items removeObjectAtIndex:0];
        
        NSMutableArray *buttons = [[NSMutableArray alloc ]initWithCapacity:3];
        
        [buttons addObject:menu];
        [buttons addObject:barButton2];
        [buttons addObject:barButton];
        
        
        [_toolbar setItems:buttons animated:NO];
        
    }
    if (!IS_IPAD) {
        int t=0;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) t=20;
            
            
         webView.frame=CGRectMake(0, 44+t, webView.frame.size.width, webView.frame.size.height+54);
        
      //  toolbarsotto.frame=CGRectMake(0, self.view.frame.size.height-24, toolbarsotto.frame.size.width,toolbarsotto.frame.size.height);
     
        barra.frame=CGRectMake(0, self.view.frame.size.height-10, barra.frame.size.width,barra.frame.size.height);

    }
    
    
  
    
    _toolbar.hidden=NO;

    if ([prefs objectForKey:@"scheda"]!=nil) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:toolbarsotto.items];
        [items removeObjectAtIndex:1];
       
        [items removeObjectAtIndex:1];
        
        
        [toolbarsotto setItems:items animated:NO];
    }
    [self.view bringSubviewToFront:_toolbar];
    [self.view bringSubviewToFront:titolo];
    
    titolo.textColor=[UIColor whiteColor];
    [self.view bringSubviewToFront:webView];
}



-(void)dism{
        NSLog(@"cliccato dismiss");
   
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)back{
    NSLog(@"cliccato back");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismisspop" object:self];
    lat=nil;
   // titolo.text=nil;
    if ([titolo.text isEqualToString:@"About"] || [titolo.text isEqualToString:@"il sensore"] || [titolo.text isEqualToString:@"Tweets @AcqualtaVE"]) {
        NSLog(@"cliccato back in About");
  
            type = TransitionTypeGravity;
            
       
        [self.navigationController popViewControllerAnimated:YES];

    }else [self dismissViewControllerAnimated:YES completion:nil];

        type = TransitionTypeNormal;
        
    

    
}
/*

- (void)alertView:(UIAlertView *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
		[self dismissModalViewControllerAnimated:YES];
		
	//	iScrollview = [[webView subviews] objectAtIndex:0];
		
			
	//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:indirizzo]];
	}
}

*/


-(BOOL)ShouldAutorotate{
    return false;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if (IS_IPAD) {
        return YES;
    }else return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}



-(NSUInteger)supportedInterfaceOrientations{
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskAll;
    }else return (UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown) ;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    webView1=nil;
    webView=nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [webView release];
    [webView1 release];
    [m_activity release];
    [titolo release];
    [titolotext release];
    [super dealloc];
}


@end
