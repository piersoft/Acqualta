/*
     File: RootViewController.h
 Abstract: View controller for displaying the earthquake list.
  Version: 2.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "IEURLConnection.h"



@interface RootViewController_j : UIViewController <UIActionSheetDelegate,UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UITextFieldDelegate> {
    
    
   // NSMutableArray *earthquakeList;
    NSString *myAnnotation;
    UITableView *_tableView;
       CGFloat magnitude;
    NSMutableArray *elencoFeed;
    NSString *feeds;
    long long fileSizeRemote;
   IBOutlet UISearchDisplayController *searchDisplayController;
	 NSXMLParser *rssParser;
	//variabile temporanea pe ogni elemento
	NSMutableDictionary *item;
	
	// valori dei campi letti dal feed
	NSString *currentElement;
	NSMutableString *currentTitle, *currentDate, *currentSummary, *currentLink, *currentImage, *currentThumbnail,*currentLat,*currentLon, *currentId,*currentWWW, *currentEmail,*currentCategory;
    
    // This date formatter is used to convert NSDate objects to NSString objects, using the user's preferred formats.
    NSDateFormatter *dateFormatter;
    IBOutlet UIImageView *sfondo;
    IBOutlet UIImageView *check;
        IBOutlet UIImageView *barra;
            IBOutlet UIImageView *barraup;
        IBOutlet UIButton *refresh;
    IBOutlet UILabel *aggiornamento;
    IBOutlet UITableViewCell *cellaView;
    IBOutlet UITableViewCell *CellCustomipad;
    IBOutlet UITableViewCell *cellaView_s;
    IBOutlet UITableViewCell *CellCustomipad_s;
      MBProgressHUD *_hud;
    IBOutlet UIToolbar *toolBar;
 NSNumber *scopeButtonPressedIndexNumber;
    IBOutlet UISegmentedControl *segbar;
   IBOutlet UIImageView *sfondotabella;
    IBOutlet UILabel *version;
       IBOutlet UILabel *titolo;
    IBOutlet UIBarButtonItem *prev;
    IBOutlet UIBarButtonItem *succ;
    int start;
    int start1;
    BOOL filtro;
     UILabel                     *noResultLabel;
    int par;
    BOOL isFiltered;
   IBOutlet UITextField *ricerca;
    
}
@property (nonatomic, strong) NSDictionary *tracks;
@property (strong, nonatomic)    IBOutlet UILabel *titolo;
@property (nonatomic, assign) BOOL isFiltered;
@property (strong, nonatomic) IBOutlet UISearchBar *search;
@property (nonatomic, retain) NSMutableArray *filteredListItems;
@property (nonatomic, retain)   NSString *feeds;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic, copy) NSString *prova;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic, retain) IBOutlet UITextField *ricerca;
@property (retain) MBProgressHUD *hud;
//@property (nonatomic, retain) NSMutableArray *earthquakeList;


@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) CGFloat magnitude;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;

//- (void)insertEarthquakes:(NSArray *)earthquakes;   // addition method of earthquakes (for KVO purposes)
-(IBAction)prevpage;
-(IBAction)nextpage;
@end
