//
//  ViewController.m
//  Acqualta
//
//  Created by Francesco Piero Paolicelli on 10/11/13.
//  Copyright (c) 2013 Francesco Piero Paolicelli. All rights reserved.
//

#import "ViewController.h"
#import "RootViewController_s.h"
#import "Mappa.h"
#import "ViewArticolo.h"
#import "Appirater.h"
#import "MappaAPI.h"
#import "RootViewController_j.h"

@interface ViewController ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBeahvior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:@"scheda"];
    
    if ([prefs objectForKey:@"news"]!=nil) {
        [self livelli];
    }
    /*
    if (IS_IPAD) {
        int t=0;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) t=-20;

        sfondo.frame=CGRectMake(0, t, 768, 1024);
        sfondo.image=[UIImage imageNamed:@"ipadneutro.png"];
        aziende.frame=CGRectMake(0, 400, 400, 50);
        
    }   
*/
}
-(void)viewDidAppear:(BOOL)animated{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        
        self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)viewDidLoad
{
    
    [Appirater appLaunched:YES];
    
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
   
         if (IS_IPAD) {
              [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(animazione) userInfo:nil repeats:NO];
         }else  [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(animazione) userInfo:nil repeats:NO];
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
     }else{
         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
         NSString *view=[prefs objectForKey:@"phone"];
        
         if ([view isEqualToString:@"iPhoneRetina"]) {
             self.view.frame=CGRectMake(0, 20, 320, 460);
         }
         UIImageView *banner=[[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-70, 320, 70)];
         
        
         banner.image=[UIImage imageNamed:@"acqualtabanneriphone.png"];
         if (IS_IPAD){
             banner.image=[UIImage imageNamed:@"acqualtabanner.png"];
             banner.frame=CGRectMake(0, self.view.frame.size.height-70, 768,70);

         }
         NSLog(@"banner");
         [self.view addSubview:banner];
         
     }
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
-(IBAction)animazione{
    
    //  NSUInteger num = arc4random() % 40 + 1;
    //  NSString *filename = [NSString stringWithFormat:@"m%lu", (unsigned long)num];
    NSLog(@"animazion");
    NSString *filename = @"acqualtabanneriphone.png";
    if (IS_IPAD) filename =@"acqualtabanner.png";
    UIImage *image = [UIImage imageNamed:filename];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    
    //  CGPoint tappedPos = [gesture locationInView:gesture.view];
    imageView.center = self.view.center;
    
    [self.gravityBeahvior addItem:imageView];
    [self.collisionBehavior addItem:imageView];
    [self.itemBehavior addItem:imageView];
}


-(IBAction)livelli{
  
NSData *data = [[NSData alloc] initWithContentsOfURL:
                [NSURL URLWithString:@"http://paolomainardi.com:3050/api/data?limit=10"]];
NSError *jsonError = nil;
NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                     JSONObjectWithData:data
                                     options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                     error:&jsonError];


RootViewController_j *trackListVC;
trackListVC = [[RootViewController_j alloc]
               initWithNibName:@"RootViewController_j"
               bundle:nil];
    trackListVC.title=@"Livelli";
trackListVC.tracks = (NSDictionary *)jsonResponse ;
    [self presentViewController:trackListVC animated:YES completion:nil];
    

}

-(IBAction)livelli2{
    NSString *nib=@"RootViewController2_s";
    
    RootViewController_s *photoView = [[RootViewController_s alloc] initWithNibName:nib bundle:nil];
    photoView.title=@"Livelli";
    photoView.feeds=@"http://www.acqualta.org/feed.php";
    photoView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:photoView animated:YES completion:nil];
    
}
 
-(IBAction)news{
    if (IS_IPAD)
    {
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloipad" bundle:nil];
        
        controller.indirizzo = @"http://www.acqualta.org/il-sensore";
        
        
        controller.titolotext=@"Il sensore";
        
          controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        
       // [self.navigationController pushViewController:controller animated:YES];
       // [controller release];
        
         [self presentViewController:controller animated:YES completion:nil];
        
    }else{
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloiphone" bundle:nil];
        
        controller.indirizzo = @"http://www.acqualta.org/il-sensore";
        
        
        controller.titolotext=@"Il sensore";
        
          controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
           [self presentViewController:controller animated:YES completion:nil];
       // [self.navigationController pushViewController:controller animated:YES];
       // [controller release];
        
    }

    
}
-(IBAction)bandi{
    NSString *nib=@"RootViewController2_n";
    
    RootViewController_s *photoView = [[RootViewController_s alloc] initWithNibName:nib bundle:nil];
    photoView.title=@"News";
    photoView.feeds=@"http://www.acqualta.org/feed";
    [self presentViewController:photoView animated:YES completion:nil];
    
}
-(IBAction)mappa{
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:
                    [NSURL URLWithString:@"http://paolomainardi.com:3050/api/devices/"]];
    NSError *jsonError = nil;
    NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                         error:&jsonError];
    
    //    [self performSelector:@selector(timeout:) withObject:nil afterDelay:0];
    
    MappaAPI *trackListVC;
    trackListVC = [[MappaAPI alloc]
                   initWithNibName:@"MappaAPI"
                   bundle:nil];
    trackListVC.tracks = (NSDictionary *)jsonResponse ;
  //  NSLog(@"tracks in viewcontroller %@",[trackListVC.tracks objectForKey:@"data"]);
    [self.navigationController pushViewController:trackListVC animated:YES];
    [trackListVC release];
    
    
}
-(IBAction)mappa_old{
    
    Mappa *photoView = [[Mappa alloc] initWithNibName:@"Mappa" bundle:nil];
    photoView.feed=@"http://www.imatera.info/Acqualta/acqualta.xml";
   // [self presentViewController:photoView animated:YES completion:nil];
    [self.navigationController pushViewController:photoView animated:YES];
    [photoView release];
}
-(IBAction)website{
    self.navigationController.navigationBarHidden=NO;
    
    if (IS_IPAD)
    {
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloipad" bundle:nil];
        
        controller.indirizzo = @"http://www.acqualta.org/il-sensore";
        
        
        controller.titolotext=@"Il sensore";
        
        //  controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        // [self presentViewController:controller animated:YES completion:nil];
        
    }else{
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloiphone" bundle:nil];
        
        controller.indirizzo = @"http://www.acqualta.org/il-sensore";
        
        
        controller.titolotext=@"Il sensore";
        
        //  controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    
    }

}

-(IBAction)credits{
    
  //  self.navigationController.navigationBarHidden=NO;
  
    if (IS_IPAD)
    {
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloipad" bundle:nil];
       
        controller.indirizzo = @"http://www.acqualta.org/about";
        
        
        controller.titolotext=@"About";
        
      //  controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
     
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
      // [self presentViewController:controller animated:YES completion:nil];
        
    }else{
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloiphone" bundle:nil];
        
        controller.indirizzo = @"http://www.acqualta.org/about";
        
        
        controller.titolotext=@"About";
        
        //  controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];    }
    

}

-(IBAction)tweets{
    
    self.navigationController.navigationBarHidden=NO;
    
    if (IS_IPAD)
    {
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloipad" bundle:nil];
        
        controller.indirizzo = @"http://www.imatera.info/Acqualta/tweetacqualta.html";
        
        
        controller.titolotext=@"Tweets @AcqualtaVE";
        
        //  controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        // [self presentViewController:controller animated:YES completion:nil];
        
    }else{
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloiphone" bundle:nil];
        
        controller.indirizzo = @"http://www.imatera.info/Acqualta/tweetacqualta.html";
        
        
        controller.titolotext=@"Tweets @AcqualtaVE";
        
        //  controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];    }
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
