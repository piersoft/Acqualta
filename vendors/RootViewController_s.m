/*
     File: RootViewController_s.m

 
 */

#import "RootViewController_s.h"
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

@implementation RootViewController_s

//@synthesize earthquakeList;
@synthesize tableView = _tableView;
@synthesize magnitude;
@synthesize hud=_hud;
@synthesize isFiltered,prova;
@synthesize search,feeds;
@synthesize filteredListItems, savedSearchTerm, savedScopeButtonIndex, searchWasActive,titolo,ricerca;


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
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if(textField == ricerca){
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(ricercaparsing) userInfo:nil repeats:NO];
        self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        _hud.labelText = nil;
        _hud.detailsLabelText = nil;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    
    [self.view endEditing:YES];
    
    ricerca.text=[ricerca.text stripHtml];
    
    // [self ricercaparsing];
    [super touchesBegan:touches withEvent:event];
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    // Any new character added is passed in as the "text" parameter
    
    if([text isEqualToString:@"\n"]) {
        
        // Be sure to test for equality using the "isEqualToString" message
        
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        
        return NO;
    }
    
    // For any other character return TRUE so that the text gets added to the view
    
    return YES;
}
-(void)ricercaparsing{
    
    
    NSString *pa=[NSString stringWithFormat:@"%@?s=%@",feeds,ricerca.text];
    NSLog(@"ricerca link=%@",pa);
    [self parseXMLFileAtURL:pa];
    
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
    
    
    if (feeds==nil) {
      //  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      //  [prefs setObject:nil forKey:@"news"];

     //  titolo.text=@"News";
    //self.title=@"News";
 // feeds=@"http://156.54.64.30/ws/feed/?";
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    
        UIView *addStatusBar = [[UIView alloc] init];
        addStatusBar.frame = CGRectMake(0, 0, 768, 20);
        //  addStatusBar.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1]; //change this to match your navigation bar
        addStatusBar.backgroundColor = [UIColor whiteColor]; //change this to match your navigation bar
        
        [self.view addSubview:addStatusBar];
    
    
    } else {
       
    toolBar.tintColor=[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255 alpha:1];
     }
    
 /*
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:feeds]];
    [request setRequestMethod:@"HEAD"];
    [request setDelegate:self];
    [request startAsynchronous];
    
*/
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



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    // If the number of parsed earthquakes is greater than
    // kMaximumNumberOfEarthquakesToParse, abort the parse.
    //
    
    
    currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
     
		// inizializza tutti gli elementi
		item = [[NSMutableDictionary alloc] init];
        currentId = [[NSMutableString alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		currentImage = [[NSMutableString alloc] init];
		currentThumbnail = [[NSMutableString alloc] init];
        currentLat = [[NSMutableString alloc] init];
        currentLon = [[NSMutableString alloc] init];
        currentWWW = [[NSMutableString alloc] init];
        currentEmail = [[NSMutableString alloc] init];
		    currentCategory = [[NSMutableString alloc] init];
      
	}
  
    
}
- (void)parseXMLFileAtURL:(NSString *)URL {
	// inizializziamo la lista degli elementi
	elencoFeed = [[NSMutableArray alloc] init];
	filteredListItems = [[NSMutableArray alloc] init];
	// dobbxiamo convertire la stringa "URL" in un elemento "NSURL"
	NSURL *xmlURL = [NSURL URLWithString:URL];
	
	// inizializziamo il nostro parser XML
	rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	
	[rssParser setDelegate:self];
	
	// settiamo alcune proprietà
	[rssParser setShouldProcessNamespaces:NO];
	[rssParser setShouldReportNamespacePrefixes:NO];
	[rssParser setShouldResolveExternalEntities:NO];
	
	// avviamo il parsing del feed RSS
	[rssParser parse];
  
   
	
}





- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName

{
  
	if ([elementName isEqualToString:@"item"]) {
         par=par+1;
		/* salva tutte le proprietà del feed letto nell'elemento "item", per
         poi inserirlo nell'array "elencoFeed" */
        [item setObject:currentId forKey:@"phone"];
		[item setObject:currentTitle forKey:@"luogo"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"descrizione"];
        [item setObject:currentWWW forKey:@"www"];
        [item setObject:currentEmail forKey:@"email"];
        [item setObject:currentCategory forKey:@"categoria"];
        
        
        
		[item setObject:currentDate forKey:@"pubDate"];
		
        [item setObject:currentImage forKey:@"indirizzo"];
		
        [item setObject:currentLat forKey:@"lat"];
        [item setObject:currentLon forKey:@"long"];
		[item setObject:currentThumbnail forKey:@"file"];
        
        [elencoFeed addObject:[item copy]];
        [filteredListItems addObject:[item copy]];
       
        /*
        NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
        [formatter setNumberStyle:NSNumberFormatterPercentStyle];
        
        //    Set to the current locale
        [formatter setLocale:[NSLocale currentLocale]];
        
        NSNumber *num = [NSNumber numberWithFloat:par];
        NSString *formattedOutput = [formatter stringFromNumber:num];
        */
        
      _hud.labelText = [NSString stringWithFormat: @"%f%%", (float)par/ (float) 770*100];
     //   NSLog(@"text %@",_hud.labelText);
     if (((float)par/ (float) 770*100)>=90) {
         
         _hud.labelText = nil;
         _hud.detailsLabelText = nil;
        
         [MBProgressHUD hideHUDForView:self.tableView animated:YES];
         self.hud = nil;
         

     }
    }
  
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	;
    
    
    
	// salva i caratteri per l'elemento corrente
	if ([currentElement isEqualToString:@"title"]){
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"])
	{
        
    //    NSLog(@"enclosure =%@",string);
		[currentSummary appendString:string];
		
	}else if ([currentElement isEqualToString:@"category"])
	{
        
        //    NSLog(@"enclosure =%@",string);
		[currentCategory appendString:string];
		
	} else if ([currentElement isEqualToString:@"file"])
	{
		[currentThumbnail appendString:string];
		
	} else if ([currentElement isEqualToString:@"website"])
	{
		[currentWWW appendString:string];
		
	} else if ([currentElement isEqualToString:@"email"])
	{
		[currentEmail appendString:string];
		
	}else if ([currentElement isEqualToString:@"indirizzo"])
	{
		[currentImage appendString:string];
		
	}else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
		
		
		//NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
		//[self.currentImage setString: [currentImage stringByTrimmingCharactersInSet: charsToTrim]];
		
    }else if ([currentElement isEqualToString:@"latitudine"])
	{
		[currentLat appendString:string];
		
	}else if ([currentElement isEqualToString:@"longitudine"])
	{
		[currentLon appendString:string];
		
	}else if ([currentElement isEqualToString:@"telefono"])
	{
		[currentId appendString:string];
		
	}
    
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
    
  //  if (((float)par/ (float) 770*100)>=90) {
  
    _hud.labelText = nil;
    _hud.detailsLabelText = @"";
    
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //[self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:0];
  //  }
    
    

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSLog(@"sono in parse prima del reloadtable");
    
    if ([elencoFeed count] < 10) {
        //start = 0;
        succ.enabled=NO;
    }
    
    if(item==nil || [elencoFeed count]==0) {
        
        ////  UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Spiacenti non ci sono risultati!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[errorAlert show];
        NSLog(@"ho trovato il nil");
        if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"en"]) {
            
        //    [footer setTitle:NSLocalizedString(@"Sorry, items not found",nil) forState:UIControlStateNormal];
        }
        else {
          //  [footer setTitle:NSLocalizedString(@"Spiacenti, non ci sono risultati",nil) forState:UIControlStateNormal];
        }
        [self.tableView reloadData];
    }
    
    else {
        [self.tableView reloadData];
        //  NSLog(@"elenco feed %i",[elencoFeed count]);
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        //  [self.view sendSubviewToBack:Banner3];
	}
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:4];
 
    
    _tableView.alpha=1;
    
  
    [UIView commitAnimations];
    NSDate *now = [NSDate date];
    NSString *agg=[NSString stringWithFormat:@"Aggiornamento: %@",[self.dateFormatter stringFromDate:now]];
    aggiornamento.text=agg;
    
  /*
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:search contentsController:self];

    
   [self.searchDisplayController setValue:[NSNumber numberWithInt:UITableViewStyleGrouped]
                                    forKey:@"_searchResultsTableViewStyle"];
    
    if (self.savedSearchTerm)
	{
   
        
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
        if (!IS_IPAD) {
           search.frame=CGRectMake(0, 0, self.search.frame.size.width, self.search.frame.size.height-44);
        }
    }
    
    */
    
	// programmatically set up search display controller
	//searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:search contentsController:self];
	//[self setSearchDisplayController:searchDisplayController];
	//[searchDisplayController setDelegate:self];
	//[searchDisplayController setSearchResultsDataSource:self];
    
	//[search release];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
  
    titolo.text=self.title;
    ricerca.delegate=self;
    ricerca.enablesReturnKeyAutomatically = YES;
    
    ricerca.returnKeyType = UIReturnKeyDone;
   
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
    UITextField *searchField = [search valueForKey:@"_searchField"];
    
    // Change search bar text color
    searchField.textColor = [UIColor whiteColor];
    
    // Change the search bar placeholder text color
    [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [search setShowsCancelButton:NO animated:YES];
    [self.searchDisplayController.searchBar setShowsCancelButton:NO];
     }
    par=0;
    
    
    [[FavoritesData sharedFavoritesData] getFavorites];

    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    if ([self.title isEqualToString:@"Aziende"]) {
         //   _hud.labelText = @"Attendere qualche secondo..";
    }

    [self performSelector:@selector(timeout:) withObject:nil afterDelay:20];
    [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(inizio) userInfo:nil repeats:NO];

    start=1;
    start1=0;
    prev.enabled=NO;

    
    // Add search bar to navigation bar
    self.navigationItem.titleView = search;
    [self.view bringSubviewToFront:toolBar];
   [self.view bringSubviewToFront:titolo];
}



- (void)requestFinished:(ASIHTTPRequest *)request
{
   
    
    NSLog(@"Content will be %llu bytes in size",[request contentLength]);
   
  //  prova=[NSString stringWithFormat:@"%llu",[request contentLength]];
    fileSizeRemote=[request contentLength];
   
}

-(void)inizio{
//NSString *aggiunta;
    
    
        NSString *aggiunta;
        aggiunta=@"&orderby=title&order=ASC";
        NSString *path = [NSString stringWithFormat:@"%@?paged=%i%@&items=10",feeds,start,aggiunta];
        NSLog(@"Path news =%@",path);
        [self parseXMLFileAtURL:path];
        [[self tableView] reloadData];
        
    
    
   
}
-(void)carica{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   
      [self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject: [prefs objectForKey:@"filelocale"]];
}
-(IBAction)nextpage{
	
	start = start + 1;
    start1 = start1 + 10;
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    _hud.labelText = nil;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:10];
	[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(restart) userInfo:nil repeats:NO];
	
    
}
-(IBAction)prevpage{

	start = start - 1;
    start1=start1 -10;
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    _hud.labelText = nil;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:10];
	[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(restart) userInfo:nil repeats:NO];
	
    
}
-(IBAction)reload{
    start=1;
    start1=0;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    _hud.labelText = nil;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:10];
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
    
  //  if ([titolo.text rangeOfString:@"News"].length != 0){
         aggiunta=@"&orderby=title&order=ASC";
        NSString *path = [NSString stringWithFormat:@"%@?paged=%i%@",feeds,start,aggiunta];
        NSLog(@"Path news =%@",path);
        [self parseXMLFileAtURL:path];
        [[self tableView] reloadData];
   /*
    }else {
       
        aggiunta=@"&items=10";
        NSString *path = [NSString stringWithFormat:@"%@&start=%i%@",feeds,start1,aggiunta];
        NSLog(@"Path =%@",path);
        [self parseXMLFileAtURL:path];
        [[self tableView] reloadData];
        
    }
  */
  //  feeds = [feeds stringByReplacingOccurrencesOfString:@"news" withString:@"carta"];
    
   // NSString *feedURLString = feeds;
   
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
- (void)viewDidUnload {
    [super viewDidUnload];
    
  
    
   // [self removeObserver:self forKeyPath:@"earthquakeList"];
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
   // return [elencoFeed count];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [filteredListItems count];
    }
	else
	{
       
        return [elencoFeed count];
    }}

// The cell uses a custom layout, but otherwise has standard behavior for UITableViewCell.
// In these cases, it's preferable to modify the view hierarchy of the cell's content view, rather
// than subclassing. Instead, view "tags" are used to identify specific controls, such as labels,
// image views, etc.
//


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
       NSDictionary *item1;
    NSString *CellIdentifier;
    

   if (tableView == self.searchDisplayController.searchResultsTableView){
    
        item1 = [[NSDictionary alloc] initWithDictionary:[filteredListItems objectAtIndex:indexPath.row]];
     //   CellIdentifier = [[filteredListItems objectAtIndex:indexPath.row] objectForKey:@"id"];
        CellIdentifier = [item1 objectForKey:@"luogo"];
        NSLog(@"sono nella tableview filtrata");
       
    }else {
        item1 = [[NSDictionary alloc] initWithDictionary:[elencoFeed objectAtIndex:indexPath.row]];
        CellIdentifier = [item1 objectForKey:@"luogo"];
              NSLog(@"sono nella tableview non filtrata");
      //  CellIdentifier = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"id"];
    }
    
    //CellIdentifier = [item1 objectForKey:@"id"];

    /*
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        CellIdentifier = [[filteredListItems objectAtIndex:indexPath.row] objectForKey:@"id"];

    }
	else
	{
        CellIdentifier = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"id"];

    }
    */
  //  NSString *CellIdentifier = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"id"];
	//tableView.backgroundColor = [UIColor lightGrayColor];
	
        
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        

        
		//[[NSBundle mainBundle] loadNibNamed:@"cellaView" owner:self options:NULL];
		//cell = cellaView;
		
        
        

        if ([self.title isEqualToString:@"Livelli"]) {
            
        
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                [[NSBundle mainBundle] loadNibNamed:@"CellCustomipad" owner:self options:NULL];
                cell=CellCustomipad;
            }
            else {
                [[NSBundle mainBundle] loadNibNamed:@"cellaView" owner:self options:NULL];
                cell=cellaView;
            }
            
        }else{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                [[NSBundle mainBundle] loadNibNamed:@"CellCustomipad_s" owner:self options:NULL];
                cell=CellCustomipad_s;
            }
            else {
                [[NSBundle mainBundle] loadNibNamed:@"cellaView_s" owner:self options:NULL];
                cell=cellaView_s;
            }
        }
        
        
        
		/*
         
         NSData *receivedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
         
         UIImage *cellBackground = [[UIImage alloc] initWithData:receivedData];
         
         UIImageView* background = [[UIImageView alloc] initWithImage:cellBackground];
         
         background.frame = CGRectMake(5, 5, 50, 50);
         background.contentMode = UIViewContentModeScaleAspectFill;
         CALayer * l = [background layer];
         [l setMasksToBounds:YES];
         [l setCornerRadius:5.0];
         // You can even add a border
         [l setBorderWidth:1];
         [l setBorderColor:[[UIColor blackColor] CGColor]];
         
         [cell.contentView addSubview:background];
         */
    }
	else {
		AsyncImageView* oldImage = (AsyncImageView*)
		[cell.contentView viewWithTag:999];
		[oldImage removeFromSuperview];
        
    }
    
  
/*
    cell.layer.borderWidth=2.0;
  cell.layer.borderColor = [UIColor blueColor].CGColor;
    cell.layer.cornerRadius=5.0;
    */
    cell.backgroundColor=[UIColor clearColor];
     tableView.separatorColor=[UIColor clearColor];
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
     
   
      
        
    [tableView setBackgroundView:nil];
    [tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    tableView.opaque=NO;
//   tableView.separatorColor=[UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.sectionHeaderHeight=0;
       
 
     //   self.searchDisplayController.searchResultsTableView.frame=self.tableView.frame;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
         
             [tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }else  [tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y-64, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    }
    for (id subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            if ([((UILabel *)subview).text isEqualToString:@"No Results"]) {
                ((UILabel *)subview).text=@"Non ci sono risultati" ;
                ((UILabel *)subview).textColor=[UIColor whiteColor];
            }
        }
    }

    
 //   CGRect rect = cell.frame;
    
 //   NSLog(@"Cell width = %f",rect.size.width);
 //    NSLog(@"Tableview x,y origin width = %f,%f",self.tableView.frame.origin.x,self.tableView.frame.origin.y);

	BOOL isFav = [[FavoritesData sharedFavoritesData] favoriteWithId:CellIdentifier] != nil ;
	NSString *starImage = isFav ? @"37x-Checkmark.png" : @"";
   
  //  UIImageView *check = (UIImageView *)[cell viewWithTag:8];

    
    UIImage *cellBackground = [UIImage imageNamed:starImage] ;
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
	
    
    NSString *link2 = [item1 objectForKey:@"descrizione"];
    link2=[link2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    link2 =[link2 stringByReplacingOccurrencesOfString:@"%0A" withString:@""];
    
   link2 = [link2 stringByReplacingOccurrencesOfString:@"livello: " withString:@"<image>"];
   link2 = [link2 stringByReplacingOccurrencesOfString:@"; location" withString:@"</image>"];
    
   // NSLog(@"link2: %@",   link2);
    NSString * foo3 =   link2;
    // vecchio reg
    // 	NSString * regex2 = @"^(.+?)</image>";
    NSString * regex3 = @"<image>(.*?)</image>";
    
	NSString *image1;
    
    //  if ([linkimg1 rangeOfString:@"http"].length == 0) {
    
    
    image1 = [foo3 stringByMatching:regex3 capture:1];
    image1 = [image1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    image1=[image1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    image1 =[image1 stringByReplacingOccurrencesOfString:@"%0A" withString:@""];
    
   // image1=[NSString stringWithFormat:@"%@ cm.",image1];
   
    int minThreshold = [image1 intValue];
    float stringFloat = [image1 floatValue];
    double myDecimal = stringFloat - minThreshold;
    if(myDecimal < 0.50)
    {
        //do nothing
    }
    else
    {
        minThreshold = minThreshold + 1;
    }
    
    
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    
    titleLabel.text = [item1 objectForKey:@"descrizione"];
    //  cell.backgroundColor=[UIColor redColor];
    UILabel *titleLabel1 = (UILabel *)[cell viewWithTag:11];
    
    titleLabel1.text = [NSString stringWithFormat:@"%i cm.", minThreshold ];
    
    NSString *linkimg = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"descrizione"];
    //  linkimg = [linkimg stringByReplacingOccurrencesOfString:@"image.php?src=" withString:@"<image>"];
    linkimg = [linkimg stringByReplacingOccurrencesOfString:@"src=\"" withString:@"<image>"];
    linkimg = [linkimg stringByReplacingOccurrencesOfString:@".jpg" withString:@".jpg</image>"];
    linkimg = [linkimg stringByReplacingOccurrencesOfString:@".png" withString:@".png</image>"];
    linkimg = [linkimg stringByReplacingOccurrencesOfString:@".gif" withString:@".gif</image>"];
    linkimg=[linkimg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    linkimg =[linkimg stringByReplacingOccurrencesOfString:@"%0A" withString:@""];
    
    
   // NSLog(@"linkimg: %@", linkimg);
    NSString * foo2 = linkimg;
    // vecchio reg
    // 	NSString * regex2 = @"^(.+?)</image>";
    NSString * regex2 = @"<image>(.*?)</image>";
    
    NSString *image = [foo2 stringByMatching:regex2 capture:1];
    image = [image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    image=[image stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    image =[image stringByReplacingOccurrencesOfString:@"%0A" withString:@""];
   
    UIImageView *background1;
    UIImage *cellBackground1 = [UIImage imageNamed:@"cropped-acqualtaVE_120.png"] ;
    if ([self.title isEqualToString:@"Livelli"]) {
        cellBackground1= [UIImage imageNamed:@""] ;
    }
    background1 = [[UIImageView alloc] initWithImage:cellBackground1];
    
    UIImageView *imgview = (UIImageView *)[cell viewWithTag:10];
    CGRect frame= imgview.frame;
    
    
    
   
    if ((minThreshold >=-50) && (minThreshold <=79)) {
        titleLabel1.textColor=[UIColor greenColor];
      //  cellBackground1 = [UIImage imageNamed:@"sea1.gif"];
        
        if (![self.title isEqualToString:@"News"]) {
        UIWebView *gifview =[[UIWebView alloc]initWithFrame:frame];
        NSString *imageFileName = @"sea1";
        NSString *imageFileExtension = @"gif";
        
        // load the path of the image in the main bundle (this gets the full local path to the image you need, including if it is localized and if you have a @2x version)
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:imageFileExtension];
        
        // generate the html tag for the image (don't forget to use file:// for local paths)
     //   NSString *imgHTMLTag = [NSString stringWithFormat:@"<img src=\"file://%@\" width=\"120&#37;\" />", imagePath];
        NSString *imgHTMLTag = [NSString stringWithFormat:@"<img STYLE=\"position:absolute; TOP:0px; LEFT:0px; WIDTH:100&#37;\" SRC=\"file://%@\"/>", imagePath];
        gifview.opaque=NO;
        gifview.backgroundColor=[UIColor clearColor];
        gifview.userInteractionEnabled=NO;
        //gifview.scalesPageToFit=YES;
        [gifview loadHTMLString:imgHTMLTag baseURL:[[NSBundle mainBundle] bundleURL]];
        
      //  NSLog(@"imghtmltag %@",imgHTMLTag);
      
        //  background1.contentMode = UIViewContentModeScaleAspectFill;
        CALayer * l3 = [gifview layer];
        [l3 setMasksToBounds:YES];
        [l3 setCornerRadius:5.0];
        // You can even add a border
        [l3 setBorderWidth:0.5];
        //   [l setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [l3 setBorderColor:[[UIColor clearColor] CGColor]];
        

        [cell addSubview:gifview];
        }
    }
    
    if ((minThreshold >=80) && (minThreshold <=109)) {
        titleLabel1.textColor=[UIColor yellowColor];
        cellBackground1 = [UIImage imageNamed:@"sea2.jpg"];
    }
    
    if ((minThreshold >=110) && (minThreshold <=139)) {
        titleLabel1.textColor=[UIColor orangeColor];
        cellBackground1 = [UIImage imageNamed:@"sea3.jpg"];
    }
        if ((minThreshold >=110)&& (minThreshold <=139)) {
        titleLabel1.textColor=[UIColor redColor];
        cellBackground1 = [UIImage imageNamed:@"sea4.jpg"];
    }
    
    
    
   
      // pv8.progress=stringFloat;
    NSLog(@"stringfloat %f",stringFloat);
//    }else{
        
       
        
        if (image == NULL){
            if ([self.title isEqualToString:@"News"]) {
                
                cellBackground1 = [UIImage imageNamed:@"cropped-acqualtaVE_120.png"] ;
                [cell bringSubviewToFront:background1];
                
            }
            
                        //  cellBackground1 = [UIImage imageNamed:@"mp-ico-72px.png"] ;
           
            
            background1.frame = frame;
            //  background1.contentMode = UIViewContentModeScaleAspectFill;
            CALayer * l1 = [background1 layer];
            [l1 setMasksToBounds:YES];
            [l1 setCornerRadius:5.0];
            // You can even add a border
            [l1 setBorderWidth:0.5];
            //   [l setBackgroundColor:[[UIColor whiteColor] CGColor]];
            [l1 setBorderColor:[[UIColor clearColor] CGColor]];
            
          
            
            [cell.contentView addSubview:background1];
        
     
        }else{
        
       
      //  UIImageView *background1;
            
            CALayer * l = [imgview layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:5.0];
            // You can even add a border
            [l setBorderWidth:0.5];
            [l setBorderColor:[[UIColor clearColor] CGColor]];
            
            AsyncImageView* asyncImage = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
            asyncImage.tag = 999;
            
            NSURL* url = [NSURL URLWithString:image];
            asyncImage.contentMode = UIViewContentModeScaleAspectFill;
            CALayer * l1 = [asyncImage layer];
            [l1 setMasksToBounds:YES];
            [l1 setCornerRadius:5.0];
            // You can even add a border
            [l1 setBorderWidth:0.5];
            [l1 setBorderColor:[[UIColor clearColor] CGColor]];
            //NSData *receivedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:image]];
            // [asyncImage loadImageFromURL:url];
            
            asyncImage.imageURL=url;
            [cell.contentView addSubview:asyncImage];
        

    }
   // }
   // [cell addSubview:pv8];
    
        // UIButton *button = (UIButton *)[cell.contentView.subviews objectAtIndex:0];

    NSString *link = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"pubDate"];
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
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    
    dateLabel.text = link;
    
  
    
    
	NSString *titolo1 = [item1 objectForKey:@"luogo"];
	
	
	UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:1];
  
	subtitleLabel.text = [titolo1 uppercaseString] ;
    subtitleLabel.textColor=titleLabel1.textColor;
    
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

// When the user taps a row in the table, display the USGS web page that displays details of the
// earthquake they selected.
//

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
   
    NSString *CellIdentifier = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"title"];
	
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
    
	UIImage *cellBackground =[UIImage imageNamed:@"IconCellOk.png"];
	UIImageView* background = [[UIImageView alloc] initWithImage:cellBackground];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		background.frame = CGRectMake(745, 15, 15, 15);
	}
	else {
        
       
            background.frame = CGRectMake(300, 10, 10, 10);
        
        
        
    }
	[cell.contentView addSubview:background];
	
	
    
	//background.contentMode = UIViewContentModeScaleAspectFill;
	CALayer * l1 = [background layer];
	[l1 setMasksToBounds:YES];
	[l1 setCornerRadius:5.0];
	// You can even add a border
	[l1 setBorderWidth:0.5];
	[l1 setBorderColor:[[UIColor clearColor] CGColor]];
	[cell.contentView addSubview:background];
	
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
	


    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *myPhotos = [[NSMutableArray alloc] init];
    NSMutableArray *myCaptions = [[NSMutableArray alloc] init];
    NSMutableArray *myTitles = [[NSMutableArray alloc] init];
    
    NSString *link1 = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"pubDate"];
   	
    
    
    NSString *link2 = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"bonifica"];
    
    
    
	//UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    if ([link2 rangeOfString:@"nessuna"].length != 0) {
      [myTitles addObject:link1];
    }else {
     [myTitles addObject:link2];
    }
	

    NSString *linkimg = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"file"];
    
    NSString *linkimmagina = [NSString stringWithFormat:@"http://www.ansamatic.it/wp-content/uploads/utenti/%@",linkimg];

    
    if (  [linkimg rangeOfString:@"noimmagine"].length == 0) {
    [myPhotos addObject:linkimmagina];
    
    [myCaptions addObject:[[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"luogo"]];
    

    
    MTGalleryViewController *controller = [[MTGalleryViewController alloc] initWithPhotos:myPhotos andCaptions:myCaptions andtitles:myTitles];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
      [self presentViewController:controller animated:YES completion:nil];
    
    [myPhotos release];
    [myCaptions release];
    
    [controller release];
    }
  */  /*
    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:
            NSLocalizedString(@"External App Sheet Title",
                              @"Title for sheet displayed with options for displaying Earthquake data in other applications")
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                 destructiveButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"Show INGV Site in Safari", @"Show INGV Site in Safari"),
                                        NSLocalizedString(@"Show Location in Maps", @"Show Location in Maps"),
                                        nil];
    [sheet showInView:self.view];
    [sheet release];
    */
    
    
    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 //   NSString *CellIdentifier = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"id"];
	
    NSDictionary *item1;
    NSString *CellIdentifier;
    
    
 
     if (tableView == self.searchDisplayController.searchResultsTableView){
    

        item1 = [[NSDictionary alloc] initWithDictionary:[filteredListItems objectAtIndex:indexPath.row]];
        //   CellIdentifier = [[filteredListItems objectAtIndex:indexPath.row] objectForKey:@"id"];
        CellIdentifier = [item1 objectForKey:@"luogo"];
        NSLog(@"sono nella tableview filtrata da cliccare");
       
    }else {
        item1 = [[NSDictionary alloc] initWithDictionary:[elencoFeed objectAtIndex:indexPath.row]];
         NSLog(@"sono nella tableview non filtrata da cliccare");
        CellIdentifier = [item1 objectForKey:@"luogo"];
        //  CellIdentifier = [[elencoFeed objectAtIndex:indexPath.row] objectForKey:@"id"];
    }
	
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
    if ([self.title isEqualToString:@"News"]) {
        
 
   	       NSString *titolo1 = [item1 objectForKey:@"luogo"];
         NSString *numscheda = [item1 objectForKey:@"link"];
   
      numscheda =[numscheda stringByReplacingOccurrencesOfRegex:@"%0A" withString:@""];
                
     numscheda=[  numscheda stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"Link da passare %@",numscheda);
        
    if (IS_IPAD)
    {
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloipad" bundle:nil];
        if ([self.title isEqualToString:@"Aziende"]) {
            controller.buttonoff=@"0";
        }
        controller.indirizzo = numscheda;
        controller.lat=[item1 objectForKey:@"lat"];
        controller.longi=[item1 objectForKey:@"long"];
        controller.www=[item1 objectForKey:@"www"];
       controller.emailaz=[item1 objectForKey:@"email"];
 NSLog(@"website e email %@ %@",controller.www,controller.emailaz);
controller.phone=[item1 objectForKey:@"phone"];
        controller.titolotext=titolo1;
         controller.indirizzoazienda=[item1 objectForKey:@"indirizzo"];
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
          [self presentViewController:controller animated:YES completion:nil];
     
    }else{
        
        ViewArticolo *controller = [[ViewArticolo alloc] initWithNibName:@"Articoloiphone" bundle:nil];
        controller.indirizzo = numscheda;
        controller.lat=[item1 objectForKey:@"lat"];
        controller.longi=[item1 objectForKey:@"long"];
        if ([self.title isEqualToString:@"Aziende"]) {
            controller.buttonoff=@"0";
        }
        controller.www=[item1 objectForKey:@"www"];
        controller.emailaz=[item1 objectForKey:@"email"];
      NSLog(@"website e email %@ %@",controller.www,controller.emailaz);
        controller.indirizzoazienda=[item1 objectForKey:@"indirizzo"];
        controller.phone=[item1 objectForKey:@"phone"];
        controller.titolotext=titolo1;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
          [self presentViewController:controller animated:YES completion:nil];
    }
       }
   
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	
	if (scopeButtonPressedIndexNumber == [NSNumber numberWithInt:1] || scopeButtonPressedIndexNumber == [NSNumber numberWithInt:2]) {
        //   	if (scopeButtonPressedIndexNumber != nil) {
        return NO;
	}
	else {
    	return YES;
	}
    
    [self.searchDisplayController setActive:YES animated:NO];
    
    // Hand over control to UISearchDisplayController during the search
    searchBar.delegate = (id <UISearchBarDelegate>)self.searchDisplayController;
    
	
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller

{
    if ([search.text isEqualToString:@""]) {
        self.tableView.hidden=NO;
    }
    [controller.searchBar setShowsCancelButton:NO];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [search setShowsCancelButton:NO];
    [searchBar setShowsCancelButton:NO animated:true];
 //   self.tableView.allowsSelection = NO;
 //   self.tableView.scrollEnabled = NO;
   
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    self.tableView.hidden=NO;

    [searchBar setShowsCancelButton:NO animated:YES];
  //  [searchBar resignFirstResponder];
  //  self.tableView.allowsSelection = YES;
  //  self.tableView.scrollEnabled = YES;
}




-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [search setShowsCancelButton:NO];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    if (search.text !=nil) {
        [filteredListItems removeAllObjects]; // First clear the filtered array.
      
    }
    
    if(searchText.length == 0)
    {
        isFiltered = FALSE;
    }
    else
    {
        isFiltered = TRUE;
        
        filteredListItems = [[NSMutableArray alloc] init];
        NSLog(@"text da cercare =%@",searchText);
        for (NSDictionary *item1 in elencoFeed)
        {
            self.tableView.hidden=YES;
         
            /*
            NSRange nameRange = [[item1 objectForKey:@"luogo"] rangeOfString:search.text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound)
            {
                [filteredListItems addObject:item];
            }*/
            NSComparisonResult result = [[item1 objectForKey:@"luogo"] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
                
            if (result == NSOrderedSame)
			{
                [filteredListItems addObject:item1];
                [self.tableView reloadData];
             
            }
        }
    }
    
    if ([search.text isEqual:@""]) {
        self.tableView.hidden=NO;
    }
    NSLog(@"filtered %i",isFiltered);
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSLog(@"cliccato cerca");
   // [self.tableView becomeFirstResponder];
 //   [self.tableView resignFirstResponder];
    
    // searchBar.showScopeBar = YES;
    //[self setShowsScopeBar:YES]; // I tried it explicitly, but did not help
}

- (void)searchDisplayController: (UISearchDisplayController *)controller
 willShowSearchResultsTableView: (UITableView *)searchTableView {
  //  search.showsScopeBar = YES;
    searchTableView.rowHeight = self.tableView.rowHeight;
    
    [self.view bringSubviewToFront:barra];
    [self.view bringSubviewToFront:refresh];
    [self.view bringSubviewToFront:toolBar];
    if ([search.text isEqualToString:@""]) {
        self.tableView.hidden=NO;
    //    search.showsScopeBar = YES;
    }
    
    
}


- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView{
    
       NSLog(@"Sono nel didLoadSearchResultsTableView");
    
    [tableView initWithFrame:self.tableView.frame style:self.tableView.style];
    
    
    
    [tableView setBackgroundView:nil];
    [tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    tableView.opaque=NO;
    tableView.separatorColor=self.tableView.separatorColor;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.sectionHeaderHeight=0;
    
    if ([search.text isEqualToString:@""]) {
        self.tableView.hidden=NO;

        [super navigationController];
    }
    
    [self.view bringSubviewToFront:barra];
    [self.view bringSubviewToFront:refresh];
      [self.view bringSubviewToFront:toolBar];
   
    for (id subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            if ([((UILabel *)subview).text isEqualToString:@"No Results"]) {
                ((UILabel *)subview).text=@"Non ci sono risultati" ;
                ((UILabel *)subview).textColor=[UIColor whiteColor];
            }
        }
    }
    
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView  {
    
    NSLog(@"finita la ricerca");
    tableView.frame = self.tableView.frame;
   
    
    NSLog(@"search table origin x,y: %f,%f",tableView.frame.origin.x,tableView.frame.origin.x);
   // if (!IS_IPAD) {
        //  sfondotabella.image=[UIImage imageNamed:@"mp-sfondo_ipad.jpg"];
        tableView.sectionHeaderHeight=18;
        
        [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y+20, tableView.frame.size.width, tableView.frame.size.height)];
        
  //  }
    
 
   // [self.view sendSubviewToBack:tableView];

    [self.view bringSubviewToFront:barra];
    [self.view bringSubviewToFront:refresh];
      [self.view bringSubviewToFront:toolBar];
    
    for (id subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            if ([((UILabel *)subview).text isEqualToString:@"No Results"]) {
                ((UILabel *)subview).text=@"Non ci sono risultati" ;
                ((UILabel *)subview).textColor=[UIColor whiteColor];
            }
        }
    }
}




- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  //  [self changeNoResultsText:@"Searching full search..."];
    return YES;

}



- (UINavigationController *)navigationController {
    return nil;
}



- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController
                                                *)controller {
    // Un-hide the navigation bar that UISearchDisplayController hid
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController
                                               *)controller {
    UISearchBar *searchBar = (UISearchBar *)self.navigationItem.titleView;
    
    // Manually resign search mode
    [searchBar resignFirstResponder];
 
    // Take back control of the search bar
    searchBar.delegate = self;
    // search.delegate=self;
    //  search.showsScopeBar = YES;
    NSLog(@"sono qui");
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