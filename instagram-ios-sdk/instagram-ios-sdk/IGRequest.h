//
//  IGRequest.h
//  instagram-ios-sdk
//
//  Created by Cristiano Severini on 18/04/12.
//  Copyright (c) 2012 IQUII. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IGRequestDelegate;


enum {
    kIGRequestStateReady,
    kIGRequestStateLoading,
    kIGRequestStateComplete,
    kIGRequestStateError
};
typedef NSUInteger IGRequestState;

extern NSString* const InstagramErrorDomain;

@interface IGRequest : NSObject {
    
}

@property(nonatomic, weak) id<IGRequestDelegate> delegate;
@property(nonatomic, strong) NSString* url;
@property(nonatomic, strong) NSString* httpMethod;
@property(nonatomic, strong) NSMutableDictionary* params;
@property(nonatomic, strong) NSURLConnection* connection;
@property(nonatomic, strong) NSMutableData* responseText;
@property(nonatomic, readonly) IGRequestState state;
@property(nonatomic, strong) NSError* error;

+(NSString*)serializeURL:(NSString*)baseUrl
                  params:(NSDictionary*)params;

+(NSString*)serializeURL:(NSString*)baseUrl
                  params:(NSDictionary*)params
              httpMethod:(NSString*)httpMethod;

+(IGRequest*)getRequestWithParams:(NSMutableDictionary*)params
                       httpMethod:(NSString*)httpMethod
                         delegate:(id<IGRequestDelegate>)delegate
                       requestURL:(NSString*)url;

-(BOOL)loading;

-(void)connect;

@end


#pragma mark

@protocol IGRequestDelegate <NSObject>

@optional

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(IGRequest *)request;

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(IGRequest *)request didReceiveResponse:(NSURLResponse *)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(IGRequest *)request didFailWithError:(NSError *)error;

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(IGRequest *)request didLoad:(id)result;

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(IGRequest *)request didLoadRawResponse:(NSData *)data;

@end