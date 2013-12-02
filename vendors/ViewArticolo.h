//
//  ViewArticolo.h
//  SimpleRSSreader
//
//  Created by Andrea Busi on 17/05/10.
//  Copyright 2010 BubiDevs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//#import "PullToRefreshTableViewController.h"
//#import "EGORefreshTableHeaderView.h"
#import "Reachability.h"
//#import "SHK.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>


@interface ViewArticolo : UIViewController <UIWebViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,UIActivityItemSource,UIGestureRecognizerDelegate>
{
    
 
	IBOutlet UIWebView *webView;
    IBOutlet UIWebView *webView1;
	IBOutlet UIActivityIndicatorView *m_activity; 
	NSString *sommario;
	NSString *indirizzo;
      IBOutlet UIBarButtonItem *menu;
    	NSString *indirizzo1;
    NSString *indirizzoazienda;
    NSString *emailaz;
     NSString *www;
    NSString *immagine;
       NSString *phone;
         NSString *lat;
         NSString *longi;
       NSString *map;
    NSString *datatext;
    NSString *titoloview;
	UIScrollView *iScrollview;
	UIToolbar * _toolbar;	
	int badge;
	int largo;
    int caricato;
	NSTimer *mytimer;
	UIAlertView *alertView3	;
    UILabel *dateLabel;
    UILabel *dateLabel1;
   IBOutlet UILabel *titolo;
    NSString *titolotext;
    UILabel *data;
    CGFloat myFontSize;
      UIPopoverController *popovercontroller;
    IBOutlet UISlider *slider;
    UIImageView *logo;
   IBOutlet UIImageView *sfondo;
    BOOL fit;
     BOOL chiama;
    IBOutlet UIBarButtonItem *avanti;
    IBOutlet UIButton *playButton;
      IBOutlet UIButton *phoneButton;
      IBOutlet UIButton *mapButton;
    IBOutlet UIBarButtonItem *indietro;
       IBOutlet UIBarButtonItem *webcam;
     IBOutlet UIBarButtonItem *webcamimage;
    IBOutlet UIButton *fb;
    IBOutlet UIButton *tw;
       IBOutlet UIButton *mail;
    NSString *buttonoff;
        MBProgressHUD *_hud;
   // IBOutlet UIToolbar *toolBar;
    IBOutlet UIToolbar *toolbarsotto;
   
}
@property (retain) MBProgressHUD *hud;
@property (nonatomic, retain) IBOutlet UIImageView *barra;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *titolo;
@property (nonatomic, retain) IBOutlet UIToolbar * toolbar;
@property (nonatomic, retain) NSString *indirizzo;
@property (nonatomic, retain) NSString *buttonoff;
@property (nonatomic, retain) NSString *indirizzo1;
@property (nonatomic, retain) NSString *titolotext;
@property (nonatomic, retain) NSString *indirizzoazienda;
@property (nonatomic, retain) NSString *emailaz;
@property (nonatomic, retain) NSString *www;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *map;
@property (nonatomic, retain) NSString *lat;
@property (nonatomic, retain) NSString *longi;
@property (nonatomic, retain) NSString *immagine;
@property (nonatomic, retain) NSString *titoloview;
@property (nonatomic, retain) NSString *datatext;
@property(assign,getter=isReloading) BOOL fit;
@property (nonatomic, retain) NSString *sommario;
@property (nonatomic, retain) UIActivityIndicatorView *m_activity;

-(IBAction)rubrica;
-(IBAction)back;
-(IBAction)share;

@end
