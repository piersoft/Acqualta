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
         if (IS_IPAD && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
             banner.image=[UIImage imageNamed:@"acqualtabanner.png"];
             banner.frame=CGRectMake(0, self.view.frame.size.height-90, 768,70);
             
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

-(IBAction)proveJSON{
    NSData *data = [[NSData alloc] initWithContentsOfURL:
                    [NSURL URLWithString:@"http://acqualta.cartodb.com/api/v2/viz/4633d396-5834-11e3-af15-0719a28de9e2/viz.json"]];
    NSError *jsonError = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:0|1|2
                                         error:&jsonError];
  
    
  NSLog(@"json %@",jsonResponse);
    NSLog(@"json error %@",jsonError);
    
    
    
   
}
-(void)livelliapri{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *livelli=[NSString stringWithFormat:@"%@?limit=10",[prefs objectForKey:@"apilivelli"]];
    
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:
                    [NSURL URLWithString:livelli]];
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
-(IBAction)livelli{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([[prefs objectForKey:@"api"] isEqualToString:@"0"]) {
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(livelli2) userInfo:nil repeats:NO];
        [prefs setObject:nil forKey:@"scheda"];
    }else [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(livelliapri) userInfo:nil repeats:NO];
 

}

-(void)livelli2{
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

-(void)mappapri{
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:
                    [NSURL URLWithString:[prefs objectForKey:@"apimappa"]]];
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
-(IBAction)mappa{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([[prefs objectForKey:@"api"] isEqualToString:@"0"]) {
          [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(mappa_old) userInfo:nil repeats:NO];
        [prefs setObject:nil forKey:@"scheda"];
    }else [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(mappapri) userInfo:nil repeats:NO];

    
}
-(void)mappa_old{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    Mappa *photoView = [[Mappa alloc] initWithNibName:@"Mappa" bundle:nil];
 //   photoView.feed=@"http://www.imatera.info/Acqualta/acqualta.xml";
    photoView.feed=[prefs objectForKey:@"xml"];
   // [self presentViewController:photoView animated:YES completion:nil];
    [self.navigationController pushViewController:photoView animated:YES];
    [photoView release];
}
-(IBAction)credits{
    self.navigationController.navigationBarHidden=NO;
    
    if (IS_IPAD)
    {
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloipad" bundle:nil];
        
        controller.indirizzo = @"http://www.imatera.info/Acqualta/creditsiphone.html";
        
        
        controller.titolotext=@"Credits";
        
          controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
       //  [self presentViewController:controller animated:YES completion:nil];
        
    }else{
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloiphone" bundle:nil];
        
        controller.indirizzo = @"http://www.imatera.info/Acqualta/creditsiphone.html";
        
        
        controller.titolotext=@"Credits";
        
        //  controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
    //     [self presentViewController:controller animated:YES completion:nil];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    
    }

}

-(IBAction)about{
    
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
