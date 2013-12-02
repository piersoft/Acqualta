//
//  RootViewController.h
//  SimpleMapView
//
//  Created by Mayur Birari.

//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UserProfileVC.h"
#import "RegexKitLite.h"
#import <CoreLocation/CoreLocation.h>
//#import "WeatherAnnotationView.h"
//#import "MTGalleryViewController.h"
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "Place.h"
#import "PlaceMark.h"
 #import "TileOverlay.h"
@class DisplayMap,AppDelegate;


@interface MappaAPI : UIViewController<MKMapViewDelegate,UIApplicationDelegate,UIAlertViewDelegate,UIActionSheetDelegate,NSXMLParserDelegate,CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
	UIImageView* routeView;
    IBOutlet UIButton *osm;
    AppDelegate* appDelegate;
    
    Place* origine;
    Place* destinazione;
    
	
	NSArray* routes;
	
	UIColor* lineColor;
    
    CLLocationDistance distance;
    NSString *linkdapassare;
    NSString *feed;
    NSString *feedsubtit;
    NSString *feedlat;
    NSString *feedlon;
    NSString *titlemap;
    float *latmap;
    float *lngmap;
    // MKReverseGeocoder *reverseGeocoder;
	 IBOutlet UIBarButtonItem *backbutton;
     IBOutlet UIBarButtonItem *locationbutton;
	IBOutlet MKMapView* mapView;
	IBOutlet UserProfileVC* userProfileVC;
	IBOutlet UIButton *cmdMiaPosizione;
    IBOutlet UIBarButtonItem *percorsobutton;
	IBOutlet UISegmentedControl *segmentTipoMappa;
	IBOutlet UISegmentedControl *segmentTipoPin;
	IBOutlet UISegmentedControl *segmentposizione;
	IBOutlet UIToolbar *toolbar;
    IBOutlet UITextField *percorsotextview;
    
    // parser XML
	NSXMLParser *rssParser;
	// elenco degli elementi letti dal feed
	NSMutableArray *elencoFeed;
	
	//variabile temporanea pe ogni elemento
	NSMutableDictionary *item;
	
	// valori dei campi letti dal feed
	NSString *currentElement;
	NSMutableString *currentTitle, *currentCategory, *currentSummary, *currentLink, *currentImage, *currentLat, *currentLong, *currentCheck, *currentAddr,*currentWWW, *currentEmail;;
    
    //	IBOutlet UIButton *arbutton;
	NSTimer *mytimer;
	int pin;
	NSMutableArray *shopPoints;
    //  NSMutableArray *elencoFeed;
    
    //  NSMutableDictionary *item;
    //	ARViewController *cameraViewController;
    NSString *indirizzoshare;
    MBProgressHUD *_hud;
    int par;
    int chiese;
    
    IBOutlet UITextField *chieser;
    IBOutlet UITextField *gothere;
    IBOutlet UIBarButtonItem *menu;
    UIImageView *barra;
    
    //   IBOutlet UIWindow *window;
}
//@property (nonatomic, retain)  UIWindow *window;
@property (nonatomic, strong) NSDictionary *tracks;
- (id)calculateRoutesDistanceFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t;
- (void) showRouteFrom: (Place*) f to:(Place*) t typePath:(NSString*)type;
- (void) showMap: (Place*) t;
- (IBAction)gestioneZoom:(id)sender;
- (IBAction)gestioneScroll:(id)sender;

- (IBAction)scegliPercorso;
@property (nonatomic, retain)	IBOutlet UIImageView *barra;
@property (nonatomic, retain)	IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain)     NSString *feed;
@property (nonatomic, retain)     NSString *linkdapassare;
@property (nonatomic, retain)     NSString *feedsubtit;
@property (nonatomic, retain)     NSString *feedlat;
@property (nonatomic, retain)     NSString *feedlon;
@property (nonatomic, retain)     NSString *titlemap;
//@property (nonatomic, retain)     float *latmap;
//@property (nonatomic, retain)     float *lngmap;
@property (nonatomic, retain) Place* origine;
@property (nonatomic, retain) Place* destinazione;
@property (nonatomic, retain) Place* dest;
@property (nonatomic, retain) UIColor* lineColor;
@property (nonatomic, retain) TileOverlay *overlay;

+ (CGFloat)annotationPadding;

+ (CGFloat)calloutHeight;

@property (retain) MBProgressHUD *hud;




-(IBAction)goBack;
@property(nonatomic,retain)	IBOutlet MKMapView* mapView;
@property(nonatomic,retain)	   NSString *indirizzoshare;
@property(nonatomic,retain) IBOutlet UserProfileVC* userProfileVC;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentposizione;
@property (nonatomic, retain) IBOutlet UIButton *cmdMiaPosizione;



- (IBAction)visualizzaMiaPosizione:(id)sender;
- (IBAction)mostraTipoMappa:(id)sender;
- (IBAction)mostraTipoPin:(id)sender;

//-(IBAction)info;

//-(IBAction) displayAR:(id) sender;

//@property (nonatomic, retain) ARViewController *cameraViewController;
//@property (nonatomic, retain) UIViewController *infoViewController;


-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRouteView;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to typePath:(NSString*)type;
-(void) centerMap;

@end
