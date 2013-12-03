/*
     File: RootViewController_s.m

 
 */

#import "RootViewController_j.h"
//#import "ViewController.h"
#import "RegexKitLite.h"
#import "AsyncImageView.h"
#import "Favorite.h"
#import "FavoritesData.h"
#import "Mappa.h"
#import "UIImage+Resizing.h"
//#import "SchedaViewController.h"
//#import "MapView.h"
#import "ViewArticolo.h"

#import "ASIHTTPRequest.h"

@implementation RootViewController_j

//@synthesize earthquakeList;
@synthesize tableView = _tableView;
@synthesize magnitude;
@synthesize hud=_hud;
@synthesize isFiltered,prova;
@synthesize search,feeds;
@synthesize filteredListItems, savedSearchTerm, savedScopeButtonIndex, searchWasActive,titolo,ricerca,tracks;


@synthesize searchDisplayController;

#pragma mark -

- (void)dealloc {
  // [earthquakeList release];
    [dateFormatter release];
 //   [filteredFeed release];
    [elencoFeed release];
    

      //  [self.tableView release], self.tableView = nil;
   
        //[filteredListItems dealloc];
  
    [super dealloc];
}

-(BOOL)canBecomeFirstResponder {
    
    return YES;
}



- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    self.hud = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
 
	// getting an NSString
    
}


- (void)timeout:(id)arg {
    
    _hud.labelText = nil;
    _hud.detailsLabelText = nil;
    _hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:1.0];
    //   [self.tableView reloadData];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    if (IS_IPAD) {
         self.view.frame=CGRectMake(0,0, 768, 1024);
         toolBar.frame=CGRectMake(0, 0, 768, 44);
        sfondotabella.frame=CGRectMake(0, 64, 768, 1024);
        barraup.frame=CGRectMake(0, 60, 768, 10);

    }

    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:nil forKey:@"scheda"];
    
 
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    
        UIView *addStatusBar = [[UIView alloc] init];
        addStatusBar.frame = CGRectMake(0, 0, 768, 20);
        //  addStatusBar.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1]; //change this to match your navigation bar
        addStatusBar.backgroundColor = [UIColor whiteColor]; //change this to match your navigation bar
        
        [self.view addSubview:addStatusBar];
    
    
    } else {
       
    toolBar.tintColor=[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255 alpha:1];
     }
    

    if (IS_IPAD) {
        int t=64;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) t=44;
        
        sfondotabella.frame=CGRectMake(0, t, 768, 1024);
        sfondotabella.image=[UIImage imageNamed:@"sfondo_acqualta.png"];
    }
 
    [  self.tableView setBackgroundView:nil];
    [  self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    self.tableView.opaque=NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 && IS_IPAD) {
        barra.frame=CGRectMake(0,56, 768, 20);
        
    }
        
}



- (void)viewDidLoad {
    [super viewDidLoad];
   
  
   titolo.text=self.title;
 
    par=0;
    
    
    [[FavoritesData sharedFavoritesData] getFavorites];

    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    if ([self.title isEqualToString:@"Aziende"]) {
         //   _hud.labelText = @"Attendere qualche secondo..";
    }

    [self performSelector:@selector(timeout:) withObject:nil afterDelay:1];
  
    start=1;
    start1=0;
    prev.enabled=NO;

    
    // Add search bar to navigation bar
    self.navigationItem.titleView = search;
    [self.view bringSubviewToFront:toolBar];
   [self.view bringSubviewToFront:titolo];
    
}




-(IBAction)nextpage{
	
	start = start + 1;
    start1 = start1 + 10;
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    _hud.labelText = nil;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:1];
	[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(restart) userInfo:nil repeats:NO];
	
    
}
-(IBAction)prevpage{

	start = start - 1;
    start1=start1 -10;
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    _hud.labelText = nil;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:1];
	[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(restart) userInfo:nil repeats:NO];
	
    
}
-(IBAction)reload{
    start=1;
    start1=0;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    _hud.labelText = nil;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:1];
    [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(restart) userInfo:nil repeats:NO];
    // [self restart];
}


-(void)restart{
 
    if (start==1) {
        prev.enabled=NO;
        succ.enabled=YES;
    }else prev.enabled=YES;
    
    
    if (start1==0) {
        prev.enabled=NO;
        succ.enabled=YES;
    }else prev.enabled=YES;
    NSString *aggiunta;
    feeds=@"http://paolomainardi.com:3050/api/data?limit=10";
  //  if ([titolo.text rangeOfString:@"News"].length != 0){
         aggiunta=@"&offset=";
        NSString *path = [NSString stringWithFormat:@"%@%@%i",feeds,aggiunta,start1];
        NSLog(@"Path news =%@",path);
    self.tracks=nil;
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:
                    [NSURL URLWithString:path]];
    NSError *jsonError = nil;
    NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                         JSONObjectWithData:data
                                         options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                         error:&jsonError];
    

    self.tracks = (NSDictionary *)jsonResponse ;
    
        [[self tableView] reloadData];
   
   
}
-(void)viewDidAppear:(BOOL)animated{
    if (IS_IPAD) {
        
        self.view.frame=CGRectMake(0,0, 768, 1024);
        toolBar.frame=CGRectMake(0, 20, 768, 44);
        
        [self.view bringSubviewToFront:barra];
        [self.view bringSubviewToFront:toolBar];
        [self.view bringSubviewToFront:titolo];
    }
    
    
    
}


// On-demand initializer for read-only property.
- (NSDateFormatter *)dateFormatter {
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];

         [dateFormatter setDateFormat:@"dd/MM/yyyy' 'HH.mm.ss"];
       [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3600*2]];
     //   [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
     //   [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
       
    }
    return dateFormatter;
}





#pragma mark -
#pragma mark UITableViewDelegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"indexpath %longi",(long)indexPath.row);
    return indexPath;
}


// The number of rows is equal to the number of earthquakes in the array.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
 //   NSLog(@"Elenco feed =%li",[elencoFeed count]);
    NSArray *monday = tracks[@"data"];
    return [monday count];
  
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
      NSArray *monday = tracks[@"data"];
       NSDictionary *item1;
    NSString *CellIdentifier;
    

   
        item1 = [[NSDictionary alloc] initWithDictionary:[monday objectAtIndex:indexPath.row]];
        CellIdentifier = [NSString stringWithFormat:@"%@",item1[@"id"]];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        
     
 
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                [[NSBundle mainBundle] loadNibNamed:@"CellCustomipad" owner:self options:NULL];
                cell=CellCustomipad;
            }
            else {
                [[NSBundle mainBundle] loadNibNamed:@"cellaView" owner:self options:NULL];
                cell=cellaView;
            }
            
        
   
    }
	
    cell.backgroundColor=[UIColor clearColor];
     tableView.separatorColor=[UIColor clearColor];
    

	BOOL isFav = [[FavoritesData sharedFavoritesData] favoriteWithId:CellIdentifier] != nil ;
	NSString *starImage = isFav ? @"37x-Checkmark.png" : @"";
 
    
    UIImage *cellBackground = [UIImage imageNamed:starImage] ;
    check.image = cellBackground;

	
	//background.frame = CGRectMake(295, 42, 10, 10);
	check.contentMode = UIViewContentModeScaleAspectFill;
    // background.backgroundColor=[UIColor clearColor];
	CALayer * l1 = [check layer];
	[l1 setMasksToBounds:YES];
	[l1 setCornerRadius:5.0];
	// You can even add a border
	[l1 setBorderWidth:0.5];
	[l1 setBorderColor:[[UIColor clearColor] CGColor]];
	[cell.contentView addSubview:check];
	
   
    NSString *link = item1[@"date_sent"];
    /*
	link = [link stringByReplacingOccurrencesOfString:@"PDT" withString:@""];
	link = [link stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
	link = [link stringByReplacingOccurrencesOfString:@"+0000" withString:@""];
	link = [link stringByReplacingOccurrencesOfString:@"Wed" withString:@"Mercoledì"];
	link = [link stringByReplacingOccurrencesOfString:@"Sun" withString:@"Domenica"];
	link = [link stringByReplacingOccurrencesOfString:@"Sat" withString:@"Sabato"];
	link = [link stringByReplacingOccurrencesOfString:@"Fri" withString:@"Venerdì"];
	link = [link stringByReplacingOccurrencesOfString:@"Mon" withString:@"Lunedì"];
	link = [link stringByReplacingOccurrencesOfString:@"Tue" withString:@"Martedì"];
	link = [link stringByReplacingOccurrencesOfString:@"Thu" withString:@"Giovedì"];
	link = [link stringByReplacingOccurrencesOfString:@"Jan" withString:@"Gennaio"];
	link = [link stringByReplacingOccurrencesOfString:@"Feb" withString:@"Febbario"];
	link = [link stringByReplacingOccurrencesOfString:@"March" withString:@"Marzo"];
	link = [link stringByReplacingOccurrencesOfString:@"Apr" withString:@"Aprile"];
	link = [link stringByReplacingOccurrencesOfString:@"May" withString:@"Maggio"];
	link = [link stringByReplacingOccurrencesOfString:@"Jun" withString:@"Giugno"];
	link = [link stringByReplacingOccurrencesOfString:@"Jul" withString:@"Luglio"];
	link = [link stringByReplacingOccurrencesOfString:@"Aug" withString:@"Agosto"];
	link = [link stringByReplacingOccurrencesOfString:@"Sep" withString:@"Settembre"];
	link = [link stringByReplacingOccurrencesOfString:@"Oct" withString:@"Ottobre"];
	link = [link stringByReplacingOccurrencesOfString:@"Nov" withString:@"Novembre"];
	link = [link stringByReplacingOccurrencesOfString:@"Dec" withString:@"Dicembre"];
     */
   // link = [link stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    link = [link stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    link = [link stringByReplacingOccurrencesOfString:@".000" withString:@""];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    
   
  
  //  NSLog(@"date orig %@",link);
    NSString *date = link;
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat : @"YYYY-MM-DD'T'hh:mm:ss"];

   [dateFormatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"Rome"]];
    NSDate *AppointmentDate = [dateFormatter1 dateFromString:date];
   // [dateFormatter1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3600*2]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -2;
    components.year =1;
    
    NSDate *nextMonth = [gregorian dateByAddingComponents:components toDate:AppointmentDate options:0];
    [components release];
    
  //  NSDateComponents *nextMonthComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:nextMonth];
 //   NSDate *nextMonthDay = [gregorian dateFromComponents:nextMonthComponents];
    
    [gregorian release];
    
   //	NSLog(@"appointmentDate %@",AppointmentDate);
    NSString *localDate = [NSDateFormatter localizedStringFromDate:nextMonth dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterMediumStyle];
  //  NSLog(@"DATE--> %@",localDate);
    
      dateLabel.text = localDate;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 && !IS_IPAD) {
        sfondo.frame=CGRectMake(0, 0, 320, 83);
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 && IS_IPAD) {
        sfondo.frame=CGRectMake(0, 0, 620, 119);
    }
    if (indexPath.row==[elencoFeed count]-1) {
        
        sfondo.image=[UIImage imageNamed:@"cellarossasf.png"];
        // sfondo.alpha=0;
    }
    
    if (indexPath.row==0) {
        
        sfondo.image=[UIImage imageNamed:@"cellarossasfup.png"];
        // sfondo.alpha=0;
    }
    
   
    
    int minThreshold = [item1[@"level"] intValue]+0;

    //float stringFloat = [item1[@"level"] floatValue];

   
    
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    
    titleLabel.text = [NSString stringWithFormat:@"%@", item1[@"level"]];
    //  cell.backgroundColor=[UIColor redColor];
    UILabel *titleLabel1 = (UILabel *)[cell viewWithTag:11];
    
    titleLabel1.text = [NSString stringWithFormat:@"%i cm.", minThreshold ];
    //    NSLog(@"qui 2");
    
    
 
    
    
   UIImage *cellBackground1 = [UIImage imageNamed:@""] ;
   
    UIImageView *imgview = (UIImageView *)[cell viewWithTag:10];
    
    
   
    if ((minThreshold >=-50) && (minThreshold <=79)) {
        titleLabel1.textColor=[UIColor greenColor];
      //  cellBackground1 = [UIImage imageNamed:@"sea1.gif"];
        
   
        UIWebView *gifview =[[UIWebView alloc]initWithFrame:imgview.frame];
        NSString *imageFileName = @"sea1b";
        NSString *imageFileExtension = @"gif";
       NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:imageFileExtension];
        
      NSString *imgHTMLTag = [NSString stringWithFormat:@"<img STYLE=\"position:absolute; TOP:0px; LEFT:0px; WIDTH:100&#37;\" SRC=\"file://%@\"/>", imagePath];
        gifview.opaque=NO;
        gifview.backgroundColor=[UIColor clearColor];
        gifview.userInteractionEnabled=NO;
        //gifview.scalesPageToFit=YES;
        [gifview loadHTMLString:imgHTMLTag baseURL:[[NSBundle mainBundle] bundleURL]];
        
     CALayer * l3 = [gifview layer];
        [l3 setMasksToBounds:YES];
        [l3 setCornerRadius:5.0];
        // You can even add a border
        [l3 setBorderWidth:0.5];
        [l3 setBorderColor:[[UIColor clearColor] CGColor]];
        

        [cell addSubview:gifview];
        }
    
    
    if ((minThreshold >=80) && (minThreshold <=109)) {
        titleLabel1.textColor=[UIColor yellowColor];
        cellBackground1 = [UIImage imageNamed:@"sea2b.jpg"];
      //  NSLog(@"qui 3");
        
      
    }
    
    if ((minThreshold >=110) && (minThreshold <=139)) {
        titleLabel1.textColor=[UIColor orangeColor];
        cellBackground1 = [UIImage imageNamed:@"sea3b.jpg"];
        
    }
        if ((minThreshold >=110)&& (minThreshold <=190)) {
        titleLabel1.textColor=[UIColor redColor];
        cellBackground1 = [UIImage imageNamed:@"sea4b.jpg"];
    }
    
    
	NSString *titolo1 = item1[@"location"];
	
	UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:1];
    
	subtitleLabel.text = [titolo1 uppercaseString] ;
    subtitleLabel.textColor=titleLabel1.textColor;
    
      CALayer * l11 = [imgview layer];
        [l11 setMasksToBounds:YES];
        [l11 setCornerRadius:5.0];
        // You can even add a border
        [l11 setBorderWidth:0.5];
        //   [l setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [l11 setBorderColor:[[UIColor clearColor] CGColor]];
        
    imgview.image=cellBackground1;
    [cell.contentView addSubview:imgview];
    
    
        cell.selectionStyle=1;
      //  cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   

    
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
            return 120;
		}
		else {
            // return [[sectionInfo objectAtIndex:indexPath.row] floatValue];
			return 84;
		}
    
	
	
	
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 //   NSString *CellIdentifier = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"id"];
	
    NSArray *monday = tracks[@"data"];
    NSDictionary *item1;
    NSString *CellIdentifier;
    
    
    
    item1 = [[NSDictionary alloc] initWithDictionary:[monday objectAtIndex:indexPath.row]];
    CellIdentifier = [NSString stringWithFormat:@"%@",item1[@"id"]];
    
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	UIImage *cellBackground =[UIImage imageNamed:@"37x-Checkmark.png"];
   // UIImageView *check = (UIImageView *)[cell viewWithTag:8];
    
     check.image = cellBackground;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //  background.frame = CGRectMake(655, 15, 15, 15);
    }
    else {
        
        //    background.frame = CGRectMake(280, 10, 10, 10);
        
        
        
    }
	
	//background.frame = CGRectMake(295, 42, 10, 10);
	check.contentMode = UIViewContentModeScaleAspectFill;
    // background.backgroundColor=[UIColor clearColor];
	CALayer * l1 = [check layer];
	[l1 setMasksToBounds:YES];
	[l1 setCornerRadius:5.0];
	// You can even add a border
	[l1 setBorderWidth:0.5];
	[l1 setBorderColor:[[UIColor clearColor] CGColor]];
	[cell.contentView addSubview:check];
    
	
	Favorite *favorite = [[FavoritesData sharedFavoritesData] favoriteWithId:CellIdentifier];
    
    if(!favorite) {
        
        Favorite *fav = [[Favorite alloc] init];
		fav.favId = CellIdentifier;
		//fav.description = FAV_DESC;
        [[FavoritesData sharedFavoritesData] addFavorite:fav];
        [fav release];
        
    }
    else {
		//  [[FavoritesData sharedFavoritesData] removeFavoriteById:CellIdentifier];
    }
	
    NSLog(@"self title %@",self.title);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"1" forKey:@"scheda"];
    
    NSLog(@"apro singola scheda in mappa");
    
    Mappa *controller = [[Mappa alloc] initWithNibName:@"Mappa" bundle:nil];
    controller.feedlat=item1[@"latitude"];
    controller.feedlon=item1[@"longitude"];
    controller.feed=item1[@"location"];
    controller.linkdapassare=@"";
    controller.feedsubtit=[NSString stringWithFormat:@"%@", item1[@"level"]];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
   
  //  [self.navigationController pushViewController:   controller animated:YES];
  //  [controller release];
   [self presentViewController:controller animated:YES completion:nil];
}


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

-(IBAction)dismiss{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end