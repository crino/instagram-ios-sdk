##Instagram iOS SDK

This open source iOS library allows you to integrate Instagram into your iOS application include iPhone, iPad and iPod touch.

It's inspired by [Facebook iOS SDK](https://github.com/facebook/facebook-ios-sdk/)

##Getting Started

* Register your application on [Instagram website](http://instagram.com/developer/clients/manage/).

* Set **REDIRECT URI** to ig\[clientId\]://authorize .

* Make sure you've edited your application's .plist file properly, so that your applicaition binds to the ig\[clientId\]:// URL scheme (where "\[clientId\]" is your Instagram application CLIENT ID).

* Capture instagram schema in your application
``` objective-c
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.instagram handleOpenURL:url]; 
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.instagram handleOpenURL:url];    
}
```

##Requirements

The library 1.1.0 and higher requires either iOS 5.0 and above.

For compatibility with iOS 4.3, use the latest 1.0.0 release.

## Creators

instagram-sdk-ios was created by [Cristiano Severini](https://github.com/crino/) .

### Credits

[List of contributors](https://github.com/crino/instagram-ios-sdk/graphs/contributors).

##License

Copyright (C) 2012 [Cristiano Severini](https://github.com/crino/)

Distributed under the MIT License.
