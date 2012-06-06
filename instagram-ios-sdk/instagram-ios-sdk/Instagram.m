//
//  Instagram.m
//  instagram-ios-sdk
//
//  Created by Cristiano Severini on 18/04/12.
//  Copyright (c) 2012 IQUII. All rights reserved.
//

#import "Instagram.h"


static NSString* kDialogBaseURL = @"https://instagram.com/";
//static NSString* kGraphBaseURL = @"https://graph.facebook.com/";
static NSString* kRestserverBaseURL = @"https://api.instagram.com/v1/";


//static NSString* kFBAppAuthURLScheme = @"fbauth";
//static NSString* kFBAppAuthURLPath = @"authorize";
//static NSString* kRedirectURL = @"igconnect://success";

static NSString* kLogin = @"oauth/authorize";
//static NSString* kSDK = @"ios";
//static NSString* kSDKVersion = @"2";

static NSString *requestFinishedKeyPath = @"state";
static void *finishedContext = @"finishedContext";




@interface Instagram ()

@property(nonatomic, strong) NSArray* scopes;
@property(nonatomic, strong) NSString* clientId;

-(void)authorizeWithSafary;

@end


@implementation Instagram

@synthesize accessToken = _accessToken;
@synthesize sessionDelegate = _sessionDelegate;
@synthesize scopes = _scopes;
@synthesize clientId = _clientId;

-(id)initWithClientId:(NSString*)clientId delegate:(id<IGSessionDelegate>)delegate {
    self = [super init];
    if (self) {
        self.clientId = clientId;
        self.sessionDelegate = delegate;
        _requests = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc {
    for (IGRequest* request in _requests) {
        [_requests removeObserver:self forKeyPath:requestFinishedKeyPath];
    }
}

#pragma mark - internal

-(void)invalidateSession {
    self.accessToken = nil;
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* instagramCookies = [cookies cookiesForURL:[NSURL URLWithString:kDialogBaseURL]];
    
    for (NSHTTPCookie* cookie in instagramCookies) {
        [cookies deleteCookie:cookie];
    }
}

- (IGRequest*)openUrl:(NSString *)url
               params:(NSMutableDictionary *)params
           httpMethod:(NSString *)httpMethod
             delegate:(id<IGRequestDelegate>)delegate {
    
//    [params setValue:@"json" forKey:@"format"];
//    [params setValue:kSDK forKey:@"sdk"];
//    [params setValue:kSDKVersion forKey:@"sdk_version"];
    if ([self isSessionValid]) {
        [params setValue:self.accessToken forKey:@"access_token"];
    }
    
    IGRequest* _request = [IGRequest getRequestWithParams:params
                                               httpMethod:httpMethod
                                                 delegate:delegate
                                               requestURL:url];
    [_requests addObject:_request];
    [_request addObserver:self forKeyPath:requestFinishedKeyPath options:0 context:finishedContext];
    [_request connect];
    return _request;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == finishedContext) {
        IGRequest* _request = (IGRequest*)object;
        IGRequestState requestState = [_request state];
        if (requestState == kIGRequestStateError) {
            [self invalidateSession];
            if ([self.sessionDelegate respondsToSelector:@selector(igSessionInvalidated)]) {
                [self.sessionDelegate igSessionInvalidated];
            }
        }
        if (requestState == kIGRequestStateComplete || requestState == kIGRequestStateError) {
            [_request removeObserver:self forKeyPath:requestFinishedKeyPath];
            [_requests removeObject:_request];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSString *)getOwnBaseUrl {
    return [NSString stringWithFormat:@"ig%@://authorize", self.clientId];
}

/**
 * A private function for opening the authorization dialog.
 */
- (void)authorizeWithSafary {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.clientId, @"client_id",
                                   @"token", @"response_type",
                                   [self getOwnBaseUrl], @"redirect_uri",
                                   nil];
    
    NSString *loginDialogURL = [kDialogBaseURL stringByAppendingString:kLogin];
    
    if (self.scopes != nil) {
        NSString* scope = [self.scopes componentsJoinedByString:@"+"];
        [params setValue:scope forKey:@"scope"];
    }
    
    // If the device is running a version of iOS that supports multitasking,
    // try to obtain the access token from Safary
    BOOL didOpenOtherApp = NO;
//    UIDevice *device = [UIDevice currentDevice];
//    if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
        
//        NSString *nextUrl = [self getOwnBaseUrl];
//        [params setValue:nextUrl forKey:@"redirect_uri"];
        
        NSString *igAppUrl = [IGRequest serializeURL:loginDialogURL params:params];
        didOpenOtherApp = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:igAppUrl]];
//    }
    
// If single sign-on failed, open an inline login dialog. This will require the user to
// enter his or her credentials.
//    if (!didOpenOtherApp) {
//        [_loginDialog release];
//        _loginDialog = [[FBLoginDialog alloc] initWithURL:loginDialogURL
//                                              loginParams:params
//                                                 delegate:self];
//        [_loginDialog show];
//    }
}

- (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}

#pragma mark - public

-(void)authorize:(NSArray *)scopes {
    self.scopes = scopes;
    
    [self authorizeWithSafary];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    // If the URL's structure doesn't match the structure used for Instagram authorization, abort.
    if (![[url absoluteString] hasPrefix:[self getOwnBaseUrl]]) {
        return NO;
    }
    
    NSString *query = [url fragment];
    if (!query) {
        query = [url query];
    }
    
    NSDictionary *params = [self parseURLParams:query];
    NSString *accessToken = [params valueForKey:@"access_token"];
    
    // If the URL doesn't contain the access token, an error has occurred.
    if (!accessToken) {
//        NSString *error = [params valueForKey:@"error"];
        
        NSString *errorReason = [params valueForKey:@"error_reason"];
        
        BOOL userDidCancel = [errorReason isEqualToString:@"user_denied"];
        [self igDidNotLogin:userDidCancel];
        return YES;
    }
    
//    // We have an access token, so parse the expiration date.
//    NSString *expTime = [params valueForKey:@"expires_in"];
//    NSDate *expirationDate = [NSDate distantFuture];
//    if (expTime != nil) {
//        int expVal = [expTime intValue];
//        if (expVal != 0) {
//            expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
//        }
//    }
    
    [self igDidLogin:accessToken/* expirationDate:expirationDate*/];
    return YES;
}

- (void)logout {
    [self invalidateSession];
    
    if ([self.sessionDelegate respondsToSelector:@selector(igDidLogout)]) {
        [self.sessionDelegate igDidLogout];
    }
}

-(IGRequest*)requestWithParams:(NSMutableDictionary*)params
                      delegate:(id<IGRequestDelegate>)delegate {
    if ([params objectForKey:@"method"] == nil) {
        NSLog(@"API Method must be specified");
        return nil;
    }
    
    NSString * methodName = [params objectForKey:@"method"];
    [params removeObjectForKey:@"method"];
    
    return [self requestWithMethodName:methodName
                                params:params
                            httpMethod:@"GET"
                              delegate:delegate];
}

-(IGRequest*)requestWithMethodName:(NSString*)methodName
                            params:(NSMutableDictionary*)params
                        httpMethod:(NSString*)httpMethod
                          delegate:(id<IGRequestDelegate>)delegate {
    NSString * fullURL = [kRestserverBaseURL stringByAppendingString:methodName];
    return [self openUrl:fullURL
                  params:params
              httpMethod:httpMethod
                delegate:delegate];
}

- (BOOL)isSessionValid {
    return (self.accessToken != nil);
    
}

#pragma mark 

/**
 * Set the authToken after login succeed
 */
- (void)igDidLogin:(NSString *)token /*expirationDate:(NSDate *)expirationDate*/ {
    self.accessToken = token;
    if ([self.sessionDelegate respondsToSelector:@selector(igDidLogin)]) {
        [self.sessionDelegate igDidLogin];
    }
    
}

/**
 * Did not login call the not login delegate
 */
- (void)igDidNotLogin:(BOOL)cancelled {
    if ([self.sessionDelegate respondsToSelector:@selector(igDidNotLogin:)]) {
        [self.sessionDelegate igDidNotLogin:cancelled];
    }
}

@end
