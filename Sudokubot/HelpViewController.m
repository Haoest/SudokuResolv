//
//  HelpViewController.m
//  Sudokubot
//
//  Created by Haoest on 4/7/11.
//  Copyright 2011 none. All rights reserved.
//

#import "HelpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HelpViewController()

-(void) pagingTabIndexChanged:(id)sender;
-(IBAction) mainMenuButton_tapped;

@end

@implementation HelpViewController

@synthesize rootViewDelegate;
@synthesize pagingTabs, webView, solveButton, mainMenuButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.pagingTabs = nil;
    self.webView = nil;
    self.solveButton = nil;
    self.mainMenuButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects: 
                       (id)[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] CGColor],
                       (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.7 alpha:1] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    [pagingTabs addTarget:self action:@selector(pagingTabIndexChanged:) forControlEvents:UIControlEventValueChanged];
    [self pagingTabIndexChanged:nil];
    webView.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
     
 -(void) pagingTabIndexChanged:(id)sender{
     if (pagingTabs.selectedSegmentIndex == 0){
         [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help-intro" ofType:@"html"] isDirectory:false]]];
         [solveButton setHidden:false];
     }else{
         [solveButton setHidden:true];
         if (pagingTabs.selectedSegmentIndex==1){
             [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help-tips" ofType:@"html"] isDirectory:false]]];
         }else{
             [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help-thanks" ofType:@"html"] isDirectory:false]]];
         }
     }
 }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) solveButton_tap{
    [rootViewDelegate showPreview:[UIImage imageNamed:[NSString stringWithFormat:@"sample-puzzle.jpg"]]];
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType; {
    
    NSURL *requestURL = [ [ request URL ] retain ];
    if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ] ||
          [[requestURL scheme] isEqualToString:@"mailto"] ||
          [[requestURL scheme] isEqualToString:@"itms-apps"])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {
        return ![ [ UIApplication sharedApplication ] openURL: [ requestURL autorelease ] ];
    }
    [ requestURL release ];
    return YES;
}

-(IBAction) mainMenuButton_tapped{
    [rootViewDelegate showRootView];
}

@end
