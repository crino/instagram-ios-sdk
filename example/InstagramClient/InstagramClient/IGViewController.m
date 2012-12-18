//
//  IGViewController.m
//  InstagramClient
//
//  Created by Cristiano Severini on 12/07/12.
//  Copyright (c) 2012 Crino. All rights reserved.
//

#import "IGViewController.h"

#import "IGAppDelegate.h"
#import "IGListViewController.h"

@interface IGViewController ()

@end

@implementation IGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton sizeToFit];
    loginButton.center = CGPointMake(160, 200);
    [loginButton addTarget:self 
                    action:@selector(login) 
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    
    IGAppDelegate* appDelegate = (IGAppDelegate*)[UIApplication sharedApplication].delegate;
    
    // here i can set accessToken received on previous login 
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    appDelegate.instagram.sessionDelegate = self;
    if ([appDelegate.instagram isSessionValid]) {
        IGListViewController* viewController = [[IGListViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)login {
    IGAppDelegate* appDelegate = (IGAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
}

#pragma - IGSessionDelegate

-(void)igDidLogin {
    NSLog(@"Instagram did login");
    // here i can store accessToken
    IGAppDelegate* appDelegate = (IGAppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    IGListViewController* viewController = [[IGListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

-(void)igDidLogout {
    NSLog(@"Instagram did logout");
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"Instagram session was invalidated");
}

@end
