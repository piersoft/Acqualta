//	Mappa.m
//  Acqualta VE
//
//  Created by Francesco Piero Paolicelli on 11/04/11.
//  Copyright 2011 piersoft.it. All rights reserved.
//


#import "MyAnnotation.h"
#import "UserProfileVC.h"
#import	"Mappa.h"
#import "shopPoint.h"
#import "ViewArticolo.h"
#import "asyncimageview.h"
#import "NSString+SBJSON.h"

#import "TileOverlay.h"
#import "TileOverlayView.h"


#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
@implementation Mappa

//@synthesize window=_window;
@synthesize mapView,userProfileVC;
@synthesize segmentposizione,cmdMiaPosizione,indirizzoshare,feed,feedsubtit,feedlat,feedlon,titlemap,toolbar,barra,linkdapassare,overlay;

@synthesize lineColor, origine, destinazione;

- (IBAction)osmclass
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.openstreetmap.org/copyright"]];
}

- (IBAction)gestioneZoom:(id)sender{
	//if (switchZoom.on){
    mapView.zoomEnabled=TRUE;
	/*} else {
     mapView.zoomEnabled=FALSE;
     }*/
    
}

- (IBAction)gestioneScroll:(id)sender{
	//if (switchScroll.on){
    mapView.scrollEnabled=TRUE;
	/*} else {
     mapView.scrollEnabled=FALSE;
     }*/
    
}
#pragma mark -
#pragma mark View lifecycle

+ (CGFloat)annotationPadding;

{
    
    return 10.0f;
    
}

+ (CGFloat)calloutHeight;

{
    
    return 40.0f;
    
}

-(IBAction) scegliPercorso
{
	//NSLog(@"ActionSheetViewController::alert");
    //	appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
	UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Vuoi calcolare il percorso? Verrà attivato il GPS"
                                  delegate:self
                                  cancelButtonTitle:@"Annulla"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: @"Percorso in macchina",@"Percorso a piedi",
                                  nil
								  ];
	//[actionsheet showInView:[self view]];
	[actionsheet showInView:self.view];
    [actionsheet release];
    
    
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"button %li clicked", (long)buttonIndex );
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:10];
    segmentposizione.selectedSegmentIndex=1;
    mapView.showsUserLocation = YES;
    
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    //calcolo il percorso
    switch (buttonIndex) {
		case 0: {
            
            
            mytimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(macchina) userInfo:nil repeats:NO];
            break;
            
        }
            
		case 1:{
            
            
            mytimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(piedi) userInfo:nil repeats:NO];
            break;
        }
		default: break;
            
	}
    
    
    
    
}

-(void)macchina{
    [self showRouteFrom:origine to:destinazione typePath:nil];
}
-(void)piedi{
    [self showRouteFrom:origine to:destinazione typePath:@"w"];
    
}


- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.hud = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)timeout:(id)arg {
    
    _hud.labelText = nil;
    _hud.detailsLabelText = nil;
    _hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:0.5];
    //   [self.tableView reloadData];
    
}

- (void)gotoLocation
{
    // start off by default in Venezia
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 45.4301;
    newRegion.center.longitude = 12.3260;
	//MKCoordinateSpan span;
	//span.latitudeDelta=0.3;
	//span.longitudeDelta=0.3;
    
    newRegion.span.latitudeDelta = 0.2;
    newRegion.span.longitudeDelta = 0.2;
	
    [self.mapView setRegion:newRegion animated:YES];
    
    
}

-(void)gotoosm{
    overlay = [[TileOverlay alloc] initOverlay];
    [mapView addOverlay:overlay];
    MKMapRect visibleRect = [mapView mapRectThatFits:overlay.boundingMapRect];
    visibleRect.size.width /= 2;
    visibleRect.size.height /= 2;
    visibleRect.origin.x += visibleRect.size.width / 2;
    visibleRect.origin.y += visibleRect.size.height / 2;
    mapView.visibleMapRect = visibleRect;
    // start off by default in Venezia
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 45.4301;
    newRegion.center.longitude = 12.3260;
	//MKCoordinateSpan span;
	//span.latitudeDelta=0.3;
	//span.longitudeDelta=0.3;
    
    newRegion.span.latitudeDelta = 0.2;
    newRegion.span.longitudeDelta = 0.2;
	
    [self.mapView setRegion:newRegion animated:YES];
    
    
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)ovl
{
    TileOverlayView *view = [[TileOverlayView alloc] initWithOverlay:ovl];
    view.tileAlpha = 1.0; // e.g. 0.6 alpha for semi-transparent overlay
    return [view autorelease];
}

#pragma mark ADBannerViewDelegate


- (void)parseXMLFileAtURL:(NSString *)URL {
	// inizializziamo la lista degli elementi
	elencoFeed = [[NSMutableArray alloc] init];
	
	// dobbiamo convertire la stringa "URL" in un elemento "NSURL"
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


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
	
	
	
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		// inizializza tutti gli elementi
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentCategory = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		currentImage = [[NSMutableString alloc] init];
		currentLat= [[NSMutableString alloc] init];
        currentLong= [[NSMutableString alloc] init];
        currentCheck =[[NSMutableString alloc] init];
        currentAddr =[[NSMutableString alloc] init];
        currentWWW = [[NSMutableString alloc] init];
        currentEmail = [[NSMutableString alloc] init];
	}
	
	
    else if ([currentElement isEqualToString:@"enclosure"])
    {
        
        
        currentImage = [[NSMutableString alloc] init];
        [currentImage appendString:[attributeDict objectForKey:@"url"]];
    }
    
    /*
	 else if ([currentElement isEqualToString:@"media:content"])
	 {
	 
	 [currentImage appendString:[attributeDict objectForKey:@"url"]];
	 }
	 */
	
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    
	if ([elementName isEqualToString:@"item"]) {
        
		/* salva tutte le proprietà del feed letto nell'elemento "item", per
         poi inserirlo nell'array "elencoFeed" */
		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentSummary forKey:@"summary"];
		[item setObject:currentCheck forKey:@"phone"];
		[item setObject:currentCategory forKey:@"category"];
        [item setObject:currentAddr forKey:@"addr"];
        [item setObject:currentImage forKey:@"image"];
        [item setObject:currentWWW forKey:@"www"];
        [item setObject:currentEmail forKey:@"email"];
        
        [item setObject:currentLong forKey:@"longitudine"];
		[item setObject:currentLat forKey:@"latitudine"];
        //     par=par+1;
        //    _hud.labelText = [NSString stringWithFormat: @"%f", (float)par/ (float) 150*100];
        //   NSLog(@"textperce %@",_hud.labelText);
        [elencoFeed addObject:[item copy]];
        
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
		[currentSummary appendString:string];
		
	}else if ([currentElement isEqualToString:@"indirizzo"])
	{
		[currentAddr appendString:string];
		
	} else if ([currentElement isEqualToString:@"category"]) {
		
        
        [currentCategory appendString:string];
        
        
		
		
		//NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
		//[self.currentImage setString: [currentImage stringByTrimmingCharactersInSet: charsToTrim]];
		
    }
    else if ([currentElement isEqualToString:@"content:encoded"])
	{
        //	[currentImage appendString:string];
		
	}else if ([currentElement isEqualToString:@"website"])
	{
		[currentWWW appendString:string];
		
	} else if ([currentElement isEqualToString:@"email"])
	{
		[currentEmail appendString:string];
		
	}
    else if ([currentElement isEqualToString:@"latitudine"])
	{
		[currentLat appendString:string];
		
	}
    else if ([currentElement isEqualToString:@"longitudine"])
	{
		[currentLong appendString:string];
		
	}
    else if ([currentElement isEqualToString:@"telefono"])
	{
		[currentCheck appendString:string];
		
	}
}

-(void)stophud{
    //  [self performSelectorInBackground:@selector(dismissHUD:) withObject:nil];
    mytimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissHUD:) userInfo:nil repeats:NO];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
	
    //  [MBProgressHUD hideHUDForView:self.view animated:YES];
    // self.hud = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // [self performSelector:@selector(timeout:) withObject:nil afterDelay:2];
    [UIApplication sharedApplication].statusBarStyle=UIBarStyleDefault;
    
	//   [self performSelector:@selector(zoom) withObject:nil afterDelay:0];
    
    
    
    //    destinazione = [[Place alloc] init];
    shopPoints = [[NSMutableArray alloc] init];
	shopPoint *myAnnotation;
    
    
	
    for (int i=0; i<=[elencoFeed count]-1; i++) {
        //   [MBProgressHUD hideHUDForView:self.view animated:YES];
        //      self.hud = nil;
        //    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        par=i;
        _hud.labelText = [NSString stringWithFormat: @"%f", (float)par/ (float)[elencoFeed count]*100];
        //    NSLog(@"textperce %@",_hud.labelText);
        //    NSLog(@"float %f",(float)par/ (float)[elencoFeed count]*100);
        //     if (i==[elencoFeed count]-1 && [feed rangeOfString:@"cat=-5%2C16,-19,-21"].length==0) {
        if (i==[elencoFeed count]-1 ) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //   self.hud = nil;
            
            MKMapRect flyTo = MKMapRectNull;
            for (id <MKAnnotation> annotation in shopPoints) {
                
                //     NSLog(@"Vai verso l'insieme dei POI centrando la mappa");
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
                if (MKMapRectIsNull(flyTo)) {
                    flyTo = pointRect;
                } else {
                    flyTo = MKMapRectUnion(flyTo, pointRect);
                    //NSLog(@"else-%@",annotationPoint.x);
                }
                
                
                
            }
            
            /*
             mapView.visibleMapRect = flyTo;
             
             MKCoordinateRegion region;
             //Set Zoom level using Span
             CGContextRef context = UIGraphicsGetCurrentContext();
             [UIView beginAnimations:nil context:context];
             MKCoordinateSpan span;
             region.center=mapView.region.center;
             
             span.latitudeDelta=mapView.region.span.latitudeDelta *1.2;
             span.longitudeDelta=mapView.region.span.longitudeDelta *1.2;
             region.span=span;
             
             [UIView setAnimationDuration:0.50];
             [mapView setRegion:region animated:YES];
             [UIView commitAnimations];
             */
            //  [self performSelector:@selector(zoom) withObject:nil afterDelay:2];
            
            //    [self performSelector:@selector(timeout:) withObject:nil afterDelay:2];
        }
        NSString *title=[[elencoFeed objectAtIndex:i] objectForKey:@"title"];
        NSString *addr=[[elencoFeed objectAtIndex:i] objectForKey:@"addr"];
        addr=[addr stringByReplacingOccurrencesOfRegex:@"\n" withString:@""];
        /*
         title = [title stringByReplacingOccurrencesOfString:@" " withString:@""];
         title = [title stringByReplacingOccurrencesOfString:@"  " withString:@""];
         title = [title stringByReplacingOccurrencesOfString:@"   " withString:@""];
         title = [title stringByReplacingOccurrencesOfString:@"    " withString:@""];
         title = [title stringByReplacingOccurrencesOfString:@"     " withString:@""];
         title = [title stringByReplacingOccurrencesOfString:@"      " withString:@""];
         */
        title= [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *link=[[elencoFeed objectAtIndex:i] objectForKey:@"link"];
        
        link=[link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //    NSString *check=[[elencoFeed objectAtIndex:i] objectForKey:@"descrizione"];
        
        //    check=[check stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *subtitle=[[elencoFeed objectAtIndex:i] objectForKey:@"category"];
        subtitle=[subtitle stringByReplacingOccurrencesOfRegex:@"\n" withString:@""];
        // if ([subtitle rangeOfString:@"Sede"].length != 0 )
        // {
        subtitle=addr;
        // }
        /*
         NSString *linkimg1 =[[elencoFeed objectAtIndex:i] objectForKey:@"summary"];
         
         linkimg1 = [linkimg1 stringByReplacingOccurrencesOfString:@"Rating: " withString:@"<rate>Rating:"];
         linkimg1 = [linkimg1 stringByReplacingOccurrencesOfString:@"<strong>" withString:@""];
         linkimg1 = [linkimg1 stringByReplacingOccurrencesOfString:@"</strong>" withString:@"</rate>"];
         
         
         linkimg1=[linkimg1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
         
         
         
         
         NSLog(@"linkimg: %@", linkimg1);
         NSString * foo1 = linkimg1;
         // vecchio reg
         // 	NSString * regex2 = @"^(.+?)</image>";
         NSString * regex1 = @"<rate>(.*?)</rate>";
         
         NSString *image1 = [foo1 stringByMatching:regex1 capture:1];
         
         image1 = [image1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         image1=[image1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
         
         
         NSLog(@"Match Rating: %@", image1);
         */
        NSString *image =[[elencoFeed objectAtIndex:i] objectForKey:@"image"];
        
        NSString *idsens =[[elencoFeed objectAtIndex:i] objectForKey:@"www"];
        idsens=[NSString stringWithFormat:@"ID: %@",idsens];
        image=[image stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //image=[image stringByReplacingOccurrencesOfString:@".jpg" withString:@"-150x150.jpg"];
        
        NSString *checklat=[[elencoFeed objectAtIndex:i] objectForKey:@"latitudine"] ;
        //    NSLog (@"chcklat =%@",checklat);
        NSString *checklng=[[elencoFeed objectAtIndex:i] objectForKey:@"longitudine"] ;
        //    NSLog (@"chcklnd =%@",checklng);
        checklat=[checklat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([checklat rangeOfString:@"."].length == 0){
            checklat=@"40.665568";
            checklng=@"16.601111";
        }
        // if (checklat !=@"0") {
		myAnnotation = [[[shopPoint alloc] init] autorelease];
        
        
        myAnnotation.latitude = [checklat floatValue];
        
        myAnnotation.longitude = [checklng floatValue];
        
        myAnnotation.title = [title
                              copy] ;
        
        //    myAnnotation.subtitle = [image1 copy] ;
        //     myAnnotation.subtitle = [subtitle copy] ;
        myAnnotation.link = [link
                             copy] ;
        myAnnotation.immagine = [image
                                 copy] ;
        //    myAnnotation.pin = [check
        //copy] ;
        
        // if ([idsens rangeOfString:@"nessuna"].length == 0) {
        myAnnotation.subtitle =[idsens
                                copy] ;
        
        // }
        
        
        //   NSLog(@"links =%@",myAnnotation.link);
        //	NSLog(@"Immagini =%@",myAnnotation.immagine);
        //   NSLog(@"pin =%@",myAnnotation.pin);
        //  NSLog(@"lat =%f",myAnnotation.latitude);
        //	NSLog(@"Iong =%f",myAnnotation.longitude);
        //  NSLog(@"subtitile =%@",myAnnotation.subtitle);
        //  NSLog(@"title =%@",myAnnotation.title);
        
        [shopPoints addObject:myAnnotation];
        
        [mapView addAnnotations:shopPoints];
        
    }
    
    
    
    //    destinazione.name = myAnnotation.title;
    //    destinazione.description = myAnnotation.subtitle;
    //    destinazione.latitude = myAnnotation.latitude;
    //    destinazione.longitude = myAnnotation.longitude;
    
    // [self showMap:destinazione];
    
    
    // per ora non serve usando il performbackground    mytimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(zoom) userInfo:nil repeats:NO];
    
    
    mytimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(zoom) userInfo:nil repeats:NO];
    
}


-(void)zoom{
    //   NSLog(@"Numero POI =%d",[shopPoints count]);
    
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKAnnotation> annotation in shopPoints) {
        
        //   NSLog(@"Vai verso l'insieme dei POI centrando la mappa");
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
            //NSLog(@"else-%@",annotationPoint.x);
        }
        
        // Position the map so that all overlays and annotations are visible on screen.
        
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:0.1];
        
        
    }
    
    
    mapView.visibleMapRect = flyTo;
    
	MKCoordinateRegion region;
    //Set Zoom level using Span
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    MKCoordinateSpan span;
    region.center=mapView.region.center;
    
    span.latitudeDelta=mapView.region.span.latitudeDelta *2;
    span.longitudeDelta=mapView.region.span.longitudeDelta *2;
    region.span=span;
    
    [UIView setAnimationDuration:0.30];
    [mapView setRegion:region animated:YES];
    [UIView commitAnimations];
    
}
- (void)viewDidLoad {
    
    
    
    [super viewDidLoad];
    par=0;
    chiese=0;
    
    
    percorsobutton.enabled=NO;
    percorsotextview.hidden=YES;
    
    routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
    routeView.userInteractionEnabled = NO;
    //    mapView.showsUserLocation = YES;
    [mapView addSubview:routeView];
    
    self.lineColor = [UIColor colorWithRed:0 green:0 blue:255 alpha:1.0];
    
    /*
     [self.mapView.userLocation addObserver:self
     forKeyPath:@"location"
     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
     context:NULL];
     
     */
    //Recupero la posizione corrente con il LOCATION MANAGER (vedi il metodo didUpdateLocation)
    
    [mapView setDelegate:self];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    
    
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //   _hud.labelText = @"";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:45];
    
    mytimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(inizio) userInfo:nil repeats:NO];
    
    
    
}




-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
		NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
		printf("[%f,", [latitude doubleValue]);
		printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
		[array addObject:loc];
	}
	
	return array;
}




-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t typePath:(NSString*)type{
	
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
    //type=h (percorso in macchina-evita strade principali "Avoid Highways")
    //type=t (percorso in macchina-evita pedaggi "Avoid Tolls")
    //type=w (percorso a piedi)
    //type=null (nil) (percorso in macchina)
    
    
	NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?dirflg=%@&output=dragdir&saddr=%@&daddr=%@", type, saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    //	NSLog(@"api url: %@", apiUrl);
	NSError *error = nil;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
	
    
    //  NSLog(@"apiResponse: %@", apiResponse);
    
    //Recupero la distanza in metri
    NSString *tooltip = [apiResponse stringByMatching:@"tooltipHtml:\\\" ([^\\\"]*)\\\"" capture:1L];
    
    tooltip = [tooltip stringByReplacingOccurrencesOfString:@"\\x26#160;"
                                                 withString:@" "];
    
    //visualizzo a video la distanza e il tempo di percorrenza
    //stampo il risultato a video
    if(tooltip!=nil){
        UIFont *customFont = [UIFont fontWithName:@"HiraKakuProN-W6" size:12];
        
        UILabel *distanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 44, 320, 24)] autorelease];
        distanceLabel.font=customFont;
        // distanceLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
        //distanceLabel.shadowColor = [UIColor blackColor];
        distanceLabel.shadowOffset = CGSizeMake(1,1);
        distanceLabel.textColor = [UIColor whiteColor];
        distanceLabel.text = [NSString stringWithFormat:@"Distanza/Tempo: %@", tooltip];
        distanceLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:169.0/255.0 blue:208.0/255.0 alpha:0.7];
        distanceLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:distanceLabel];
    }
    
    
    NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    
    if(encodedPoints!=nil && [encodedPoints length] > 0){
        
        NSMutableString *encodedPointsMutable = [[NSMutableString alloc] initWithString:encodedPoints];
        
        NSArray * array = [self decodePolyLine:encodedPointsMutable];
        [encodedPointsMutable release];
        
        return array;
        
    }
    else
    {
        return nil;
    }
    
	
	
}


-(void) centerMap1 {
	MKCoordinateRegion region;
    
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
    // NSLog(@"contiamo i percorsi %i",[routes count]);
	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLocation = [routes objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[mapView setRegion:region animated:TRUE];
}

-(void) centerMap {
    //  NSLog(@"Numero POI =%d",[shopPoints count]);
    
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKAnnotation> annotation in shopPoints) {
        
        //     NSLog(@"Vai verso l'insieme dei POI centrando la mappa");
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
            //NSLog(@"else-%@",annotationPoint.x);
        }
        
        // Position the map so that all overlays and annotations are visible on screen.
        
        //  [self performSelector:@selector(timeout:) withObject:nil afterDelay:0.1];
        
        
    }
    mapView.visibleMapRect = flyTo;
    
	MKCoordinateRegion region;
    //Set Zoom level using Span
    MKCoordinateSpan span;
    region.center=mapView.region.center;
    span.latitudeDelta=mapView.region.span.latitudeDelta *1.5;
    span.longitudeDelta=mapView.region.span.longitudeDelta *1.5;
    region.span=span;
    [mapView setRegion:region animated:TRUE];
}



/*
 questa funzione disegna un solo punto (la destinazione) sulla mappa
 */

-(void) showMap: (Place*) t{
    
}




/*
 questa funzione disegna il tracciato tra l'origine e la destinazione sulla mappa
 */
-(void) showRouteFrom: (Place*) f to:(Place*) t typePath:(NSString*)type{
	
	if(routes) {
        
        [mapView removeAnnotations:[mapView annotations]];
        [routes release];
        
		
        //  PlaceMark* to = [[[PlaceMark alloc] initWithPlace:t] autorelease];
        //  [mapView addAnnotation:to];
	}
	
	PlaceMark* from = [[[PlaceMark alloc] initWithPlace:f] autorelease];
	PlaceMark* to = [[[PlaceMark alloc] initWithPlace:t] autorelease];
	
	//[mapView addAnnotation:from];
	//[mapView addAnnotation:to];
  	
	routes = [[self calculateRoutesFrom:from.coordinate to:to.coordinate typePath:type] retain];
	if(routes != nil){
        [self updateRouteView];
        [self centerMap1];
        NSLog(@"Sono qui senza errori");
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Errore"
                              message:@"Spiacenti, non è stato possibile calcolare il percorso! Hai selezionato un punto di interesse?"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:0];
    }
    
	
}




-(void) updateRouteView {
    
    
}


/** calcolo del percorso in metri **/
- (id)calculateRoutesDistanceFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    
    CLLocation *locationFrom = [[CLLocation alloc] initWithLatitude:f.latitude longitude:f.longitude];
    CLLocation *locationTo = [[CLLocation alloc] initWithLatitude:t.latitude longitude:t.longitude];
    distance = [locationFrom distanceFromLocation:locationTo];
    
    //[self performSelectorInBackground:@selector(reverseGeocode) withObject:nil];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"reverse geocoding...");
    NSString *reverseGeocoder = [NSString stringWithFormat:
                                 @"http://maps.google.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",
                                 destinazione.latitude,
                                 destinazione.longitude];
	NSString *response = [NSString stringWithContentsOfURL:[NSURL URLWithString:reverseGeocoder]
                                                  encoding:NSUTF8StringEncoding error:nil];
    id data = [response JSONValue];
    if (!data || [data count] == 0) return self;
    if ([data isKindOfClass:[NSArray class]]) data = [data objectAtIndex:0];
    if (![data isKindOfClass:[NSDictionary class]]) return self;
    data = [data objectForKey:@"results"]; if (!data || [data count] == 0) return self;
    if ([data isKindOfClass:[NSArray class]]) data = [data objectAtIndex:0];
    if (![data isKindOfClass:[NSDictionary class]]) return self;
    
    //NSLog(@"%@", data);
    //data = [data objectForKey:@"formatted_address"]; if (!data) return;
    
    data = [data objectForKey:@"address_components"]; if (!data) return self;
    // array with hash
    //   NSString *streetNumber = [[(NSArray*)data objectAtIndex:0] objectForKey:@"short_name"];
    //    NSString *streetName = [[(NSArray*)data objectAtIndex:1] objectForKey:@"short_name"];
    
    
    
    
    //converto i metri in KM
    //distance = distance/1000;
    
    
    //stampo il risultato a video
  	if(routes != nil){
        UILabel *distanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 44, 320, 24)] autorelease];
        
        distanceLabel.text = [NSString stringWithFormat:@"Distanza aerea (in metri): %.0f", distance];
        [self.view addSubview:distanceLabel];
    }
    [locationFrom release];
    [locationTo release];
    
    [pool release];
    
    return self;
}


#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(routes != nil){
        [self updateRouteView];
    }
    
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D here =  newLocation.coordinate;
    NSLog(@"CLLocationCoordinate2D %f  %f ", here.latitude, here.longitude);
    
	origine = [[Place alloc] init];
    //	origine.name = @"Tu";
    //	origine.description = @"Tu sei qui!";
    
	origine.latitude =  here.latitude;
	origine.longitude = here.longitude;
}



-(IBAction)goBack {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"image"];
    //  feed=nil;
    //  [feed release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    mapView.showsUserLocation = NO;
    locationManager.delegate = nil;
    [locationManager stopUpdatingLocation];
    mapView = nil;
    [overlay release];
    [mapView release];
    
    // [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)inizio1{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:nil forKey:@"image"];
    
    NSString *path = feed;
    NSLog(@"Feed categoria mappa %@",feed);
    //    [self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
    [self parseXMLFileAtURL:path];
    
}

-(void)inizio{
    
    NSLog(@"sono in inizio per singolo pin");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    if ([prefs objectForKey:@"scheda"]==nil) {
        
        [prefs setObject:@"1" forKey:@"scheda"];
        
        
        [prefs setObject:nil forKey:@"image"];
        
        NSString *path = feed;
        //  [self performSelectorInBackground:@selector(parseXMLFileAtURL:) withObject:path];
        
        [self parseXMLFileAtURL:path];
        //   [self performSelector:@selector(timeout:) withObject:nil afterDelay:5];
        
        
    } else{
        
        NSLog(@"sono in una scheda");
        
        // [self performSelector:@selector(timeout:) withObject:nil afterDelay:0];
        
        item = [[NSMutableDictionary alloc] init];
        elencoFeed = [[NSMutableArray alloc] init];
		/*
         currentTitle = [[NSMutableString alloc] init];
         currentCategory = [[NSMutableString alloc] init];
         currentSummary = [[NSMutableString alloc] init];
         currentLink = [[NSMutableString alloc] init];
         currentImage = [[NSMutableString alloc] init];
         currentLat= [[NSMutableString alloc] init];
         currentLong= [[NSMutableString alloc] init];
         currentCheck =[[NSMutableString alloc] init];
         */
        
        
        //     NSString *img=[prefs valueForKey:@"image"];
        //     NSString *subt=[prefs valueForKey:@"subtitle"];
        [item setObject:feed forKey:@"title"];
		[item setObject:linkdapassare forKey:@"link"];
        //    	[item setObject:@"" forKey:@"link"];
		[item setObject:@"" forKey:@"summary"];
		[item setObject:@"" forKey:@"check"];
        
        [item setObject:feedlon forKey:@"longitudine"];
		[item setObject:feedlat forKey:@"latitudine"];
        
        
        
        
        [elencoFeed addObject:[item copy]];
        
        //    NSLog(@"elenco feed singolo PIN %@",elencoFeed);
        
        //    destinazione = [[Place alloc] init];
        shopPoints = [[NSMutableArray array] retain];
        shopPoint *myAnnotation;
        
        
        NSString *idsensore=[[elencoFeed objectAtIndex:0] objectForKey:@"www"];
        NSString *title=[[elencoFeed objectAtIndex:0] objectForKey:@"title"];
        
        title= [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *link=[[elencoFeed objectAtIndex:0] objectForKey:@"link"];
        
        link=[link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"link per singola scheda %@",link);
        NSString *check=[[elencoFeed objectAtIndex:0] objectForKey:@"descrizione"];
        
        check=[check stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *subtitle=[[elencoFeed objectAtIndex:0] objectForKey:@"category"];
        subtitle=[subtitle stringByReplacingOccurrencesOfRegex:@"\n" withString:@""];
        
        NSString *image =[[elencoFeed objectAtIndex:0] objectForKey:@"image"];
        
        image=[image stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //image=[image stringByReplacingOccurrencesOfString:@".jpg" withString:@"-150x150.jpg"];
        
		myAnnotation = [[[shopPoint alloc] init] autorelease];
        myAnnotation.latitude = [[[elencoFeed objectAtIndex:0] objectForKey:@"latitudine"] floatValue];
        
        myAnnotation.longitude = [[[elencoFeed objectAtIndex:0] objectForKey:@"longitudine"] floatValue];
        
        myAnnotation.title = [title
                              copy] ;
        
        //    myAnnotation.subtitle = [image1 copy] ;
        myAnnotation.subtitle = [subtitle copy] ;
        myAnnotation.link = [link
                             copy] ;
        
        myAnnotation.immagine = [image
                                 copy] ;
        myAnnotation.pin = [check
                            copy] ;
        
        //  if ([idsensore rangeOfString:@"nessuna"].length == 0) {
        myAnnotation.subtitle =[idsensore
                                copy] ;
        
        // }
        
		[shopPoints addObject:myAnnotation];
        
        //    NSLog(@"links =%@",myAnnotation.link);
        //	NSLog(@"Immagini =%@",myAnnotation.immagine);
        //    NSLog(@"pin =%@",myAnnotation.pin);
        //    NSLog(@"lat =%f",myAnnotation.latitude);
        //	NSLog(@"Iong =%f",myAnnotation.longitude);
        //   NSLog(@"subtitile =%@",myAnnotation.subtitle);
        //   NSLog(@"title =%@",myAnnotation.title);
        
        
        
        [mapView addAnnotations:shopPoints];
        
        
        
        
        mytimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(zoom) userInfo:nil repeats:NO];
        
	}
}

-(void)carica{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *kelink=[prefs valueForKey:@"lk"];
    NSString *lk = nil;
    NSString *subt= nil;
    
    //    NSLog(@"sono in carica con link= %@",kelink);
    
    for (int i=0; i<=[shopPoints count]-1; i++) {
        
        NSString *title=[[elencoFeed objectAtIndex:i] objectForKey:@"title"];
        
        title= [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if([kelink isEqualToString:title] ){
            //      NSLog(@"shopdetails con button.title uguale a index %@",title);
            lk=[[elencoFeed objectAtIndex:i] objectForKey:@"link"];
            lk = [lk stringByReplacingOccurrencesOfString:@" " withString:@""];
            lk = [lk stringByReplacingOccurrencesOfString:@"  " withString:@""];
            lk = [lk stringByReplacingOccurrencesOfString:@"   " withString:@""];
            lk = [lk stringByReplacingOccurrencesOfString:@"    " withString:@""];
            lk = [lk stringByReplacingOccurrencesOfString:@"     " withString:@""];
            lk = [lk stringByReplacingOccurrencesOfString:@"      " withString:@""];
            lk= [lk stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            //     NSLog(@"lk %@",lk);
            subt=[[elencoFeed objectAtIndex:i] objectForKey:@"subtitle"];
            
            NSString* sommario = [subt stripHtml];
            sommario = [sommario stringByReplacingOccurrencesOfString:@"  " withString:@""];
            sommario= [sommario stringByReplacingOccurrencesOfString:@"   " withString:@""];
            sommario = [sommario stringByReplacingOccurrencesOfString:@"    " withString:@""];
            sommario = [sommario stringByReplacingOccurrencesOfString:@"     " withString:@""];
            sommario = [sommario stringByReplacingOccurrencesOfString:@"      " withString:@""];
            sommario= [sommario stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if ([lk rangeOfString:@"cont=galleria"].length != 0) {
                //        NSLog(@"lancio galleria");
                indirizzoshare=lk;
                //        NSLog(@"lancio galleria");
                //    [self launchGallery];
                
                
            }  else if (([lk rangeOfString:@"youtube"].length != 0) || ([lk rangeOfString:@"youtu.be"].length != 0 )){
                
                lk=[lk stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                lk=[lk stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
                lk = [lk stringByReplacingOccurrencesOfString:@"http://www.youtube.com/watch?v=" withString:@"http://www.youtube.com/embed/"];
                //      NSLog(@"file di youtube");
                if (IS_IPAD)
                {
                    
                    
                }
                
                else{
                    
                    //	[self.navigationController pushViewController:controller animated:YES];
                }
                
                
                
            }else {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                }
                else {
                    
                }
                
                
            }
        }
        
    }
    
    
    
    
    
    
}

-(void)caricatimer{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = nil;
    _hud.detailsLabelText = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:10];
    mytimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(carica) userInfo:nil repeats:NO];
	
	
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        UIView *addStatusBar = [[UIView alloc] init];
        addStatusBar.frame = CGRectMake(0, 0, 768, 20);
        //  addStatusBar.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1]; //change this to match your navigation bar
        addStatusBar.backgroundColor = [UIColor whiteColor]; //change this to match your navigation bar
        
        [self.view addSubview:addStatusBar];
        
        
    } else
    {
        
        
        
        toolbar.tintColor=[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255 alpha:1];
    }
    
    if (IS_IPAD) {
        
        toolbar.frame=CGRectMake(0, 0, 768, 44);
        //   barra.frame=CGRectMake(0,40, 768, 20);
        [self.view bringSubviewToFront:barra];
        [self.view bringSubviewToFront:toolbar];
        
    }
    //   chieser.text=SHKLocalizedString(@"Rupestrian Churches");
    //   percorsotextview.text=SHKLocalizedString(@"Go there");
    [self gotoLocation];
	pin = 0;
    
    
    //	mapView.showsUserLocation = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(caricatimer) name:@"carica"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stoplocat1) name:@"stoploc"  object:nil];
    
    
    if (self.tabBarController.selectedIndex==1) {
        
        
    }
    
    
	self.navigationController.navigationBarHidden=YES;
    
	self.navigationItem.hidesBackButton=YES;
    //	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    // [self.view sendSubviewToBack:self.navigationController.navigationBar];
    if (IS_IPAD) {
        
        self.view.frame=CGRectMake(0,0, 768, 1024);
        toolbar.frame=CGRectMake(0, 20, 768, 44);
        
        //  barra.frame=CGRectMake(0,64, 768, 20);
        [self.view bringSubviewToFront:barra];
        [self.view bringSubviewToFront:toolbar];
        
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 && IS_IPAD) {
        barra.frame=CGRectMake(0,56, 768, 20);
        
    }
    segmentTipoMappa.selectedSegmentIndex=2;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"mappe.png"];
    }
    return self;
}





- (void)viewDidAppear:(BOOL)animated {
    
    
#ifdef DEBUGX
	NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
#endif
    
    
    [super viewDidAppear:animated];
}




-(void)stoplocat1{
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(stoplocat) userInfo:nil repeats:NO];
}
-(void)stoplocat{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    mapView.showsUserLocation = NO;
    locationManager.delegate = nil;
    [locationManager stopUpdatingLocation];
}
- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    mapView.showsUserLocation = NO;
    locationManager.delegate = nil;
    [locationManager stopUpdatingLocation];
    
	[super viewWillDisappear:animated];
}



#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    
	// Configure the cell.
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark -
#pragma mark Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//   	self.hidesBottomBarWhenPushed = YES;
//
//	DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"NIB" bundle:nil];
// ...
// Pass the selected object to the new view controller.
//[self.navigationController pushViewController:detailViewController animated:YES];
//[detailViewController release];

//}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    
	// Releases the view if it doesn't have a superview.
	
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
/*
 - (void)viewDidUnload {
 // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
 // For example: self.myOutlet = nil;
 }
 */

#pragma mark MKMapViewDelegate
/*
 - (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
 {
 return [kml viewForOverlay:overlay];
 }
 */



- (MKAnnotationView *)mapView:(MKMapView *)lmapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	
    //NSLog(@"Sezione annotazioni");
    
    
    
	
	// if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *pin2View = nil;
    
    static NSString *AnnotationViewID = @"annotationViewID";
	pin2View = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
    
	
	pin2View.canShowCallout=YES;
    
    // pin2View.pinColor=MKPinAnnotationColorRed;
	pin2View.image = [UIImage imageNamed:@"pinverde.png"];
    
	NSString *testo=nil;
    NSString *lk=nil;
    par=0;
    // [self performSelector:@selector(timeout:) withObject:nil afterDelay:0];
    for (int i=0; i<[shopPoints count]; i++) {
        
        
        
        if (i==[shopPoints count]-4) {
            
            
        }
        NSString *title=[[elencoFeed objectAtIndex:i] objectForKey:@"title"];
        
        title= [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *link=[[elencoFeed objectAtIndex:i] objectForKey:@"link"];
        
        link=[link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //    NSString *check=[[elencoFeed objectAtIndex:i] objectForKey:@"check"];
        
        //    check=[check stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *subtitle=[[elencoFeed objectAtIndex:i] objectForKey:@"www"];
        NSString *link2=[[elencoFeed objectAtIndex:i] objectForKey:@"link"];
        subtitle=[subtitle stringByReplacingOccurrencesOfRegex:@"\n" withString:@""];
        
        
        
        //     NSLog(@"annotation title %@",annotation.title);
        
        //   int i=0;
        if([annotation.title isEqualToString:title] ){
            destinazione.latitude = [[[elencoFeed objectAtIndex:i] objectForKey:@"latitudine"] floatValue];
            destinazione.longitude = [[[elencoFeed objectAtIndex:i] objectForKey:@"longitudine"] floatValue];
            destinazione.name = annotation.title;
            destinazione.description =annotation.subtitle;
            //     NSLog(@"shopPoints ad index %@",title);
            if ([link2 rangeOfString:@"nessuna"].length == 0) {
                //  pin2View.pinColor=MKPinAnnotationColorGreen;
                
            }
            
            UIImage *flagImage= [UIImage imageNamed:@"pinverde.png"];
            
            
            
            
            CGRect resizeRect;
            
            
            
            resizeRect.size = flagImage.size;
            
            CGSize maxSize = CGRectInset(self.view.bounds,
                                         
                                         [Mappa annotationPadding],
                                         
                                         [Mappa annotationPadding]).size;
            
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [Mappa calloutHeight];
            
            if (resizeRect.size.width > maxSize.width)
                
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            
            if (resizeRect.size.height > maxSize.height)
                
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            
            
            resizeRect.origin = (CGPoint){0.0f, 0.0f};
            
            UIGraphicsBeginImageContext(resizeRect.size);
            
            [flagImage drawInRect:resizeRect];
            
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:resizedImage] autorelease];
            
            imageView.frame = CGRectMake(-5,-5, 40, 40);
            //    NSLog(@"Pin custom");
            [pin2View addSubview:imageView];
            
            pin2View.opaque = NO;
            //pin2View.image = pinImage;
            
           // testo=image;
            lk=link;
            
            
        }
        
    }
    
    
    //       NSLog(@"image link =%@",testo);
    //    NSLog(@"link =%@",lk);
    [UIColor colorWithWhite:0 alpha:.5];
    
    
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:annotation.title forState:UIControlStateNormal];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        //   [rightButton setImage:[UIImage imageNamed:@"freccinatrasparente.png"] forState:UIControlStateNormal];
        
    }else   // [rightButton setImage:[UIImage imageNamed:@"freccinatrasparentew.png"] forState:UIControlStateNormal];
        
        
[rightButton addTarget:self action:@selector(showDetails) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *aalta=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    aalta.image=[UIImage imageNamed:@"cropped-acqualtaVE_30.png"];
    pin2View.rightCalloutAccessoryView = aalta;
    
	
    
	return pin2View;
    
}
-(void)showDetails{
    
}

-(IBAction)gohere{
    // Check for iOS 6
    // _dest = [[Place alloc] init];
    //  NSLog(@"destinazione lat=%f",destinazione.latitude);
    //     NSLog(@"destinazione lng=%f",destinazione.longitude);
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake(destinazione.latitude, destinazione.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:titlemap];
        
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        // Get the "Current User Location" MKMapItem
        // Pass the map item to the Maps app
        [mapItem openInMapsWithLaunchOptions:launchOptions];
    }
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView {
    //  NSLog(@"si apre la annotationview");
    id<MKAnnotation> annotation = aView.annotation;
    
    if (!annotation || ![aView isSelected])
        return;
    destinazione = [[Place alloc] init];
	_dest = [[Place alloc] init];
    // non voglio vedere il pulsante del percorso se non ios6
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        percorsobutton.enabled=YES;
        percorsotextview.hidden=NO;
    }
    for (int i=0; i<[shopPoints count]; i++) {
        
        NSString *title=[[elencoFeed objectAtIndex:i] objectForKey:@"title"];
        title= [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if([annotation.title isEqualToString:title] ){
            destinazione.latitude = [[[elencoFeed objectAtIndex:i] objectForKey:@"latitudine"] floatValue];
            destinazione.longitude = [[[elencoFeed objectAtIndex:i] objectForKey:@"longitudine"] floatValue];
            destinazione.name = annotation.title;
            destinazione.description =annotation.subtitle;
            titlemap=annotation.title;
            _dest.latitude=destinazione.latitude;
            _dest.longitude=destinazione.longitude;
            
        }
    }
    // [self showMap:destinazione];
}

static NSString* const ANNOTATION_SELECTED_DESELECTED = @"mapAnnotationSelectedOrDeselected";

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	for (MKAnnotationView *anAnnotationView in views) {
		[anAnnotationView setCanShowCallout:YES];
		[anAnnotationView addObserver:self
                           forKeyPath:@"selected"
                              options:NSKeyValueObservingOptionNew
						      context:ANNOTATION_SELECTED_DESELECTED];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    
    
    NSString *action = (NSString *)context;
	if ([action isEqualToString:ANNOTATION_SELECTED_DESELECTED]) {
		BOOL annotationSelected = [[change valueForKey:@"new"] boolValue];
		if (annotationSelected) {
			NSLog(@"Annotation was selected, do whatever required");
            
            // Accions when annotation selected
		}else {
			NSLog(@"Annotation was deselected, do what you must");
            percorsobutton.enabled=NO;
            
            percorsotextview.hidden=YES;
		}
	}
}

- (IBAction)visualizzaMiaPosizione:(id)sender{
	
	//if ([segmentposizione selectedSegmentIndex]==0) {
	//	mapView.showsUserLocation=FALSE;
    //  locationManager.delegate = nil;
    //[locationManager stopUpdatingLocation];
	//} else if ([segmentposizione selectedSegmentIndex]==1) {
    mapView.showsUserLocation=TRUE;
    
    [self performSelector:@selector(zoomuser) withObject:nil afterDelay:1];
    
    
}

-(void)zoomuser{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta=0.1;
    span.longitudeDelta=0.1;
    
    CLLocationCoordinate2D location=mapView.userLocation.coordinate;
    
    region.span=span;
    region.center=location;
    
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
}



- (IBAction)mostraTipoMappa:(id)sender{
	if ([segmentTipoMappa selectedSegmentIndex]==0) {
		mapView.mapType = MKMapTypeStandard;
        osm.hidden=YES;
	} else if ([segmentTipoMappa selectedSegmentIndex]==1) {
		mapView.mapType = MKMapTypeSatellite;
        osm.hidden=YES;
	} else if ([segmentTipoMappa selectedSegmentIndex]==2) {
		mapView.mapType = MKMapTypeHybrid;
        osm.hidden=YES;
        
	}else if ([segmentTipoMappa selectedSegmentIndex]==3) {
        //  [self performSelectorOnMainThread:@selector(reloadMap) withObject:nil waitUntilDone:FALSE];
		//[self performSelectorOnMainThread:@selector(gotoosm) withObject:nil waitUntilDone:FALSE];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Attenzione"
                              message:@"Verranno scaricati i singoli Tiles di OpenStreeMap per il box inquadrato. Potrebbe essere necessario attendere 1-2 minuti. Procedi?"
                              delegate:self
                              cancelButtonTitle:@"Annulla"
                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
		
	}else {
        
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(mappaosm) userInfo:nil repeats:NO];
        NSLog(@"cliccato ok per OSM");
        //     [self rubricabackground];
        
    }
}
-(void)mappaosm{
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKAnnotation> annotation in shopPoints) {
        
        //   NSLog(@"Vai verso l'insieme dei POI centrando la mappa");
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
            //NSLog(@"else-%@",annotationPoint.x);
        }
        
        // Position the map so that all overlays and annotations are visible on screen.
        
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:0.1];
        
        
    }
    
    
    
    overlay = [[TileOverlay alloc] initOverlay];
    
    MKMapRect visibleRect = [mapView mapRectThatFits:overlay.boundingMapRect];
    visibleRect.size.width /= 2;
    visibleRect.size.height /= 2;
    visibleRect.origin.x += visibleRect.size.width / 2;
    visibleRect.origin.y += visibleRect.size.height / 2;
    
    mapView.visibleMapRect = flyTo;
    
    
    [mapView addOverlay:overlay];
    
    
    
    MKCoordinateRegion region;
    //Set Zoom level using Span
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    MKCoordinateSpan span;
    region.center=mapView.region.center;
    
    span.latitudeDelta=mapView.region.span.latitudeDelta *2;
    span.longitudeDelta=mapView.region.span.longitudeDelta *2;
    region.span=span;
    
    [UIView setAnimationDuration:0.30];
    [mapView setRegion:region animated:YES];
    [UIView commitAnimations];
    
    osm.hidden=NO;
    
}


-(void)cancelpin{
    
    NSArray *existingpoints = mapView.annotations;
    if ([existingpoints count] > 0) [mapView removeAnnotations:existingpoints];
    
    
}

-(IBAction)reload{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"";
    
    
    mytimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(reloadall) userInfo:nil repeats:NO];
    
}
- (IBAction)mostraTipoPin:(id)sender{
	if ([segmentTipoPin selectedSegmentIndex]==0) {
		pin = 1;
        [self performSelectorOnMainThread:@selector(reloadMap) withObject:nil waitUntilDone:FALSE];
		[self performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:FALSE];
        
        
	} else if ([segmentTipoPin selectedSegmentIndex]==1) {
		pin = 2;
		[self performSelectorOnMainThread:@selector(reloadMap) withObject:nil waitUntilDone:FALSE];
		[self performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:FALSE];
		
	} else if ([segmentTipoPin selectedSegmentIndex]==2) {
		pin = 0;
		[self performSelectorOnMainThread:@selector(reloadMap) withObject:nil waitUntilDone:FALSE];
		[self performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:FALSE];
	} else if ([segmentTipoPin selectedSegmentIndex]==3) {
		pin = 0;
		[self performSelectorOnMainThread:@selector(reloadMap) withObject:nil waitUntilDone:FALSE];
		[self performSelectorOnMainThread:@selector(viewDidLoad) withObject:nil waitUntilDone:FALSE];
	}
	
    
	
}




-(BOOL)ShouldAutorotate{
    return true;
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

-(void)viewDidDisappear:(BOOL)animated {
    //  [self gotoLocation];
    
	
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
    
}

- (void)dealloc {
    
    if(routes) {
		[routes release];
	}
	[routeView release];
    [locationManager release];
	[mapView release];
	[segmentTipoPin release];
	[segmentposizione release];
    [elencoFeed release];
    [shopPoints release];
    [overlay release];
    [feed release];
    
    [super dealloc];
}


@end

